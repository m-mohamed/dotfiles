# Claude Observer

Real-time observability TUI for Claude Code instances.

![claude-observer](./docs/screenshot.png)

## Features

- **Real-time monitoring** - Watch all Claude Code instances in one view
- **Activity sparklines** - See activity patterns over time
- **Event log** - Debug mode shows recent hook events
- **Jump to agent** - Press Enter to switch to selected agent's terminal
- **Tokyo Night theme** - Beautiful dark mode color scheme

## Architecture

```
Claude Code Hooks → Unix Socket → Rust Daemon → Beautiful TUI
```

Direct socket communication means instant updates with no file watching overhead.

## Installation

### Prerequisites

1. **Rust** - Install via [rustup](https://rustup.rs):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **WezTerm** - For agent navigation features

### Build

```bash
cd ~/dotfiles/claude-observer
cargo build --release
```

### Install binary

```bash
cp target/release/claude-observer ~/.local/bin/
```

## Usage

### Start the observer

```bash
claude-observer
```

### CLI Options

```
claude-observer --help

Options:
  -s, --socket <SOCKET>      Socket path [env: CLAUDE_OBSERVER_SOCKET] [default: /tmp/claude-observer.sock]
  -l, --log-level <LEVEL>    Log level [env: RUST_LOG] [default: info]
  -d, --debug                Run in debug mode (shows event log)
  -h, --help                 Print help
  -V, --version              Print version
```

### Keybindings

| Key | Action |
|-----|--------|
| `q`, `Esc` | Quit |
| `j`, `↓` | Next agent |
| `k`, `↑` | Previous agent |
| `Enter` | Jump to agent |
| `d` | Toggle debug mode |
| `?`, `h` | Toggle help |

## Configure Hooks

Update your Claude Code hooks to use the socket-based sender:

```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "~/dotfiles/claude-observer/scripts/send-event.sh working '' UserPromptSubmit"
      }]
    }],
    "Stop": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "~/dotfiles/claude-observer/scripts/send-event.sh idle '' Stop"
      }]
    }]
  }
}
```

See `scripts/send-event.sh` for the full implementation.

## Development

```bash
# Run in development mode
cargo run

# Run with debug logging
RUST_LOG=debug cargo run

# Run tests
cargo test

# Format code
cargo fmt

# Check for issues
cargo clippy
```

## License

MIT
