# some exceptions in which case zellij should not be used
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
    [ "$HERDR_ENV" = "1" ] ||
    [ "$INSIDE_EMACS" = 'vterm' ]
then
    return 1
fi


if [[ $TERM != "screen-256color" && $TERM != "linux" && -z "$ZELLIJ" ]] ; then
    session_name="auto-${HOSTNAME:-host}-$$"
    zellij attach -c "$session_name"
fi
