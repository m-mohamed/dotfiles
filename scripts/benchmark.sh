#!/usr/bin/env bash
# Benchmark ZSH startup performance

set -euo pipefail

RUNS=10
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# Check if bc is installed (required for calculations)
if ! command -v bc &>/dev/null; then
  echo -e "${RED}ERROR: bc (basic calculator) is not installed${NC}" >&2
  echo "Install with: brew install bc" >&2
  exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  ZSH Startup Performance Benchmark${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Running ${BOLD}$RUNS${NC} iterations..."
echo ""

times=()
for i in $(seq 1 $RUNS); do
  # Measure time in seconds using /usr/bin/time
  time_output=$( { /usr/bin/time -p zsh -i -c exit 2>&1; } )
  time_seconds=$(echo "$time_output" | grep real | awk '{print $2}')

  # Validate time parsing succeeded
  if [[ -z "$time_seconds" ]]; then
    echo -e "${RED}ERROR: Failed to parse time output${NC}" >&2
    echo "Time output was: $time_output" >&2
    exit 1
  fi

  # Convert to milliseconds
  time_ms=$(echo "$time_seconds * 1000" | bc)

  # Validate conversion succeeded
  if [[ -z "$time_ms" ]] || [[ "$time_ms" == "0" ]]; then
    echo -e "${RED}ERROR: Time conversion failed${NC}" >&2
    echo "Got seconds: $time_seconds, converted to: $time_ms" >&2
    exit 1
  fi

  times+=($time_ms)
  printf "Run %2d: %6.2fms\n" "$i" "$time_ms"
done

# Calculate average
total=0
for time in "${times[@]}"; do
  total=$(echo "$total + $time" | bc)
done
avg=$(echo "scale=2; $total / $RUNS" | bc)

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Average startup time: ${BOLD}${avg}ms${NC}"

# Thresholds and exit codes
if (( $(echo "$avg < 100" | bc -l) )); then
  echo -e "Status: ${GREEN}✓ EXCELLENT${NC} (<100ms target)"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 0
elif (( $(echo "$avg < 200" | bc -l) )); then
  echo -e "Status: ${YELLOW}⚠ GOOD${NC} (but could be faster)"
  echo ""
  echo "Tips to improve:"
  echo "  • Check for new plugins in .zsh_plugins.txt"
  echo "  • Add 'zmodload zsh/zprof' to top of ~/.config/zsh/.zshrc, then run 'zsh -i -c zprof'"
  echo "  • Ensure completion cache exists: ls ~/.cache/zsh/.zcompdump"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 0
else
  echo -e "Status: ${RED}✗ SLOW${NC} (investigate with zprof)"
  echo ""
  echo "Diagnostic commands:"
  echo "  • Profile startup: Add 'zmodload zsh/zprof' to top of ~/.config/zsh/.zshrc, then run 'zsh -i -c zprof'"
  echo "  • Clear completions: rm ~/.cache/zsh/.zcompdump* && exec zsh"
  echo "  • Force plugin rebuild: rm ~/.config/zsh/.zsh_plugins.zsh && exec zsh"
  echo "  • Check for slow modules: time each module individually"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 1
fi
