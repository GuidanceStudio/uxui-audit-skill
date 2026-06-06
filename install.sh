#!/usr/bin/env bash
set -euo pipefail

# ui-review skill installer.
#
# Copies the skill files into the user's Claude skill directory so the
# `/ui-review` slash command and routing become available.
#
# Local mode:  ./install.sh [OPTIONS]
# Remote mode: bash <(curl -fsSL https://raw.githubusercontent.com/GuidanceStudio/ui-review-skill/main/install.sh)

REPO_URL="${UI_REVIEW_REPO_URL:-https://github.com/GuidanceStudio/ui-review-skill.git}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FORCE=false
TARGET_DIR="${HOME}/.claude/skills/ui-review"
CLEANUP_DIR=""

cleanup_temp() {
    if [ -n "$CLEANUP_DIR" ] && [ -d "$CLEANUP_DIR" ]; then
        rm -rf "$CLEANUP_DIR"
    fi
}
trap cleanup_temp EXIT

usage() {
    cat <<EOF
Install the ui-review Claude skill.

Usage:
    ./install.sh [OPTIONS]

Options:
    --force         Overwrite an existing installation without prompting.
    --target DIR    Install to DIR instead of $TARGET_DIR.
    --help          Show this message.

Environment:
    UI_REVIEW_REPO_URL    Override the remote-mode clone URL.
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --force) FORCE=true; shift ;;
        --target) TARGET_DIR="$2"; shift 2 ;;
        --help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
    esac
done

# Locate the skill source. Local mode: the claude/ui-review dir next to this
# script. Remote mode (script piped from curl): clone the repo to a temp dir.
SRC_DIR="$SCRIPT_DIR/claude/ui-review"
if [ ! -d "$SRC_DIR" ]; then
    echo "→ ui-review source not found locally; cloning $REPO_URL"
    CLEANUP_DIR="$(mktemp -d)"
    git clone --depth 1 "$REPO_URL" "$CLEANUP_DIR/repo" >/dev/null 2>&1
    SRC_DIR="$CLEANUP_DIR/repo/claude/ui-review"
fi

if [ ! -f "$SRC_DIR/SKILL.md" ]; then
    echo "✗ could not find claude/ui-review/SKILL.md to install" >&2
    exit 1
fi

if [ -d "$TARGET_DIR" ] && [ "$FORCE" != true ]; then
    printf "Overwrite existing install at %s? [y/N] " "$TARGET_DIR"
    read -r reply
    case "$reply" in
        [yY]*) ;;
        *) echo "Aborted."; exit 0 ;;
    esac
fi

rm -rf "$TARGET_DIR"
mkdir -p "$(dirname "$TARGET_DIR")"
cp -R "$SRC_DIR" "$TARGET_DIR"

echo "✓ ui-review installed to $TARGET_DIR"
echo "  Invoke it with /ui-review (or describe a UI/UX review task)."
echo "  Capture needs Node ≥18 + Playwright — see README.md › Requirements."
