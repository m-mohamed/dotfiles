use ratatui::style::Color;

/// Socket path for IPC
pub const SOCKET_PATH: &str = "/tmp/claude-observer.sock";

/// Maximum events to keep in history
pub const MAX_EVENTS: usize = 50;

/// Maximum sparkline data points
pub const MAX_SPARKLINE_POINTS: usize = 60;

/// Tokyo Night color palette
pub mod colors {
    use super::Color;

    pub const BG: Color = Color::Rgb(26, 27, 38);           // #1a1b26
    pub const BG_LIGHT: Color = Color::Rgb(41, 46, 66);     // #292e42 lighter bg
    pub const FG: Color = Color::Rgb(192, 202, 245);        // #c0caf5
    pub const WORKING: Color = Color::Rgb(122, 162, 247);   // #7aa2f7 blue
    pub const WORKING_BRIGHT: Color = Color::Rgb(157, 187, 255); // brighter blue for pulse
    pub const ATTENTION: Color = Color::Rgb(255, 158, 100); // #ff9e64 orange
    pub const IDLE: Color = Color::Rgb(86, 95, 137);        // #565f89 gray
    pub const COMPACTING: Color = Color::Rgb(224, 175, 104); // #e0af68 yellow
    pub const BORDER: Color = Color::Rgb(59, 66, 97);       // #3b4261
    pub const HIGHLIGHT: Color = Color::Rgb(187, 154, 247); // #bb9af7 purple
}
