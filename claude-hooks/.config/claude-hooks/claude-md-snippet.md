
<!-- BEGIN SHARED: Modern CLI Tools -->
## Modern CLI Tools

This environment uses modern Rust/Go CLI tools. **Always prefer these over legacy commands.**

### File Operations
| Task | Use this | NOT this |
|------|----------|----------|
| List files | `eza --icons --git` | `ls` |
| Tree view | `eza --tree --level=2` | `tree` |
| Read files | `bat` or Read tool | `cat` |
| Find files | `fd <pattern>` | `find` |
| Disk usage | `dust` | `du` |

### Search & Text
| Task | Use this | NOT this |
|------|----------|----------|
| Search content | `rg <pattern>` | `grep` |
| JSON processing | `jq` | manual parsing |

### Git & Dev
| Task | Use this | NOT this |
|------|----------|----------|
| Git diffs | `delta` (auto via git) | `diff` |
| Code stats | `tokei` | `cloc`, `wc -l` |
| Benchmarks | `hyperfine '<cmd>'` | `time` |

### System Info
| Task | Use this | NOT this |
|------|----------|----------|
| Process list | `procs` | `ps` |
| Man pages | `tldr <cmd>` | `man` |

### DO NOT use
- `z` or `zoxide` — shell function, broken in Claude Code
- `cd` with relative paths — use absolute paths
- Aliases — not loaded in Bash tool
- `fzf` — interactive, requires human input
- `lazygit`, `lazydocker`, `btop` — TUI tools for humans, use `git`/`docker`/`procs` instead
- `nvm`, `fnm` — use Bun instead

### Useful Patterns
```bash
# Search with context
rg "pattern" -C 3

# Disk usage of current dir
dust -d 1

# Find processes by name
procs claude

# Benchmark a command
hyperfine 'fd -e rs' 'find . -name "*.rs"'

# Code statistics
tokei --sort code

# Pretty JSON
echo '{"key":"value"}' | jq .
```
<!-- END SHARED: Modern CLI Tools -->
