#!/usr/bin/env bash
#
# start-task.sh - set up git worktrees for a new task.
#
# Usage:
#   start-task.sh <task-name> [repo-name ...]
#   start-task.sh [task-name] <github-pr-url>
#   start-task.sh done
#   start-task.sh restart
#
# Behavior:
#   * "done" (run from inside a task directory) tears the task down: it verifies
#     every worktree is complete (clean tree, and either its PR is merged or the
#     branch has no commits beyond origin/master), then removes the worktrees,
#     deletes their local branches, and moves the task directory to ~/src/hades.
#     If anything looks incomplete, it aborts and changes nothing.
#   * "restart" (run from inside an archived task under ~/src/hades) brings a
#     task back to ~/src/current-tasks: it recreates each repo's worktree on its
#     original branch when that branch still exists (locally or on origin), or
#     on a fresh branch off origin/master when the branch is gone. Planning
#     artifacts saved at the task level are carried back over.
#   * If a GitHub PR URL is given (on its own or after a task name), creates the
#     usual ~/src/current-tasks/<task>/<repo> worktree (repo taken from the URL)
#     but checks out the PR's own branch. Without a task name, the task dir is
#     named after the PR's branch.
#   * If run from inside a git repo, creates a single worktree for that repo at
#     ~/src/current-tasks/<task-name>/<repo-name>, branched off the repo's
#     current HEAD. Extra repo args are ignored (with a warning).
#   * If NOT run from inside a git repo, one or more repo names (found in
#     ~/src) are expected. Each gets a worktree at
#     ~/src/current-tasks/<task-name>/<repo-name>, branched off that repo's
#     freshly-fetched origin/master. If no repo names are given, prompts for
#     them (newline separated, terminated by an empty line).
#   * All worktrees use the branch name <$USER>_<task-name>.
#
# Human-facing messages/prompts go to stderr. The single line printed to stdout
# is the directory to cd into (consumed by the start-task shell function).

set -euo pipefail

SRC_DIR="$HOME/src"
TASKS_ROOT="$SRC_DIR/current-tasks"
HADES="$SRC_DIR/hades"

err() { printf '%s\n' "$*" >&2; }
die() { err "Error: $*"; exit 1; }

# Sanitize a task name just enough to be a valid directory (and branch) name.
sanitize() {
  printf '%s' "$1" | sed -e 's#[^A-Za-z0-9._-]#-#g'
}

# Is the given directory a git repo?
is_git_repo() {
  git -C "$1" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# Error out if the branch already exists in the repo at $1. Branch defaults to
# the global $BRANCH but can be overridden via $2 (used by PR-URL mode).
assert_branch_free() {
  local repo_dir="$1"
  local branch="${2:-$BRANCH}"
  if git -C "$repo_dir" show-ref --verify --quiet "refs/heads/$branch"; then
    die "branch '$branch' already exists in $repo_dir"
  fi
}

# Error out if the worktree target already exists.
assert_target_free() {
  if [ -e "$1" ]; then
    die "worktree target already exists: $1"
  fi
}

# Tear down the task containing the current directory: verify each worktree is
# finished, then remove worktrees, delete their branches, and archive the task
# directory under ~/src/hades. Aborts without changing anything if incomplete.
do_done() {
  local cur tasks_phys rel task task_dir
  cur="$(pwd -P)"
  tasks_phys="$(cd "$TASKS_ROOT" 2>/dev/null && pwd -P)" \
    || die "no tasks directory at $TASKS_ROOT"
  case "$cur/" in
    "$tasks_phys"/*) ;;
    *) die "'done' must be run from inside a task under $TASKS_ROOT" ;;
  esac
  rel="${cur#"$tasks_phys"/}"
  task="${rel%%/*}"
  task_dir="$tasks_phys/$task"
  [ -d "$task_dir" ] || die "task directory not found: $task_dir"

  local worktrees=() sources=() branches=() shas=() d
  for d in "$task_dir"/*/; do
    d="${d%/}"
    [ -d "$d" ] || continue
    is_git_repo "$d" || continue
    worktrees+=("$d")
    sources+=("$(git -C "$d" worktree list --porcelain | sed -n '1s/^worktree //p')")
    branches+=("$(git -C "$d" symbolic-ref --quiet --short HEAD 2>/dev/null || true)")
    shas+=("$(git -C "$d" rev-parse HEAD 2>/dev/null || true)")
  done
  [ "${#worktrees[@]}" -gt 0 ] || die "no git worktrees found in $task_dir"

  err "Verifying task '$task' is complete..."
  local i incomplete=() summary=() forces=()
  for i in "${!worktrees[@]}"; do
    d="${worktrees[$i]}"
    local name branch dirty ahead pr_state reason ok force
    name="$(basename "$d")"
    branch="${branches[$i]}"
    reason=""; ok=1; force=0

    dirty="$(git -C "$d" status --porcelain)"

    if git -C "$d" fetch origin master --quiet 2>/dev/null; then
      ahead="$(git -C "$d" rev-list --count FETCH_HEAD..HEAD 2>/dev/null || echo '?')"
    else
      ahead="?"
    fi

    pr_state=""
    if [ -n "$branch" ]; then
      pr_state="$( (cd "$d" && gh pr view --json state -q .state 2>/dev/null) || true )"
    fi

    if [ "$pr_state" = "CLOSED" ]; then
      ok=1; force=1
    elif [ "$pr_state" = "OPEN" ]; then
      ok=0; reason="PR is still open"
    elif [ -n "$dirty" ]; then
      ok=0; reason="uncommitted changes"
    elif [ "$pr_state" = "MERGED" ] || [ "$ahead" = "0" ]; then
      ok=1
    elif [ "$ahead" = "?" ]; then
      ok=0; reason="could not fetch origin master to verify merge"
    else
      ok=0; reason="branch not merged into master (${ahead} commit(s) ahead)"
    fi

    forces+=("$force")
    if [ "$ok" = 1 ] && [ "$force" = 1 ]; then
      summary+=("  ok   $name [${branch:-detached}] PR CLOSED - force-cleaning${dirty:+ (discarding uncommitted changes)}")
    elif [ "$ok" = 1 ]; then
      summary+=("  ok   $name [${branch:-detached}]${pr_state:+ PR $pr_state}")
    else
      incomplete+=("  FAIL $name [${branch:-detached}]: $reason")
    fi
  done

  if [ "${#incomplete[@]}" -gt 0 ]; then
    err "Task '$task' is not ready to finish:"
    printf '%s\n' "${incomplete[@]}" >&2
    die "aborting; nothing was changed"
  fi

  err "All worktrees complete:"
  printf '%s\n' "${summary[@]}" >&2

  local manifest="$task_dir/.start-task-manifest"
  : > "$manifest"
  for i in "${!worktrees[@]}"; do
    printf '%s\t%s\t%s\n' \
      "$(basename "${worktrees[$i]}")" "${branches[$i]}" "${shas[$i]}" >> "$manifest"
  done

  cd "$SRC_DIR"
  for i in "${!worktrees[@]}"; do
    local wt="${worktrees[$i]}" src="${sources[$i]}" branch="${branches[$i]}"
    [ -n "$src" ] || continue
    if [ "${forces[$i]}" = 1 ]; then
      git -C "$src" worktree remove --force "$wt" >&2 \
        || die "failed to remove worktree $wt"
    else
      git -C "$src" worktree remove "$wt" >&2 \
        || die "failed to remove worktree $wt (not clean?)"
    fi
    if [ -n "$branch" ]; then
      git -C "$src" branch -D "$branch" >&2 \
        || err "  (could not delete branch '$branch' in $src)"
    fi
  done

  mkdir -p "$HADES"
  local dest="$HADES/$task"
  [ -e "$dest" ] && dest="$HADES/${task}-$(date +%Y%m%d-%H%M%S)"
  mv "$task_dir" "$dest"

  err "Task '$task' finished and archived to $dest"
  printf '%s\n' "$SRC_DIR"
}

# Bring an archived task back from ~/src/hades into ~/src/current-tasks: recreate
# each repo's worktree on its original branch when that branch still exists
# (locally or on origin), otherwise on a fresh branch off origin/master. Planning
# artifacts saved at the task level are carried back over.
do_restart() {
  local cur hades_phys rel task hades_task active_dir manifest
  cur="$(pwd -P)"
  hades_phys="$(cd "$HADES" 2>/dev/null && pwd -P)" \
    || die "no hades directory at $HADES"
  case "$cur/" in
    "$hades_phys"/*) ;;
    *) die "'restart' must be run from inside an archived task under $HADES" ;;
  esac
  rel="${cur#"$hades_phys"/}"
  task="${rel%%/*}"
  hades_task="$hades_phys/$task"
  [ -d "$hades_task" ] || die "archived task not found: $hades_task"

  manifest="$hades_task/.start-task-manifest"
  [ -f "$manifest" ] || die "no start-task manifest in $hades_task; cannot safely restart"

  active_dir="$TASKS_ROOT/$task"
  [ -e "$active_dir" ] && die "task is already active at $active_dir"

  local repo branch sha src
  while IFS=$'\t' read -r repo branch sha; do
    [ -n "$repo" ] || continue
    src="$SRC_DIR/$repo"
    [ -d "$src" ] || die "source repo '$repo' not found in $SRC_DIR"
    is_git_repo "$src" || die "'$repo' in $SRC_DIR is not a git repo"
  done < "$manifest"

  mkdir -p "$active_dir"

  local created=() target desired
  while IFS=$'\t' read -r repo branch sha; do
    [ -n "$repo" ] || continue
    src="$SRC_DIR/$repo"
    target="$active_dir/$repo"
    desired="${branch:-${USER}_${task}}"

    git -C "$src" fetch origin --quiet 2>/dev/null \
      || err "  (fetch failed for '$repo'; using local refs)"

    if [ -n "$branch" ] && git -C "$src" show-ref --verify --quiet "refs/heads/$branch"; then
      err "Restoring '$repo' on existing local branch '$branch'"
      git -C "$src" worktree add "$target" "$branch" >&2
      created+=("  $repo -> $branch (existing local branch)")
    elif [ -n "$branch" ] && git -C "$src" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
      err "Restoring '$repo' on '$branch' tracking origin"
      git -C "$src" worktree add --track -b "$branch" "$target" "origin/$branch" >&2
      created+=("  $repo -> $branch (tracking origin)")
    else
      git -C "$src" show-ref --verify --quiet "refs/remotes/origin/master" \
        || die "origin/master not found for '$repo'; cannot start a new branch"
      if git -C "$src" show-ref --verify --quiet "refs/heads/$desired"; then
        die "branch '$desired' already exists in $src; resolve before restarting"
      fi
      err "Original branch '${branch:-<none>}' for '$repo' is gone; new branch '$desired' off origin/master"
      git -C "$src" worktree add -b "$desired" "$target" "origin/master" >&2
      created+=("  $repo -> $desired (new branch off master)")
    fi
  done < "$manifest"

  local entry base
  shopt -s dotglob nullglob
  for entry in "$hades_task"/*; do
    base="$(basename "$entry")"
    [ "$base" = ".start-task-manifest" ] && continue
    [ -e "$active_dir/$base" ] && continue
    mv "$entry" "$active_dir/"
  done
  shopt -u dotglob nullglob

  rm -rf "$hades_task"

  err "Restored task '$task':"
  printf '%s\n' "${created[@]}" >&2
  cd "$active_dir"
  printf '%s\n' "$active_dir"
}

# ---- args --------------------------------------------------------------------

if [ "$#" -lt 1 ]; then
  die "usage: start-task <task-name> [repo-name ...]  |  start-task [task-name] <github-pr-url>  |  start-task done  |  start-task restart"
fi

if [ "$1" = "done" ]; then
  do_done
  exit 0
fi

if [ "$1" = "restart" ]; then
  do_restart
  exit 0
fi

# A GitHub PR URL may be given on its own or after a task name. Detect it in
# either position; when it's first, the task name is derived from the PR below.
PR_URL=""
RAW_TASK=""
if [[ "$1" =~ ^https?:// ]]; then
  PR_URL="$1"; shift
else
  RAW_TASK="$1"; shift
  if [ "$#" -ge 1 ] && [[ "$1" =~ ^https?:// ]]; then
    PR_URL="$1"; shift
  fi
fi

# ---- PR-URL mode -------------------------------------------------------------
# Creates the usual ~/src/current-tasks/<task>/<repo> worktree, but checks out
# the PR's own branch instead of a new ${USER}_<task> branch. The repo comes
# from the URL, so this works regardless of the current directory. If no task
# name was given, it is derived from the PR's branch name.

if [ -n "$PR_URL" ]; then
  [ "$#" -eq 0 ] || err "Warning: ignoring extra args after URL: $*"

  if [[ "$PR_URL" =~ ^https?://[^/]+/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
    url_repo="${BASH_REMATCH[2]}"
    pr_num="${BASH_REMATCH[3]}"
  else
    die "not a recognized GitHub PR URL (expected .../<owner>/<repo>/pull/<n>): $PR_URL"
  fi

  src_repo="$SRC_DIR/$url_repo"
  [ -d "$src_repo" ] || die "repo '$url_repo' (from URL) not found in $SRC_DIR"
  is_git_repo "$src_repo" || die "'$url_repo' in $SRC_DIR is not a git repo"

  # Resolve the PR's head branch name (and whether it's from a fork) via gh.
  head_ref=""
  cross_repo=""
  if command -v gh >/dev/null 2>&1; then
    pr_info="$(gh pr view "$PR_URL" --json headRefName,isCrossRepository \
      -q '.headRefName + " " + (.isCrossRepository | tostring)' 2>/dev/null || true)"
    head_ref="${pr_info%% *}"
    cross_repo="${pr_info##* }"
  fi

  # Task (directory) name: explicit if given, else the PR branch, else pr-<n>.
  if [ -n "$RAW_TASK" ]; then
    TASK="$(sanitize "$RAW_TASK")"
  elif [ -n "$head_ref" ]; then
    TASK="$(sanitize "$head_ref")"
  else
    TASK="pr-$pr_num"
  fi
  [ -n "$TASK" ] || die "could not determine a task name for $PR_URL"

  TASK_DIR="$TASKS_ROOT/$TASK"
  target="$TASK_DIR/$url_repo"
  assert_target_free "$target"

  mkdir -p "$TASK_DIR"
  if [ -n "$head_ref" ] && [ "$cross_repo" != "true" ]; then
    # Same-repo PR: check out its branch tracking origin so pushes update the PR.
    assert_branch_free "$src_repo" "$head_ref"
    err "Checking out PR #$pr_num branch '$head_ref' for '$url_repo' at $target"
    git -C "$src_repo" fetch origin "$head_ref" >&2 \
      || die "failed to fetch branch '$head_ref' for PR #$pr_num"
    git -C "$src_repo" worktree add --track -b "$head_ref" "$target" "origin/$head_ref" >&2
  else
    # Fork PR, or gh unavailable/failed: check out the PR head via pull/<n>/head.
    local_branch="${head_ref:-pr-$pr_num}"
    assert_branch_free "$src_repo" "$local_branch"
    if [ "$cross_repo" = "true" ]; then
      err "PR #$pr_num is from a fork; checking out pull/$pr_num/head as '$local_branch' (no push tracking)"
    else
      err "Could not resolve PR branch via gh; checking out pull/$pr_num/head as '$local_branch'"
    fi
    git -C "$src_repo" fetch origin "pull/$pr_num/head" >&2 \
      || die "failed to fetch PR #$pr_num"
    git -C "$src_repo" worktree add -b "$local_branch" "$target" FETCH_HEAD >&2
  fi

  printf '%s\n' "$TASK_DIR"
  exit 0
fi

# ---- normal mode: a task name is required ------------------------------------

TASK="$(sanitize "$RAW_TASK")"
[ -n "$TASK" ] || die "task name '$RAW_TASK' sanitizes to an empty string"

BRANCH="${USER}_${TASK}"
TASK_DIR="$TASKS_ROOT/$TASK"

# ---- single-repo mode (inside a git repo) ------------------------------------

if is_git_repo "$PWD"; then
  if [ "$#" -gt 0 ]; then
    err "Warning: inside a git repo; ignoring extra repo args: $*"
  fi

  toplevel="$(git -C "$PWD" rev-parse --show-toplevel)"
  repo_name="$(basename "$toplevel")"
  target="$TASK_DIR/$repo_name"

  assert_branch_free "$toplevel" "$BRANCH"
  assert_target_free "$target"

  mkdir -p "$TASK_DIR"
  err "Creating worktree for '$repo_name' at $target (branch '$BRANCH', off current HEAD)"
  git -C "$toplevel" worktree add -b "$BRANCH" "$target" HEAD >&2

  printf '%s\n' "$TASK_DIR"
  exit 0
fi

# ---- multi-repo mode (not inside a git repo) ---------------------------------

# Validate that every name refers to a git repo in ~/src. Prints the offending
# names to stderr; returns nonzero if any are invalid.
validate_repos() {
  local ok=0 name path
  for name in "$@"; do
    path="$SRC_DIR/$name"
    if [ ! -d "$path" ]; then
      err "  '$name' does not exist in $SRC_DIR"
      ok=1
    elif ! is_git_repo "$path"; then
      err "  '$name' in $SRC_DIR is not a git repo"
      ok=1
    fi
  done
  return $ok
}

repos=("$@")

if [ "${#repos[@]}" -eq 0 ]; then
  # Prompt for repo names, newline separated, terminated by an empty line.
  while :; do
    err "Not in a git repo. Enter repo names in $SRC_DIR (one per line; blank line to finish):"
    repos=()
    while IFS= read -r line; do
      [ -z "$line" ] && break
      repos+=("$line")
    done
    if [ "${#repos[@]}" -eq 0 ]; then
      err "No repos entered. Try again."
      continue
    fi
    if validate_repos "${repos[@]}"; then
      break
    fi
    err "One or more repo names were invalid. Try again."
  done
else
  # Names provided as args: validate once, error out on any problem.
  if ! validate_repos "${repos[@]}"; then
    die "one or more repo names are invalid"
  fi
fi

# Pre-flight: make sure no branch/target collisions before touching anything.
for name in "${repos[@]}"; do
  assert_branch_free "$SRC_DIR/$name" "$BRANCH"
  assert_target_free "$TASK_DIR/$name"
done

mkdir -p "$TASK_DIR"
for name in "${repos[@]}"; do
  src_repo="$SRC_DIR/$name"
  target="$TASK_DIR/$name"

  err "Fetching origin/master for '$name'..."
  git -C "$src_repo" fetch origin master >&2 \
    || die "failed to fetch origin master for '$name'"

  err "Creating worktree for '$name' at $target (branch '$BRANCH', off freshly fetched origin/master)"
  git -C "$src_repo" worktree add -b "$BRANCH" "$target" FETCH_HEAD >&2
done

printf '%s\n' "$TASK_DIR"
exit 0
