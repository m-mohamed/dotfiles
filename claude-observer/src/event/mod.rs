pub mod input;
pub mod socket;

use serde::Deserialize;

/// Application events
#[derive(Debug)]
pub enum Event {
    /// Hook event from Claude Code
    Hook(HookEvent),
    /// Keyboard input
    Key(crossterm::event::KeyEvent),
}

/// Hook event from Claude Code
#[derive(Debug, Clone, Deserialize)]
pub struct HookEvent {
    /// Event type (PreToolUse, Stop, etc.)
    pub event: String,
    /// Status (working, idle, attention, compacting)
    pub status: String,
    /// Attention type (permission, input) - optional
    pub attention_type: Option<String>,
    /// WezTerm pane ID
    pub pane_id: String,
    /// Project/repo name
    pub project: String,
    /// Unix timestamp
    pub timestamp: i64,
}
