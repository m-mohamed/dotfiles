use super::Event;
use crossterm::event::{self, Event as CrosstermEvent};
use std::time::Duration;
use tokio::sync::mpsc;

/// Listen for keyboard input events
pub async fn listen(tx: mpsc::Sender<Event>) {
    loop {
        // Poll with timeout to allow for graceful shutdown
        if event::poll(Duration::from_millis(100)).unwrap_or(false) {
            if let Ok(CrosstermEvent::Key(key)) = event::read() {
                if tx.send(Event::Key(key)).await.is_err() {
                    break;
                }
            }
        }

        // Yield to allow other tasks to run
        tokio::task::yield_now().await;
    }
}
