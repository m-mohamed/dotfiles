use crate::event::Event;
use crate::state::AppState;
use crossterm::event::{KeyCode, KeyModifiers};
use std::process::Command;

/// Application state and logic
pub struct App {
    pub state: AppState,
    pub should_quit: bool,
    pub debug_mode: bool,
    pub show_help: bool,
}

impl App {
    pub fn new(debug_mode: bool) -> Self {
        Self {
            state: AppState::new(),
            should_quit: false,
            debug_mode,
            show_help: false,
        }
    }

    /// Handle incoming events
    pub fn handle_event(&mut self, event: Event) {
        match event {
            Event::Hook(hook_event) => {
                self.state.process_event(hook_event);
            }
            Event::Key(key) => {
                self.handle_key(key);
            }
        }
    }

    /// Handle keyboard input
    fn handle_key(&mut self, key: crossterm::event::KeyEvent) {
        // Handle Ctrl+C
        if key.modifiers.contains(KeyModifiers::CONTROL) && key.code == KeyCode::Char('c') {
            self.should_quit = true;
            return;
        }

        match key.code {
            // Quit
            KeyCode::Char('q') | KeyCode::Esc => {
                self.should_quit = true;
            }
            // Navigation
            KeyCode::Char('j') | KeyCode::Down => {
                self.state.next();
            }
            KeyCode::Char('k') | KeyCode::Up => {
                self.state.previous();
            }
            // Jump to agent
            KeyCode::Enter => {
                self.jump_to_selected();
            }
            // Toggle help
            KeyCode::Char('?') | KeyCode::Char('h') => {
                self.show_help = !self.show_help;
            }
            // Toggle debug mode
            KeyCode::Char('d') => {
                self.debug_mode = !self.debug_mode;
            }
            _ => {}
        }
    }

    /// Tick for triggering re-renders
    ///
    /// Best practice from ratatui async-template:
    /// - Events update state (hook events push activity data)
    /// - Ticks trigger re-render only (no new data)
    ///
    /// This ensures sparkline consistency - activity values only come
    /// from real hook events, not synthesized tick data.
    pub fn tick(&mut self) {
        // No-op: Activity data comes from hook events only.
        // Tick exists to trigger re-render at 1-second intervals.
        // See: https://github.com/ratatui-org/async-template
    }

    /// Jump to selected agent using wezterm CLI
    fn jump_to_selected(&self) {
        if let Some(agent) = self.state.selected_agent() {
            let pane_id = &agent.pane_id;
            tracing::info!("Jumping to pane {}", pane_id);

            // Use wezterm CLI to activate pane
            let result = Command::new("wezterm")
                .args(["cli", "activate-pane", "--pane-id", pane_id])
                .output();

            match result {
                Ok(output) => {
                    if !output.status.success() {
                        tracing::warn!(
                            "Failed to activate pane: {}",
                            String::from_utf8_lossy(&output.stderr)
                        );
                    }
                }
                Err(e) => {
                    tracing::error!("Failed to run wezterm CLI: {}", e);
                }
            }
        }
    }
}
