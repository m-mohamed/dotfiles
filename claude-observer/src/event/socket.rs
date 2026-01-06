use super::{Event, HookEvent};
use color_eyre::Result;
use std::path::Path;
use std::sync::Arc;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::net::UnixListener;
use tokio::sync::{mpsc, Semaphore};
use tokio::time::{timeout, Duration};

/// Maximum concurrent connections to prevent resource exhaustion
const MAX_CONNECTIONS: usize = 100;

/// Listen for hook events on Unix socket
pub async fn listen(tx: mpsc::Sender<Event>, socket_path: &Path) -> Result<()> {
    // Remove existing socket file
    if socket_path.exists() {
        std::fs::remove_file(socket_path)?;
    }

    // Bind to socket
    let listener = UnixListener::bind(socket_path)?;
    tracing::info!("Listening on {:?}", socket_path);

    // Semaphore to limit concurrent connections
    let semaphore = Arc::new(Semaphore::new(MAX_CONNECTIONS));

    // Backoff state for accept errors
    let mut backoff_ms: u64 = 0;
    const MAX_BACKOFF_MS: u64 = 5000;

    loop {
        match listener.accept().await {
            Ok((stream, _)) => {
                // Reset backoff on successful accept
                backoff_ms = 0;

                // Try to acquire permit (non-blocking check)
                let permit = match semaphore.clone().try_acquire_owned() {
                    Ok(permit) => permit,
                    Err(_) => {
                        tracing::warn!("Connection limit reached ({} max), dropping connection", MAX_CONNECTIONS);
                        continue;
                    }
                };

                let tx = tx.clone();
                tokio::spawn(async move {
                    // Permit is held until this task completes
                    let _permit = permit;

                    let reader = BufReader::new(stream);
                    let mut lines = reader.lines();

                    // Read with timeout - hooks send single-line JSON messages
                    // Use 2 second timeout to handle slow connections
                    let read_result = timeout(Duration::from_secs(2), lines.next_line()).await;

                    match read_result {
                        Ok(Ok(Some(line))) if !line.trim().is_empty() => {
                            match serde_json::from_str::<HookEvent>(&line) {
                                Ok(event) => {
                                    tracing::debug!("Received event: {:?}", event);
                                    let _ = tx.send(Event::Hook(event)).await;
                                }
                                Err(e) => {
                                    tracing::warn!("Failed to parse event: {} - {}", e, line);
                                }
                            }
                        }
                        Ok(Ok(Some(_))) => {} // Empty line, ignore
                        Ok(Ok(None)) => {}    // Stream closed
                        Ok(Err(e)) => {
                            tracing::warn!("Read error: {}", e);
                        }
                        Err(_) => {
                            tracing::debug!("Read timeout (connection may be stale)");
                        }
                    }
                });
            }
            Err(e) => {
                tracing::error!("Accept error: {}", e);

                // Exponential backoff to prevent CPU spin on persistent errors
                if backoff_ms == 0 {
                    backoff_ms = 100;
                } else {
                    backoff_ms = (backoff_ms * 2).min(MAX_BACKOFF_MS);
                }

                tracing::debug!("Backing off for {}ms", backoff_ms);
                tokio::time::sleep(Duration::from_millis(backoff_ms)).await;
            }
        }
    }
}
