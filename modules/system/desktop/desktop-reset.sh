# desktop-reset: move personal desktop settings aside so the desktop starts
# from defaults. Application settings (Dolphin, Kate, Konsole, editors, ...)
# are kept. Without --apply nothing is changed.

usage() {
  cat <<'EOF'
Usage: desktop-reset [--apply] [--force] TARGET...

Reset personal desktop settings. Without --apply, only show what would change.
Files are moved to a backup folder, never deleted.

Targets:
  kde     Plasma shell, KWin, shortcuts, input, power, session, caches
  gtk     GTK 2/3/4 theme settings (keeps GTK file chooser bookmarks)
  gnome   GNOME settings in dconf (/org/gnome/, /org/gtk/) and GNOME shell files
  niri    niri, Noctalia and fuzzel settings and caches
  themes  user-installed themes, icons, cursors, color schemes, wallpapers
  all     all of the above

Options:
  --apply   make the changes
  --force   apply even when the desktop of a target is running
  -h        show this help

Never touched: KWallet and GNOME keyring data, files managed by Home Manager,
application settings, mimeapps.list, autostart entries.
EOF
}

paths_for() {
  case "$1" in
    kde)
      printf '%s\n' \
        .config/baloofilerc \
        .config/bluedevilglobalrc \
        .config/breezerc \
        .config/kaccessrc \
        .config/kactivitymanagerd-pluginsrc \
        .config/kactivitymanagerd-statsrc \
        .config/kactivitymanagerdrc \
        .config/kcminputrc \
        .config/kconf_updaterc \
        .config/kded5rc \
        .config/kded6rc \
        .config/kdedefaults \
        .config/kdeglobals \
        .config/KDE \
        .config/kglobalshortcutsrc \
        .config/khotkeysrc \
        .config/kiorc \
        .config/klipperrc \
        .config/krunnerrc \
        .config/kscreenlockerrc \
        .config/ksmserverrc \
        .config/ksplashrc \
        .config/ktimezonedrc \
        .config/kuriikwsfilterrc \
        .config/kwinoutputconfig.json \
        .config/kwinrc \
        .config/kwinrulesrc \
        .config/kxkbrc \
        .config/menus \
        '.config/plasma*' \
        .config/powerdevilrc \
        .config/powermanagementprofilesrc \
        .config/QtProject.conf \
        .config/session \
        .config/systemsettingsrc \
        .config/Trolltech.conf \
        .local/share/baloo \
        .local/share/kactivitymanagerd \
        .local/share/kded6 \
        .local/share/klipper \
        .local/share/krunnerstaterc \
        .local/share/kscreen \
        .local/share/kwin \
        .local/share/plasma \
        .local/share/plasma-manager \
        .local/share/plasmashell \
        .local/share/sddm \
        .local/state/kactivitymanagerdstaterc \
        .local/state/kickerstaterc \
        .local/state/knighttimestaterc \
        .local/state/plasmashellstaterc \
        .local/state/systemsettingsstaterc \
        .local/state/UserFeedback.org.kde.plasmashell \
        .local/state/xdg-desktop-portal-kdestaterc \
        .cache/icon-cache.kcache \
        .cache/kcmshell6 \
        .cache/kcrash-metadata \
        .cache/krunner \
        .cache/kscreen_osd_service \
        .cache/kscreenlocker_greet \
        .cache/ksmserver-logout-greeter \
        .cache/ksplash \
        '.cache/ksvg-elements*' \
        '.cache/ksycoca6_*' \
        .cache/kwin \
        '.cache/plasma*' \
        '.cache/qtshadercache-*' \
        .cache/systemsettings
      ;;
    gtk)
      printf '%s\n' \
        .gtkrc-2.0 \
        .config/gtk-2.0 \
        .config/gtk-3.0/assets \
        .config/gtk-3.0/colors.css \
        .config/gtk-3.0/gtk.css \
        .config/gtk-3.0/settings.ini \
        .config/gtk-3.0/window_decorations.css \
        .config/gtk-4.0/assets \
        .config/gtk-4.0/colors.css \
        .config/gtk-4.0/gtk.css \
        .config/gtk-4.0/settings.ini \
        .config/gtk-4.0/window_decorations.css \
        .config/gtkrc \
        .config/gtkrc-2.0 \
        .config/xsettingsd
      ;;
    gnome)
      printf '%s\n' \
        .config/.gsd-keyboard.settings-ported \
        .config/gnome-initial-setup-done \
        .config/gnome-session \
        .config/monitors.xml \
        .config/monitors.xml~ \
        .config/nautilus \
        .local/share/backgrounds \
        .local/share/gnome-settings-daemon \
        .local/share/gnome-shell \
        .local/share/gnome-software \
        .local/share/nautilus \
        '.local/state/gnome-session@*' \
        .local/state/gnome-software \
        .cache/gnome-desktop-thumbnailer \
        .cache/gnome-software \
        .cache/libgweather \
        .cache/tracker3
      ;;
    niri)
      printf '%s\n' \
        .config/fuzzel \
        .config/niri \
        .config/noctalia \
        .local/state/noctalia \
        .cache/fuzzel \
        .cache/noctalia
      ;;
    themes)
      printf '%s\n' \
        .icons \
        .themes \
        .local/share/aurorae \
        .local/share/color-schemes \
        .local/share/icons \
        .local/share/themes \
        .local/share/wallpapers
      ;;
  esac
}

# Processes that show a target's desktop is running.
session_procs_for() {
  case "$1" in
    kde) echo "plasmashell kwin_wayland kwin_x11" ;;
    gnome) echo "gnome-shell" ;;
    niri) echo "niri" ;;
  esac
}

dconf_dirs=(/org/gnome/ /org/gtk/)

apply=false
force=false
targets=()

while [ $# -gt 0 ]; do
  case "$1" in
    --apply) apply=true ;;
    --force) force=true ;;
    -h | --help)
      usage
      exit 0
      ;;
    all) targets+=(kde gtk gnome niri themes) ;;
    kde | gtk | gnome | niri | themes) targets+=("$1") ;;
    *)
      echo "desktop-reset: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [ ${#targets[@]} -eq 0 ]; then
  usage >&2
  exit 2
fi

# Remove duplicate targets, keep order.
declare -A seen=()
unique=()
for t in "${targets[@]}"; do
  if [ -z "${seen[$t]:-}" ]; then
    seen[$t]=1
    unique+=("$t")
  fi
done
targets=("${unique[@]}")

is_hm_managed() {
  local path=$1
  if [ -L "$path" ]; then
    [[ "$(readlink "$path")" == /nix/store/* ]]
    return
  fi
  [ -d "$path" ] && [ -n "$(find "$path" -lname '/nix/store/*' -print -quit 2>/dev/null)" ]
}

shopt -s nullglob dotglob

items=()
declare -A item_target=()
for t in "${targets[@]}"; do
  while IFS= read -r pattern; do
    # Patterns are relative to $HOME and may hold a glob.
    # shellcheck disable=SC2206
    matches=("$HOME"/$pattern)
    for path in "${matches[@]}"; do
      [ -e "$path" ] || [ -L "$path" ] || continue
      if is_hm_managed "$path"; then
        echo "skip  [$t] ${path#"$HOME"/} (managed by Home Manager)"
        continue
      fi
      items+=("$path")
      item_target[$path]=$t
    done
  done < <(paths_for "$t")
done

dconf_resets=()
if [[ " ${targets[*]} " == *" gnome "* ]] && command -v dconf >/dev/null; then
  for dir in "${dconf_dirs[@]}"; do
    keys=$(dconf dump "$dir" 2>/dev/null | grep -c '=' || true)
    if [ "${keys:-0}" -gt 0 ]; then
      dconf_resets+=("$dir")
      echo "reset [gnome] dconf $dir ($keys keys)"
    fi
  done
fi

for path in "${items[@]}"; do
  size=$(du -sh "$path" 2>/dev/null | cut -f1)
  echo "move  [${item_target[$path]}] ${path#"$HOME"/} ($size)"
done

if [ ${#items[@]} -eq 0 ] && [ ${#dconf_resets[@]} -eq 0 ]; then
  echo "Nothing to reset for: ${targets[*]}"
  exit 0
fi

if [ "$apply" != true ]; then
  echo
  echo "Dry run: nothing changed. Run again with --apply to make these changes."
  exit 0
fi

if [ "$force" != true ]; then
  running=()
  for t in "${targets[@]}"; do
    for proc in $(session_procs_for "$t"); do
      # Match the program path: on NixOS the process name is a wrapper
      # (e.g. ".plasmashell-wr"), so an exact name match finds nothing.
      if pgrep -u "$(id -u)" -f "(^|/)$proc( |\$)" >/dev/null; then
        running+=("$t ($proc)")
      fi
    done
  done
  if [ ${#running[@]} -gt 0 ]; then
    echo >&2
    echo "desktop-reset: a desktop session is running: ${running[*]}" >&2
    echo "It would write its settings back on logout. Log out, switch to a text" >&2
    echo "console (Ctrl+Alt+F3), log in there and run this again." >&2
    echo "Use --force to apply anyway." >&2
    exit 1
  fi
fi

backup="${XDG_STATE_HOME:-$HOME/.local/state}/desktop-reset/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup"

for dir in "${dconf_resets[@]}"; do
  mkdir -p "$backup/dconf"
  dconf dump "$dir" >"$backup/dconf/$(echo "$dir" | tr -d '/').ini"
  dconf reset -f "$dir"
done

for path in "${items[@]}"; do
  dest="$backup/files/${path#"$HOME"/}"
  mkdir -p "$(dirname "$dest")"
  mv "$path" "$dest"
done

echo
echo "Done. Backup: $backup"
if [ ${#items[@]} -gt 0 ]; then
  echo "Restore files: cp -a '$backup/files/.' ~/"
fi
for dir in "${dconf_resets[@]}"; do
  echo "Restore dconf: dconf load $dir < '$backup/dconf/$(echo "$dir" | tr -d '/').ini'"
done
echo "Log in again to start with the default settings."
