mod agent;

pub use agent::{Agent, Status};

use crate::config::{MAX_EVENTS, MAX_SPARKLINE_POINTS};
use crate::event::HookEvent;
use std::collections::{HashMap, VecDeque};
use std::time::{SystemTime, UNIX_EPOCH};

/// Application state
#[derive(Debug, Default)]
pub struct AppState {
    /// Active agents indexed by pane_id
    pub agents: HashMap<String, Agent>,
    /// Recent events for the event log
    pub events: VecDeque<HookEvent>,
    /// Currently selected agent index
    pub selected: usize,
}

impl AppState {
    pub fn new() -> Self {
        Self::default()
    }

    /// Process a hook event and update state
    pub fn process_event(&mut self, event: HookEvent) {
        let pane_id = event.pane_id.clone();

        // Update or create agent
        let agent = self.agents.entry(pane_id.clone()).or_insert_with(|| {
            Agent::new(pane_id.clone(), event.project.clone())
        });

        // Update agent state
        agent.project = event.project.clone();
        agent.status = Status::from_str(&event.status, event.attention_type.as_deref());
        agent.last_event = event.event.clone();
        agent.last_update = current_timestamp();

        // Add activity point for sparkline
        let activity_value = match &agent.status {
            Status::Working => 1.0,
            Status::Attention(_) => 0.8,
            Status::Compacting => 0.6,
            Status::Idle => 0.1,
        };
        agent.activity.push_back(activity_value);
        if agent.activity.len() > MAX_SPARKLINE_POINTS {
            agent.activity.pop_front();
        }

        // Handle session end - remove agent
        if event.event == "SessionEnd" {
            self.agents.remove(&pane_id);
        }

        // Add to event log
        self.events.push_front(event);
        if self.events.len() > MAX_EVENTS {
            self.events.pop_back();
        }
    }

    /// Get sorted list of agents (attention first, then working, then idle)
    pub fn sorted_agents(&self) -> Vec<&Agent> {
        let mut agents: Vec<&Agent> = self.agents.values().collect();
        agents.sort_by(|a, b| a.status.priority().cmp(&b.status.priority()));
        agents
    }

    /// Navigate to next agent
    pub fn next(&mut self) {
        let len = self.agents.len();
        if len > 0 {
            self.selected = (self.selected + 1) % len;
        }
    }

    /// Navigate to previous agent
    pub fn previous(&mut self) {
        let len = self.agents.len();
        if len > 0 {
            self.selected = self.selected.saturating_sub(1);
            if self.selected == 0 && len > 0 {
                self.selected = len - 1;
            }
        }
    }

    /// Get currently selected agent
    pub fn selected_agent(&self) -> Option<&Agent> {
        self.sorted_agents().get(self.selected).copied()
    }
}

fn current_timestamp() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs() as i64)
        .unwrap_or(0)
}
