#!/usr/bin/env bash
#
# Snapshot currently known Claude Code marketplaces into dotfiles
# settings.json so fresh machines bootstrap the same set via
# extraKnownMarketplaces. Run this whenever you add a marketplace
# with /plugin marketplace add and want it persisted.
#
# Usage:  ./claude/sync-marketplaces.sh
# Then:   git diff .claude/settings.json  (review)
#         git commit -am "..."            (if happy)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KNOWN="$HOME/.claude/plugins/known_marketplaces.json"
SETTINGS="$REPO_ROOT/.claude/settings.json"

if [[ ! -f "$KNOWN" ]]; then
    echo "error: $KNOWN not found" >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "error: jq is required. Install with: brew install jq" >&2
    exit 1
fi

# Keep only the source definition, drop installLocation/lastUpdated/autoUpdate
# (machine-local state), and skip the builtin marketplace.
extras=$(jq '
    to_entries
    | map(select(.key != "claude-plugins-official"))
    | map({key: .key, value: {source: .value.source}})
    | from_entries
' "$KNOWN")

tmp=$(mktemp)
jq --argjson extras "$extras" '.extraKnownMarketplaces = $extras' "$SETTINGS" > "$tmp"
mv "$tmp" "$SETTINGS"

count=$(echo "$extras" | jq 'length')
echo "Synced $count marketplaces into $SETTINGS"
echo "Review with: git diff .claude/settings.json"
