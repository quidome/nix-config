{
  lib,
  pkgs,
}: let
  cleanupPackage = pkgs.writeShellApplication {
    name = "hypr-display-cleanup";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
      jq
      libnotify
    ];
    text = ''
      set -euo pipefail

      notify() {
        notify-send "Display cleanup" "$1"
      }

      monitors_json=""
      for _ in $(seq 1 15); do
        if monitors_json=$(hyprctl -j monitors 2>/dev/null); then
          if [ "$(printf '%s' "$monitors_json" | jq 'map(select(.name != null)) | length')" -gt 0 ]; then
            break
          fi
        fi
        sleep 0.2
      done

      if [ -z "$monitors_json" ] || [ "$(printf '%s' "$monitors_json" | jq 'map(select(.name != null)) | length')" -eq 0 ]; then
        notify "Failed: no active monitor"
        exit 1
      fi

      mapfile -t active_monitors < <(printf '%s' "$monitors_json" | jq -r 'map(select(.name != null) | .name) | .[]')
      fallback_monitor="''${active_monitors[0]}"

      if [ -z "$fallback_monitor" ]; then
        notify "Failed: no active monitor"
        exit 1
      fi

      declare -A active_monitor_map=()
      for monitor in "''${active_monitors[@]}"; do
        active_monitor_map["$monitor"]=1
      done

      if ! workspaces_json=$(hyprctl -j workspaces 2>/dev/null); then
        notify "Failed while reading Hyprland workspaces"
        exit 1
      fi

      moved=()
      while IFS=$'\t' read -r ws_name ws_monitor; do
        [ -n "$ws_name" ] || continue
        if [ -z "''${active_monitor_map[$ws_monitor]:-}" ]; then
          hyprctl dispatch moveworkspacetomonitor "$ws_name" "$fallback_monitor" >/dev/null
          moved+=("$ws_name")
        fi
      done < <(
        printf '%s' "$workspaces_json" | jq -r '
          .[]
          | select((.id // 0) > 0 and ((.name // "") | startswith("special:") | not))
          | [(.name // (.id | tostring)), (.monitor // "")]
          | @tsv
        '
      )

      moved_count="''${#moved[@]}"
      if [ "$moved_count" -eq 0 ]; then
        exit 0
      fi

      if [ "$moved_count" -le 4 ]; then
        joined=$(printf ', %s' "''${moved[@]}")
        joined="''${joined#, }"
        notify "Moved workspaces $joined to $fallback_monitor"
      else
        notify "Moved $moved_count workspaces to $fallback_monitor"
      fi
    '';
  };

  profilePackage = pkgs.writeShellApplication {
    name = "hypr-display-profile";
    runtimeInputs = with pkgs; [
      coreutils
      fuzzel
      gawk
      gnugrep
      jq
      kanshi
      libnotify
    ];
    text = ''
      set -euo pipefail

      config_file="$HOME/.config/kanshi/config"

      notify() {
        notify-send "Display profile" "$1"
      }

      read_profiles() {
        awk '/^profile[[:space:]]+/ {
          name = $2
          sub(/[[:space:]]*\{.*/, "", name)
          print name
        }' "$config_file"
      }

      ensure_config() {
        if [ ! -f "$config_file" ]; then
          notify "No kanshi config found"
          exit 1
        fi
      }

      choose_profile() {
        local current_profile selection
        current_profile=$(kanshictl status 2>/dev/null | jq -r '.current_profile // empty' || true)
        selection=$(read_profiles | fuzzel --dmenu --prompt "Display profile> " --select="$current_profile") || exit 0
        [ -n "$selection" ] || exit 0
        switch_profile "$selection"
      }

      next_profile() {
        mapfile -t profiles < <(read_profiles)
        if [ "''${#profiles[@]}" -eq 0 ]; then
          notify "No display profiles available"
          exit 1
        fi

        current="$(kanshictl status 2>/dev/null | jq -r '.current_profile // empty' || true)"
        next_index=0

        if [ -n "$current" ]; then
          for i in "''${!profiles[@]}"; do
            if [ "''${profiles[$i]}" = "$current" ]; then
              next_index=$(((i + 1) % ''${#profiles[@]}))
              break
            fi
          done
        fi

        switch_profile "''${profiles[$next_index]}"
      }

      switch_profile() {
        local profile="$1"
        notify "Switching display profile: $profile"
        if ! kanshictl switch "$profile"; then
          notify "Failed to switch display profile: $profile"
          exit 1
        fi
      }

      ensure_config

      case "''${1:-}" in
        choose)
          choose_profile
          ;;
        next)
          next_profile
          ;;
        switch)
          if [ "''${2:-}" = "" ]; then
            echo "usage: hypr-display-profile switch <profile>" >&2
            exit 1
          fi
          switch_profile "$2"
          ;;
        *)
          echo "usage: hypr-display-profile {choose|next|switch <profile>}" >&2
          exit 1
          ;;
      esac
    '';
  };
in {
  inherit cleanupPackage profilePackage;
  cleanupCmd = lib.getExe cleanupPackage;
  profileCmd = lib.getExe profilePackage;
  packages = [cleanupPackage profilePackage];
}
