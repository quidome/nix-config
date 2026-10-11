# Fail when a plain (not git-crypt) file holds a secret.
# Usage: leak-guard <dir>
# Prints file, line and kind of each hit, never the line itself.
# A line that contains "leak-guard: allow" is skipped (see docs/product/secrets.md).
root="${1:?usage: leak-guard <dir>}"
cd "$root"

# Stop on .gitattributes rules that the matching below cannot follow exactly,
# so that a plain file is never skipped by mistake.
unsupported() {
  echo "leak guard: unsupported .gitattributes rule: $1" >&2
  exit 2
}

# A nested .gitattributes may only turn the filter off for its whole folder,
# as git-crypt's own .git-crypt/.gitattributes does; every file there is checked.
plain_dirs=()
while IFS= read -r -d '' file; do
  rules="$(awk '$1 !~ /^#/ && /filter/' "$file")"
  if [[ -z "$rules" ]]; then
    continue
  fi
  if [[ "$(awk '{print $1}' <<<"$rules")" != "*" ]] ||
    ! grep -qE '(^|[[:space:]])[-!]filter([[:space:]]|$)' <<<"$rules"; then
    unsupported "${file#./} (a nested .gitattributes may only turn the filter off for its folder)"
  fi
  dir="${file#./}"
  plain_dirs+=("${dir%/.gitattributes}/")
done < <(find . -mindepth 2 -name .gitattributes -not -path './.git/*' -print0)

# Patterns that git-crypt encrypts, from .gitattributes.
encrypted=()
if [[ -f .gitattributes ]]; then
  while read -r lineno pat; do
    # A wildcard in a pattern with a slash does not match "/" in git, but does in bash.
    if [[ "$pat" == */* && "$pat" == *[][*?]* ]]; then
      unsupported ".gitattributes:$lineno (wildcard in a pattern with a slash)"
    fi
    encrypted+=("$pat")
  done < <(awk '$1 !~ /^(#|\[attr\])/ && /filter=git-crypt/ {print NR, $1}' .gitattributes)
  # Any other filter rule could make a matched file plain again; a macro is not a path.
  while read -r lineno reason; do
    unsupported ".gitattributes:$lineno ($reason)"
  done < <(awk '
    $1 ~ /^#/ { next }
    $1 ~ /^\[attr\]/ { print NR, "macro"; next }
    {
      for (i = 2; i <= NF; i++) {
        if ($i ~ /^[-!]filter$/) { print NR, "filter turned off"; next }
        if ($i ~ /^filter(=|$)/ && $i != "filter=git-crypt") { print NR, "other filter"; next }
      }
    }' .gitattributes)
fi

is_encrypted() {
  local path="$1" pat dir
  for dir in "${plain_dirs[@]}"; do
    [[ "$path" == "$dir"* ]] && return 1
  done
  for pat in "${encrypted[@]}"; do
    if [[ "$pat" == */* ]]; then
      # A pattern with a slash matches the whole path.
      # shellcheck disable=SC2053
      [[ "$path" == ${pat#/} ]] && return 0
    else
      # A pattern without a slash matches the file name, in any folder.
      # shellcheck disable=SC2053
      [[ "${path##*/}" == $pat ]] && return 0
    fi
  done
  return 1
}

# Each entry is "kind|extended regex". The $ signs are meant literally.
# shellcheck disable=SC2016
checks=(
  'password hash|\$(1|2[abxy]?|5|6|7|y|gy|apr1|argon2(id|i|d))\$[./A-Za-z0-9]'
  'private key|-----BEGIN ([A-Z0-9]+ )*PRIVATE KEY( BLOCK)?-----'
  'age secret key|AGE-SECRET-KEY-1[0-9A-Z]{10,}'
)

hits=()
while IFS= read -r -d '' file; do
  path="${file#./}"
  if is_encrypted "$path"; then
    continue
  fi
  for check in "${checks[@]}"; do
    kind="${check%%|*}"
    re="${check#*|}"
    code=0
    found="$(grep -nIE -e "$re" -- "$file")" || code=$?
    if ((code > 1)); then
      echo "leak guard: cannot read $path" >&2
      exit 2
    fi
    if [[ -z "$found" ]]; then
      continue
    fi
    while read -r line; do
      hits+=("  $path:$line  $kind")
    done < <(grep -v 'leak-guard: allow' <<<"$found" | cut -d: -f1 || true)
  done
done < <(find . -type f -not -path './.git/*' -print0 | sort -z)

if ((${#hits[@]})); then
  echo "leak guard: possible secret in a plain file" >&2
  printf '%s\n' "${hits[@]}" >&2
  exit 1
fi
