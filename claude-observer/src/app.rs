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
            Event::Tick => {
                self.tick();
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

    /// Tick for updating elapsed times
    pub fn tick(&mut self) {
        // Update activity sparklines with current values
        for agent in self.state.agents.values_mut() {
            let activity_value = match &agent.status {
                crate::state::Status::Working => 1.0,
                crate::state::Status::Attention(_) => 0.8,
                crate::state::Status::Compacting => 0.6,
                crate::state::Status::Idle => 0.1,
            };
            agent.activity.push_back(activity_value);
            if agent.activity.len() > crate::config::MAX_SPARKLINE_POINTS {
                agent.activity.pop_front();
            }
        }
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
