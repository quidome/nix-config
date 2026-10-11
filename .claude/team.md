# Team for nix-config

project-type: infrastructure    # software | infrastructure  (see project-types/)
maturity: maturing              # early | maturing | mature  (how strict the architect is)
product-docs: docs/product/     # one document per service or host group

## Roles
# role: persona + expertise, expertise
# No product-designer: infrastructure project; the architect does that work.
product-lead: carl
architect: steve + nix
engineer: bruce + nix
tester: august + nix
developer: matthew + nix
scope-keeper: matthew

## Project notes
# Short facts every stage must know, for example the check command.
check: just verify            # fmt + lint + flake check; fmt can change files
host check: just build HOST for each affected host; just plan HOST on the current host
hooks: each edited .nix file is formatted (alejandra) and linted (statix, deadnix) at once; findings come back to Claude (.claude/hooks/nix-post-edit.sh)
never without approval: just switch / boot / upgrade / sync / gc
secrets: git-crypt; never read or show encrypted files
