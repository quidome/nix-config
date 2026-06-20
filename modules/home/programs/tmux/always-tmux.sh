# some exceptions in which case tmux should not be used
if  [ -n "$TMUX" ] ||
    [ -n "$KATE_PID" ] ||
    [[ "$GIO_LAUNCHED_DESKTOP_FILE" == *"guake.desktop"* ]] ||
    [ "$__CFBundleIdentifier" = "io.lapce" ] ||
    [[ "$(tty)" =~ /dev/tty[0-9] ]] ||
    [[ "$TERM" == screen* ]] ||
    [[ "$TERM" == "" ]] ||
    [ "$ZED_TERM" = "true" ] ||
    [ "$TERM_PROGRAM" = "vscode" ] ||
    [ "$TERMINAL_EMULATOR" = "JetBrains-JediTerm" ] ||
    [ "$NO_TMUX" = "1" ] ||
    [ "$NO_ZELLIJ" = "1" ] ||
    [ "$INSIDE_EMACS" = 'vterm' ]
then
    return 1
fi

if [[ $TERM != "screen-256color" && $TERM != "linux" && -z "$TMUX" ]] ; then
    if tmux has-session -t 'default-session' 2>/dev/null; then
        tmux attach -t 'default-session'
    else
        tmux new-session -s 'default-session'
    fi
fi
