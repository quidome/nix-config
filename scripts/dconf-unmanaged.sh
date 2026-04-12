#!/usr/bin/env bash
# Show live dconf keys that are not managed by home-manager.
# Usage: ./scripts/dconf-unmanaged.sh [hostname] [username]

set -euo pipefail

HOST="${1:-$(hostname)}"
USER="${2:-$(whoami)}"
FLAKE_DIR="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

# Paths that are transient app state, not worth managing declaratively
EXCLUDE_PATTERNS=(
  "ca/desrt/dconf-editor"
  "org/freedesktop"
  "org/gnome/baobab"
  "org/gnome/boxes"
  "org/gnome/builder"
  "org/gnome/calculator"
  "org/gnome/calendar"
  "org/gnome/characters"
  "org/gnome/clocks"
  "org/gnome/Console/last-window"         # window state
  "org/gnome/contacts"
  "org/gnome/control-center"
  "org/gnome/desktop/a11y"               # accessibility toggles (runtime)
  "org/gnome/desktop/app-folders"
  "org/gnome/desktop/notifications/application"
  "org/gnome/epiphany"
  "org/gnome/evolution"
  "org/gnome/Geary"                       # mail client state
  "org/gnome/gedit"
  "org/gnome/maps"
  "org/gnome/mutter/experimental-features"
  "org/gnome/nautilus"
  "org/gnome/nm-applet"
  "org/gnome/photos"
  "org/gnome/rhythmbox"
  "org/gnome/settings-daemon/plugins/housekeeping" # donation/cleanup reminders
  "org/gnome/shell/app-picker-layout"     # app grid ordering
  "org/gnome/shell/extensions"
  "org/gnome/shell/favorite-apps"
  "org/gnome/shell/last-selected-power-profile"
  "org/gnome/shell/weather"
  "org/gnome/shell/welcome-dialog"        # one-time welcome dialog
  "org/gnome/shell/world-clocks"
  "org/gnome/software"
  "org/gnome/system-monitor"
  "org/gnome/terminal"
  "org/gnome/todo"
  "org/gnome/totem"
  "org/gtk"
  "system/locale"
)

echo "Host:  $HOST"
echo "User:  $USER"
echo "Flake: $FLAKE_DIR"
echo

# --- Get nix-managed dconf keys as flat list of "section/key" ---
echo "Evaluating home-manager dconf config from flake..." >&2
MANAGED=$(
  nix eval --json \
    "${FLAKE_DIR}#nixosConfigurations.${HOST}.config.home-manager.users.${USER}.dconf.settings" \
    2>/dev/null \
  | jq -r '
      to_entries[]
      | . as $sec
      | .value | to_entries[]
      | $sec.key + "/" + .key
    ' \
  | sort
)

if [[ -z "$MANAGED" ]]; then
  echo "Warning: no home-manager dconf settings found for ${HOST}/${USER}" >&2
fi

# --- Get live dconf, convert to "section/key" ---
LIVE=$(
  dconf dump / \
  | awk '
      /^\[/ { section = substr($0, 2, length($0)-2) }
      /^[a-zA-Z]/ && section != "" {
        idx = index($0, "=")
        if (idx > 0) print section "/" substr($0, 1, idx-1)
      }
    ' \
  | sort
)

# --- Build exclude regex ---
EXCLUDE_RE=$(printf '%s\n' "${EXCLUDE_PATTERNS[@]}" | paste -sd '|')

LIVE_FILTERED=$(echo "$LIVE" | grep -Ev "^(${EXCLUDE_RE})" || true)

# --- Diff ---
UNMANAGED=$(comm -23 \
  <(echo "$LIVE_FILTERED") \
  <(echo "$MANAGED") \
)

if [[ -z "$UNMANAGED" ]]; then
  echo "All live dconf keys are managed by home-manager."
  exit 0
fi

COUNT=$(echo "$UNMANAGED" | wc -l)
echo "Found ${COUNT} unmanaged dconf key(s):"
echo

while IFS= read -r path; do
  section=$(dirname "$path")
  key=$(basename "$path")
  value=$(dconf read "/${section}/${key}" 2>/dev/null || echo "(unreadable)")
  printf "  /%-68s = %s\n" "${path}" "${value}"
done <<< "$UNMANAGED"
