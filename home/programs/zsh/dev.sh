 # shellcheck shell=bash
p () {
  local workspace url localPath
  workspace="$DEV_PATH"

  if ! command -v git > /dev/null 2>&1
  then
    echo Cannot find git
    return 1
  fi

  # If we don't get arguments, envoke cddev
  if [ $# -ne 1 ]
  then
    _cdp
    return "$_"
  fi

  url=$1
  localPath="$workspace/$(_path_from_url "$url")"

  if [ ! -e "$localPath" ]
  then
    git clone "$url" "$localPath" || return 1
  fi

  $(_cdz) "$localPath" || exit 1
}

_cdp () {
  local repo_path
  if repo_path=$(fd -u -td '\.git$' "$DEV_PATH" | xargs dirname | fzf) && [ -d "$repo_path" ]; then
    $(_cdz) "$repo_path" || return 1
  fi
}

_cdz() {
  if command -v z >/dev/null 2>&1 ; then
    echo z
  else
    echo cd
  fi
}

_path_from_url () {
  perl -pe 's!
    ^(?<prot>\w+://)? # Capture the protocol part (e.g. "ssh://")
    (?<username>\w+@)?
    (?<domain>(\w+\.)*\w+\.\w+) # capture the domain
    (?<port>:[0-9]+)?
    [:/](?<path>.*)(\.git$) # Capture the path
  !$+{domain}/$+{path}!x' <<< "$1"
}
