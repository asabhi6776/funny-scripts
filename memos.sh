#!/usr/bin/env bash
# Usage:
#   MEMOS_URI="https://YOUR_DOMAIN.com" MEMOS_TOKEN="YOUR_API_TOKEN" ./memo.sh "Content" -t tag1,tag2
# Or:
#   export MEMOS_URI="https://YOUR_DOMAIN.com"
#   export MEMOS_TOKEN="YOUR_API_TOKEN"
#   ./memo.sh "Content" -t tag1 tag2

set -euo pipefail

MEMOS_URI="${MEMOS_URI:-}"
MEMOS_TOKEN="${MEMOS_TOKEN:-}"

# --- Validate environment variables ---
if [[ -z "$MEMOS_URI" ]]; then
    echo "Error: MEMOS_URI is required. Set MEMOS_URI env variable or pass with -u." >&2
    exit 1
fi

if ! [[ "$MEMOS_URI" =~ ^https?:// ]]; then
    MEMOS_URI="https://$MEMOS_URI"
fi

if [[ -z "$MEMOS_TOKEN" ]]; then
    echo "Error: MEMOS_TOKEN is required. Set MEMOS_TOKEN env variable or pass with -k." >&2
    exit 1
fi

# --- Parse arguments ---
CONTENT=""
TAGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--tags)
            shift
            while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
                TAGS+=("$1")
                shift
            done
            ;;
        -u|--uri)
            MEMOS_URI="$2"
            shift 2
            ;;
        -k|--token)
            MEMOS_TOKEN="$2"
            shift 2
            ;;
        *)
            if [[ -z "$CONTENT" ]]; then
                CONTENT="$1"
            else
                CONTENT="$CONTENT $1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$CONTENT" ]]; then
    echo "Error: Content is required." >&2
    exit 1
fi

# --- Process tags ---
TAG_LIST=()
if [[ ${#TAGS[@]} -gt 0 ]]; then
    for t in "${TAGS[@]}"; do
        # Split on comma or whitespace
        for part in $(echo "$t" | tr ', ' '\n'); do
            [[ -n "$part" ]] && {
                [[ "$part" =~ ^# ]] && TAG_LIST+=("$part") || TAG_LIST+=("#$part")
            }
        done
    done
fi

TAG_STRING=""
if [[ ${#TAG_LIST[@]} -gt 0 ]]; then
    TAG_STRING=" $(printf '%s ' "${TAG_LIST[@]}")"
fi

# --- Build JSON payload ---
BODY=$(jq -nc --arg content "$CONTENT$TAG_STRING" '{content: $content}')

# --- Send request ---
RESPONSE=$(curl -sS -X POST \
    -H "Accept: application/json" \
    -H "Authorization: Bearer $MEMOS_TOKEN" \
    -H "Content-Type: application/json" \
    --data "$BODY" \
    "${MEMOS_URI%/}/api/v1/memos") || {
    echo "Error: HTTP request failed" >&2
    exit 1
}

echo "$RESPONSE"

