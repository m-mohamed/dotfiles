use super::{Event, HookEvent};
use color_eyre::Result;
use std::path::Path;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::net::UnixListener;
use tokio::sync::mpsc;

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

                    while let Ok(Some(line)) = lines.next_line().await {
                        if line.trim().is_empty() {
                            continue;
                        }

                        match serde_json::from_str::<HookEvent>(&line) {
                            Ok(event) => {
                                tracing::debug!("Received event: {:?}", event);
                                if tx.send(Event::Hook(event)).await.is_err() {
                                    break;
                                }
                            }
                            Err(e) => {
                                tracing::warn!("Failed to parse event: {} - {}", e, line);
                            }
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
