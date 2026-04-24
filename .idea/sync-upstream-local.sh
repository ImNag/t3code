#!/bin/zsh

# Local upstream sync.
# Companion to .idea/sync-upstream.sh (which triggers the GitHub workflow).
# Use this when the scheduled workflow fails on merge conflicts — or
# whenever you want the merge to happen on your machine so IntelliJ's
# three-way merge tool can resolve conflicts.
#
# Flow:
#   1. Ensures `upstream` remote exists (adds pingdotgg/t3code via SSH).
#   2. Fetches upstream/main.
#   3. Attempts `git merge upstream/main`.
#   4. On success → pushes to origin/main.
#   5. On conflict → prints the conflicted files and tells you to open
#      IntelliJ's Git → Resolve Conflicts. After you resolve + commit,
#      just run `git push`.

set -u

UPSTREAM_URL="git@github.com:pingdotgg/t3code.git"
BRANCH="main"

print -P "%F{cyan}==%f Checking upstream remote …"
if git remote get-url upstream >/dev/null 2>&1; then
  current=$(git remote get-url upstream)
  if [[ "$current" != "$UPSTREAM_URL" ]]; then
    print -P "%F{yellow}[WARN]%f upstream remote points to $current (expected $UPSTREAM_URL)"
  else
    print -P "%F{green}[OK]%f   upstream = $current"
  fi
else
  print -P "%F{cyan}[..]%f   adding upstream → $UPSTREAM_URL"
  git remote add upstream "$UPSTREAM_URL"
fi

print -P "\n%F{cyan}==%f Fetching upstream/$BRANCH …"
git fetch upstream "$BRANCH" || {
  print -P "%F{red}[FAIL]%f fetch failed"
  exit 1
}

AHEAD=$(git rev-list --count "HEAD..upstream/$BRANCH")
if [[ "$AHEAD" == "0" ]]; then
  print -P "\n%F{green}[OK]%f   already up to date with upstream/$BRANCH — nothing to merge."
  exit 0
fi

print -P "\n%F{cyan}==%f Merging upstream/$BRANCH ($AHEAD commit(s) to pull in) …"
if git merge --no-edit "upstream/$BRANCH"; then
  print -P "\n%F{green}[OK]%f   merge clean — pushing to origin/$BRANCH …"
  git push origin "$BRANCH"
  print -P "\n%F{green}[OK]%f   done."
  exit 0
fi

# Merge conflict path.
print -P "\n%F{yellow}[CONFLICT]%f merge halted with conflicts."
print -P "\nConflicted files:"
git diff --name-only --diff-filter=U | sed 's/^/  /'

cat <<'EOF'

Next steps (in IntelliJ):
  1. Git tool window → "Resolve Conflicts…" (or bottom-right status bar
     shows a red banner linking to it).
  2. For each file, IntelliJ opens the three-way merge dialog
     (Yours | Result | Theirs). Resolve, click Apply.
  3. Once all files are resolved, commit the merge (Git → Commit,
     or ⌘K / Ctrl+K). Leave the default merge commit message.
  4. Push: Git → Push (⌘⇧K / Ctrl+Shift+K).

To abort the merge instead and go back to where you were:
  git merge --abort
EOF
exit 2
