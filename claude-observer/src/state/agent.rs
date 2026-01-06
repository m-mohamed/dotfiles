use std::collections::VecDeque;

/// Agent status
#[derive(Debug, Clone, PartialEq)]
pub enum Status {
    Idle,
    Working,
    Attention(AttentionType),
    Compacting,
}

impl Status {
    /// Parse status from string
    pub fn from_str(status: &str, attention_type: Option<&str>) -> Self {
        match status {
            "working" => Status::Working,
            "attention" => {
                let attn = attention_type
                    .map(AttentionType::from_str)
                    .unwrap_or(AttentionType::Input);
                Status::Attention(attn)
            }
            "compacting" => Status::Compacting,
            _ => Status::Idle,
        }
    }

    /// Priority for sorting (lower = higher priority)
    pub fn priority(&self) -> u8 {
        match self {
            Status::Attention(_) => 0,
            Status::Compacting => 1,
            Status::Working => 2,
            Status::Idle => 3,
        }
    }
}

/// Type of attention needed
#[derive(Debug, Clone, PartialEq)]
pub enum AttentionType {
    Permission,
    Input,
}

impl AttentionType {
    pub fn from_str(s: &str) -> Self {
        match s {
            "permission" => AttentionType::Permission,
            _ => AttentionType::Input,
        }
    }
}

/// Agent state
#[derive(Debug, Clone)]
pub struct Agent {
    pub pane_id: String,
    pub project: String,
    pub status: Status,
    pub start_time: i64,
    pub last_update: i64,
    pub last_event: String,
    pub activity: VecDeque<f64>,
}

impl Agent {
    pub fn new(pane_id: String, project: String) -> Self {
        Self {
            pane_id,
            project,
            status: Status::Idle,
            start_time: 0,
            last_update: 0,
            last_event: String::new(),
            activity: VecDeque::with_capacity(60),
        }
    }

    /// Calculate elapsed time since start
    pub fn elapsed_secs(&self) -> i64 {
        if self.start_time == 0 {
            return 0;
        }
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_secs() as i64)
            .unwrap_or(0);
        now - self.start_time
    }

    /// Format elapsed time for display
    pub fn elapsed_display(&self) -> String {
        let secs = self.elapsed_secs();
        if secs == 0 {
            return "--".to_string();
        }
        if secs < 60 {
            format!("{}s", secs)
        } else if secs < 3600 {
            format!("{}m {:02}s", secs / 60, secs % 60)
        } else {
            format!("{}h {:02}m", secs / 3600, (secs % 3600) / 60)
        }
    }
}
