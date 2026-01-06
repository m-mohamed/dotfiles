use crate::app::App;
use crate::config::colors;
use crate::state::Status;
use ratatui::{
    layout::{Constraint, Direction, Layout, Rect},
    prelude::*,
    style::{Modifier, Style},
    widgets::{
        Block, Borders, Cell, List, ListItem, Paragraph, Row, Sparkline, Table,
    },
    Frame,
};

/// Main render function
pub fn render(f: &mut Frame, app: &App) {
    // Create layout
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(3),  // Header
            Constraint::Min(8),     // Agent list
            Constraint::Length(8),  // Activity sparklines
            Constraint::Length(1),  // Footer
        ])
        .split(f.area());

    render_header(f, chunks[0]);
    render_agent_list(f, chunks[1], app);
    render_activity(f, chunks[2], app);
    render_footer(f, chunks[3], app);

    // Render event log if in debug mode
    if app.debug_mode && !app.state.events.is_empty() {
        render_event_log(f, app);
    }

    // Render help popup if active
    if app.show_help {
        render_help(f);
    }
}

fn render_header(f: &mut Frame, area: Rect) {
    let header = Paragraph::new("Claude Observer")
        .style(Style::default().fg(colors::FG).add_modifier(Modifier::BOLD))
        .alignment(Alignment::Center)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .border_style(Style::default().fg(colors::BORDER))
                .border_type(ratatui::widgets::BorderType::Rounded),
        );
    f.render_widget(header, area);
}

fn render_agent_list(f: &mut Frame, area: Rect, app: &App) {
    let agents = app.state.sorted_agents();

    if agents.is_empty() {
        let empty = Paragraph::new("No agents connected. Waiting for hook events...")
            .style(Style::default().fg(colors::IDLE))
            .alignment(Alignment::Center)
            .block(
                Block::default()
                    .title(" Agents ")
                    .borders(Borders::ALL)
                    .border_style(Style::default().fg(colors::BORDER))
                    .border_type(ratatui::widgets::BorderType::Rounded),
            );
        f.render_widget(empty, area);
        return;
    }

    // Create table rows
    let rows: Vec<Row> = agents
        .iter()
        .enumerate()
        .map(|(i, agent)| {
            let is_selected = i == app.state.selected;
            let style = if is_selected {
                Style::default()
                    .fg(colors::HIGHLIGHT)
                    .add_modifier(Modifier::BOLD)
            } else {
                Style::default().fg(colors::FG)
            };

            let status_style = status_color(&agent.status);
            let status_bar = status_progress_bar(&agent.status);
            let selector = if is_selected { "▸" } else { " " };

            Row::new(vec![
                Cell::from(selector).style(style),
                Cell::from(status_bar).style(status_style),
                Cell::from(agent.project.clone()).style(style),
                Cell::from(agent.elapsed_display()).style(style),
            ])
            .height(1)
        })
        .collect();

    let widths = [
        Constraint::Length(2),
        Constraint::Length(12),
        Constraint::Fill(1),
        Constraint::Length(10),
    ];

    let table = Table::new(rows, widths)
        .header(
            Row::new(vec!["", "STATUS", "PROJECT", "ELAPSED"])
                .style(Style::default().fg(colors::IDLE).add_modifier(Modifier::DIM))
                .bottom_margin(1),
        )
        .block(
            Block::default()
                .title(" Agents ")
                .borders(Borders::ALL)
                .border_style(Style::default().fg(colors::BORDER))
                .border_type(ratatui::widgets::BorderType::Rounded),
        );

    f.render_widget(table, area);
}

fn render_activity(f: &mut Frame, area: Rect, app: &App) {
    let agents = app.state.sorted_agents();

    // Create horizontal layout for sparklines
    let num_agents = agents.len().max(1);
    let constraints: Vec<Constraint> = (0..num_agents)
        .map(|_| Constraint::Ratio(1, num_agents as u32))
        .collect();

    let chunks = Layout::default()
        .direction(Direction::Horizontal)
        .constraints(constraints)
        .split(area);

    for (i, agent) in agents.iter().enumerate() {
        if i >= chunks.len() {
            break;
        }

        let data: Vec<u64> = agent
            .activity
            .iter()
            .map(|v| (v * 8.0) as u64)
            .collect();

        let sparkline = Sparkline::default()
            .data(&data)
            .style(status_color(&agent.status))
            .block(
                Block::default()
                    .title(format!(" {} ", truncate(&agent.project, 12)))
                    .borders(Borders::ALL)
                    .border_style(Style::default().fg(colors::BORDER))
                    .border_type(ratatui::widgets::BorderType::Rounded),
            );

        f.render_widget(sparkline, chunks[i]);
    }

    // Show placeholder if no agents
    if agents.is_empty() {
        let placeholder = Block::default()
            .title(" Activity ")
            .borders(Borders::ALL)
            .border_style(Style::default().fg(colors::BORDER))
            .border_type(ratatui::widgets::BorderType::Rounded);
        f.render_widget(placeholder, area);
    }
}

fn render_footer(f: &mut Frame, area: Rect, app: &App) {
    let mode = if app.debug_mode { "[debug] " } else { "" };
    let help = format!(
        "{}q:quit  j/k:nav  Enter:jump  d:debug  ?:help",
        mode
    );

    let footer = Paragraph::new(help)
        .style(Style::default().fg(colors::IDLE))
        .alignment(Alignment::Center);

    f.render_widget(footer, area);
}

fn render_event_log(f: &mut Frame, app: &App) {
    let area = centered_rect(60, 50, f.area());

    let items: Vec<ListItem> = app
        .state
        .events
        .iter()
        .take(15)
        .map(|event| {
            let line = format!(
                "{} │ {:12} │ {:15} │ {}",
                format_timestamp(event.timestamp),
                event.event,
                truncate(&event.project, 15),
                event.status
            );
            ListItem::new(line).style(Style::default().fg(colors::FG))
        })
        .collect();

    let list = List::new(items).block(
        Block::default()
            .title(" Event Log ")
            .borders(Borders::ALL)
            .border_style(Style::default().fg(colors::BORDER))
            .border_type(ratatui::widgets::BorderType::Rounded)
            .style(Style::default().bg(colors::BG)),
    );

    f.render_widget(ratatui::widgets::Clear, area);
    f.render_widget(list, area);
}

fn render_help(f: &mut Frame) {
    let area = centered_rect(40, 40, f.area());

    let help_text = r#"
  Keybindings

  q, Esc      Quit
  j, ↓        Next agent
  k, ↑        Previous agent
  Enter       Jump to agent
  d           Toggle debug mode
  ?, h        Toggle this help
"#;

    let help = Paragraph::new(help_text)
        .style(Style::default().fg(colors::FG))
        .block(
            Block::default()
                .title(" Help ")
                .borders(Borders::ALL)
                .border_style(Style::default().fg(colors::HIGHLIGHT))
                .border_type(ratatui::widgets::BorderType::Rounded)
                .style(Style::default().bg(colors::BG)),
        );

    f.render_widget(ratatui::widgets::Clear, area);
    f.render_widget(help, area);
}

// Helper functions

fn status_color(status: &Status) -> Style {
    let color = match status {
        Status::Working => colors::WORKING,
        Status::Attention(_) => colors::ATTENTION,
        Status::Compacting => colors::COMPACTING,
        Status::Idle => colors::IDLE,
    };
    Style::default().fg(color)
}

fn status_progress_bar(status: &Status) -> String {
    let (filled, total) = match status {
        Status::Working => (10, 10),
        Status::Attention(_) => (8, 10),
        Status::Compacting => (6, 10),
        Status::Idle => (0, 10),
    };

    let filled_char = "▓";
    let empty_char = "░";

    format!(
        "{}{}",
        filled_char.repeat(filled),
        empty_char.repeat(total - filled)
    )
}

fn truncate(s: &str, max_len: usize) -> String {
    if s.len() <= max_len {
        s.to_string()
    } else {
        format!("{}…", &s[..max_len - 1])
    }
}

fn format_timestamp(ts: i64) -> String {
    use std::time::{Duration, UNIX_EPOCH};
    let datetime = UNIX_EPOCH + Duration::from_secs(ts as u64);
    let now = std::time::SystemTime::now();

    // Simple HH:MM:SS format
    if let Ok(duration) = now.duration_since(datetime) {
        let secs = duration.as_secs();
        let hours = (secs / 3600) % 24;
        let mins = (secs / 60) % 60;
        let secs = secs % 60;
        format!("{:02}:{:02}:{:02}", hours, mins, secs)
    } else {
        "??:??:??".to_string()
    }
}

fn centered_rect(percent_x: u16, percent_y: u16, r: Rect) -> Rect {
    let popup_layout = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Percentage((100 - percent_y) / 2),
            Constraint::Percentage(percent_y),
            Constraint::Percentage((100 - percent_y) / 2),
        ])
        .split(r);

    Layout::default()
        .direction(Direction::Horizontal)
        .constraints([
            Constraint::Percentage((100 - percent_x) / 2),
            Constraint::Percentage(percent_x),
            Constraint::Percentage((100 - percent_x) / 2),
        ])
        .split(popup_layout[1])[1]
}
