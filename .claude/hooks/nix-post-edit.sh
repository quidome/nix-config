#!/usr/bin/env bash
# PostToolUse hook: format and lint a .nix file after Claude edits it.
# Exit 2 sends lint findings back to Claude; other failures do not block.
set -uo pipefail
export NO_COLOR=1

file="$(jq -r '.tool_response.filePath // .tool_input.file_path // empty')"

[[ "$file" == *.nix && -f "$file" ]] || exit 0

# Never touch git-crypt protected files.
if git -C "$(dirname "$file")" check-attr filter -- "$file" 2>/dev/null | grep -q 'filter: git-crypt$'; then
  exit 0
fi

if ! alejandra -q "$file" 2>&1; then
  echo "alejandra could not format $file (syntax error?)" >&2
  exit 2
fi

findings="$(statix check "$file" 2>&1)" || statix_failed=1
dead="$(deadnix --fail "$file" 2>&1)" || deadnix_failed=1

if [[ -n "${statix_failed:-}" || -n "${deadnix_failed:-}" ]]; then
  {
    echo "Lint findings in $file:"
    [[ -n "${statix_failed:-}" ]] && echo "$findings"
    [[ -n "${deadnix_failed:-}" ]] && echo "$dead"
  } | sed "s/\x1b\[[0-9;]*m//g" >&2
  exit 2
fi

exit 0
