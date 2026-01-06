//! Claude Observer - Real-time observability TUI for Claude Code instances
//!
//! Monitors Claude Code hook events via Unix socket and displays
//! agent status in a beautiful terminal interface.

mod app;
mod config;
mod event;
mod state;
mod ui;

use app::App;
use clap::Parser;
use color_eyre::Result;
use crossterm::{
    event::{DisableMouseCapture, EnableMouseCapture},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::prelude::*;
use std::io::stdout;
use std::path::PathBuf;
use tokio::sync::mpsc;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

/// Real-time observability TUI for Claude Code instances
#[derive(Parser, Debug)]
#[command(name = "claude-observer")]
#[command(author, version, about, long_about = None)]
#[command(propagate_version = true)]
struct Cli {
    /// Socket path for receiving hook events
    #[arg(short, long, env = "CLAUDE_OBSERVER_SOCKET", default_value = "/tmp/claude-observer.sock")]
    socket: PathBuf,

    /// Log level (trace, debug, info, warn, error)
    #[arg(short, long, env = "RUST_LOG", default_value = "info")]
    log_level: String,

    /// Run in debug mode (shows event log)
    #[arg(short, long, default_value_t = false)]
    debug: bool,

    /// Install binary to ~/.local/bin/
    #[arg(long, default_value_t = false)]
    install: bool,
}

/// Get the log directory path
fn get_log_dir() -> PathBuf {
    directories::BaseDirs::new()
        .map(|dirs| dirs.cache_dir().join("claude-observer").join("logs"))
        .unwrap_or_else(|| PathBuf::from("/tmp/claude-observer/logs"))
}

/// Install the binary to ~/.local/bin/
fn install_binary() -> Result<()> {
    let current_exe = std::env::current_exe()?;
    let home = std::env::var("HOME").unwrap_or_else(|_| "/tmp".to_string());
    let install_dir = PathBuf::from(home).join(".local").join("bin");
    let install_path = install_dir.join("claude-observer");

    // Create directory if needed
    std::fs::create_dir_all(&install_dir)?;

    // Copy binary
    std::fs::copy(&current_exe, &install_path)?;

    // Make executable (Unix only)
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        let mut perms = std::fs::metadata(&install_path)?.permissions();
        perms.set_mode(0o755);
        std::fs::set_permissions(&install_path, perms)?;
    }

    println!("Installed to: {}", install_path.display());
    println!("Make sure ~/.local/bin is in your PATH");
    Ok(())
}

#[tokio::main]
async fn main() -> Result<()> {
    // Parse CLI arguments
    let cli = Cli::parse();

    // Handle --install flag
    if cli.install {
        return install_binary();
    }

    // Initialize error handling
    color_eyre::install()?;

    // Setup file logging with rotation
    let log_dir = get_log_dir();
    std::fs::create_dir_all(&log_dir)?;

    let file_appender = tracing_appender::rolling::daily(&log_dir, "claude-observer.log");
    let (non_blocking, _guard) = tracing_appender::non_blocking(file_appender);

    // Initialize logging with both file and stderr
    let log_filter = format!("claude_observer={}", cli.log_level);
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::new(&log_filter))
        .with(
            tracing_subscriber::fmt::layer()
                .with_target(true)
                .with_writer(non_blocking),
        )
        .init();

    tracing::info!("Starting claude-observer v{}", env!("CARGO_PKG_VERSION"));
    tracing::info!("Log directory: {:?}", log_dir);
    tracing::debug!("Socket path: {:?}", cli.socket);

    // Create event channel
    let (event_tx, event_rx) = mpsc::channel(100);

    // Spawn socket listener
    let socket_path = cli.socket.clone();
    let socket_tx = event_tx.clone();
    let socket_handle = tokio::spawn(async move {
        if let Err(e) = event::socket::listen(socket_tx, &socket_path).await {
            tracing::error!("Socket listener error: {}", e);
        }
    });

    // Run TUI
    let result = run_tui(event_tx, event_rx, cli.debug).await;

    // Cleanup
    socket_handle.abort();

    // Remove socket file
    if cli.socket.exists() {
        let _ = std::fs::remove_file(&cli.socket);
    }

    result
}

async fn run_tui(
    event_tx: mpsc::Sender<event::Event>,
    mut event_rx: mpsc::Receiver<event::Event>,
    debug_mode: bool,
) -> Result<()> {
    // Setup terminal
    enable_raw_mode()?;
    let mut stdout = stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    // Create app state
    let mut app = App::new(debug_mode);

    // Spawn input event handler
    let input_tx = event_tx.clone();
    tokio::spawn(async move {
        event::input::listen(input_tx).await;
    });

    // Main loop
    loop {
        // Render
        terminal.draw(|f| ui::render(f, &app))?;

        // Handle events with timeout for tick updates
        tokio::select! {
            Some(event) = event_rx.recv() => {
                app.handle_event(event);
            }
            _ = tokio::time::sleep(std::time::Duration::from_secs(1)) => {
                app.tick();
            }
        }

        if app.should_quit {
            break;
        }
    }

    // Restore terminal
    disable_raw_mode()?;
    execute!(
        terminal.backend_mut(),
        LeaveAlternateScreen,
        DisableMouseCapture
    )?;
    terminal.show_cursor()?;

    Ok(())
}
