# Tests for leak-guard. Usage: leak-guard-test <leak-guard program>
# Secret-like strings are built from parts at run time, so this file
# itself never matches the guard.
guard="${1:?usage: leak-guard-test <leak-guard program>}"

d='$'
marker="saltsalt"
hash6="${d}6${d}${marker}${d}abcdefghijklmnopqrstuvwxyz0123456789"
hashy="${d}y${d}j9T${d}${marker}${d}abcdefghijklmnopqrstuvwxyz"
hash2b="${d}2b${d}12${d}${marker}abcdefghijklmnopqrstuvwxyz"
hashapr1="${d}apr1${d}${marker}${d}abcdefghijklmnopqrstuv"
hashargon="${d}argon2id${d}v=19${d}m=65536,t=3,p=4${d}${marker}${d}abcdefghijklmnopqrstuvwxyz"
pk="PRIVATE KEY"
ssh_key="-----BEGIN OPENSSH ${pk}-----"
pgp_key="-----BEGIN PGP ${pk} BLOCK-----"
age="AGE-SECRET-KEY"
age_key="${age}-1QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ${marker^^}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
failed=0
dir=""
name=""

new_case() {
  name="$1"
  dir="$tmp/$1"
  mkdir -p "$dir"
}

# Write lines to a file in the current case folder.
put() {
  local file="$dir/$1"
  shift
  mkdir -p "$(dirname "$file")"
  printf '%s\n' "$@" >"$file"
}

encrypt() {
  printf '%s filter=git-crypt diff=git-crypt\n' "$@" >"$dir/.gitattributes"
}

# expect <exit code> [text that must be in the output]
expect() {
  local want="$1" text="${2-}" out code=0
  out="$("$guard" "$dir" 2>&1)" || code=$?
  if [[ $code -ne $want ]]; then
    echo "FAIL $name: exit $code, want $want"
    failed=1
  fi
  if [[ -n $text && $out != *"$text"* ]]; then
    echo "FAIL $name: output does not contain '$text'"
    failed=1
  fi
  if [[ $out == *"$marker"* || $out == *"${marker^^}"* ]]; then
    echo "FAIL $name: output shows a secret value"
    failed=1
  fi
}

new_case clean
put file.nix '{ x = 1; }'
expect 0

new_case hash-plain
put file.nix '{' '  a = 1;' "  p = \"$hash6\";" '}'
expect 1 "file.nix:3  password hash"

new_case hash-encrypted
put secrets.nix "p = \"$hash6\";"
encrypt secrets.nix
expect 0

new_case hash-encrypted-subfolder
put a/b/secrets.nix "p = \"$hash6\";"
encrypt secrets.nix
expect 0

new_case pattern-with-slash
put hosts/x/keep.nix "p = \"$hash6\";"
encrypt hosts/x/keep.nix
expect 0
put hosts/y/keep.nix "p = \"$hash6\";"
expect 1 "hosts/y/keep.nix:1  password hash"

new_case private-keys
put ssh.txt "$ssh_key"
put pgp.txt "$pgp_key"
expect 1 "ssh.txt:1  private key"
expect 1 "pgp.txt:1  private key"

new_case age-key
put key.txt "$age_key"
expect 1 "key.txt:1  age secret key"

new_case public-key
put keys.nix '"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGb7vGx0f2bEXAMPLEEXAMPLEEXAMPLEEXAMPLE1234 user@host"'
expect 0

new_case allow-mark
put file.nix "p = \"$hash6\"; # leak-guard: allow"
expect 0

new_case binary
printf 'bin\0%s\n' "$hash6" >"$dir/blob.bin"
expect 0

new_case other-hashes
put y.nix "p = \"$hashy\";"
put b.nix "p = \"$hash2b\";"
expect 1 "y.nix:1  password hash"
expect 1 "b.nix:1  password hash"

new_case htpasswd-and-argon2
put apr1.txt "user:$hashapr1"
put argon.nix "p = \"$hashargon\";"
expect 1 "apr1.txt:1  password hash"
expect 1 "argon.nix:1  password hash"

new_case unsupported-wildcard-with-slash
put hosts/x/plain.nix "p = \"$hash6\";"
encrypt 'hosts/*.nix'
expect 2 ".gitattributes:1 (wildcard in a pattern with a slash)"

new_case unsupported-filter-off
put docs/secrets.nix "p = \"$hash6\";"
printf '%s\n' 'secrets.nix filter=git-crypt diff=git-crypt' 'docs/secrets.nix !filter !diff' >"$dir/.gitattributes"
expect 2 ".gitattributes:2 (filter turned off)"

new_case unsupported-other-filter
put docs/secrets.nix "p = \"$hash6\";"
printf '%s\n' 'secrets.nix filter=git-crypt diff=git-crypt' 'docs/secrets.nix filter=lfs' 'x.nix filter' >"$dir/.gitattributes"
expect 2 ".gitattributes:2 (other filter)"

new_case unsupported-macro
put crypt "p = \"$hash6\";"
printf '%s\n' '[attr]crypt filter=git-crypt diff=git-crypt' >"$dir/.gitattributes"
expect 2 ".gitattributes:1 (macro)"

new_case unreadable-file
put locked.nix '{ x = 1; }'
chmod 000 "$dir/locked.nix"
if [[ -r "$dir/locked.nix" ]]; then
  echo "skip $name: running as root"
else
  expect 2 "cannot read locked.nix"
fi
chmod 644 "$dir/locked.nix"

new_case unsupported-nested-gitattributes
put a/.gitattributes 'secrets.nix filter=git-crypt diff=git-crypt'
put a/secrets.nix "p = \"$hash6\";"
expect 2 "a/.gitattributes (a nested .gitattributes may only turn the filter off for its folder)"

new_case nested-filter-off
encrypt secrets.nix
put .git-crypt/.gitattributes '* !filter !diff' '*.gpg binary'
put .git-crypt/secrets.nix "p = \"$hash6\";"
expect 1 ".git-crypt/secrets.nix:1  password hash"

if ((failed)); then
  exit 1
fi
echo "leak-guard: all tests passed"
