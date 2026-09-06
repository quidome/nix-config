# shellcheck shell=bash
# Wrapped in a named function so guards can use early `return` in both bash and zsh.
_zellij_attach() {
  command -v zellij &>/dev/null || return

  # Some exceptions in which case zellij should not be used.
  if [ -n "$TMUX" ] ||
     [ -n "$KATE_PID" ] ||
     [[ "$GIO_LAUNCHED_DESKTOP_FILE" == *"guake.desktop"* ]] ||
     [ "$__CFBundleIdentifier" = "io.lapce" ] ||
     [[ "$(tty)" =~ /dev/tty[0-9] ]] ||
     [[ "$TERM" == screen* ]] ||
     [[ "$TERM" == "" ]] ||
     [ "$ZED_TERM" = "true" ] ||
     [ "$TERM_PROGRAM" = "vscode" ] ||
     [ "$TERM_PROGRAM" = "Orca" ] ||
     [ "$TERMINAL_EMULATOR" = "JetBrains-JediTerm" ] ||
     [ "$NO_TMUX" = "1" ] ||
     [ "$NO_ZELLIJ" = "1" ] ||
     [ "$HERDR_ENV" = "1" ] ||
     [ "$INSIDE_EMACS" = 'vterm' ]; then
    return
  fi

  if [[ "$TERM" != "screen-256color" && "$TERM" != "linux" && -z "$ZELLIJ" ]]; then
    local -a animals=(🐶 🐱 🐭 🐹 🐰 🦊 🐻 🐼 🐨 🐯 🦁 🐮 🐷 🐸 🐙 🦋 🐝 🦄 🐳 🦈 🦅 🦉 🦚 🦜 🐊 🦒 🐘 🦘 🦥 🦦)
    local used
    used=$(zellij list-sessions 2>/dev/null | awk '{print $1}')
    local -a available=()
    for animal in "${animals[@]}"; do
      grep -qxF "${animal}" <<< "$used" || available+=("$animal")
    done
    if [ ${#available[@]} -eq 0 ]; then
      local animal other session_name
      for animal in "${animals[@]}"; do
        for other in "${animals[@]}"; do
          session_name="${animal}-${other}"
          grep -qxF "$session_name" <<< "$used" || available+=("$session_name")
        done
      done
    fi
    local idx=$(( RANDOM % ${#available[@]} ))
    [ -n "$ZSH_VERSION" ] && idx=$(( idx + 1 ))
    zellij attach -c "${available[$idx]}"
  fi
}
_zellij_attach
unset -f _zellij_attach
