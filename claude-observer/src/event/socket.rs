use super::{Event, HookEvent};
use color_eyre::Result;
use std::path::Path;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::net::UnixListener;
use tokio::sync::mpsc;
use tokio::time::{timeout, Duration};

/// Listen for hook events on Unix socket
pub async fn listen(tx: mpsc::Sender<Event>, socket_path: &Path) -> Result<()> {
    // Remove existing socket file
    if socket_path.exists() {
        std::fs::remove_file(socket_path)?;
    }

    // Bind to socket
    let listener = UnixListener::bind(socket_path)?;
    tracing::info!("Listening on {:?}", socket_path);

    loop {
        match listener.accept().await {
            Ok((stream, _)) => {
                let tx = tx.clone();
                tokio::spawn(async move {
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
            }
        }
    }
}
