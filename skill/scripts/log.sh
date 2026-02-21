#!/bin/bash
# Wix MCP Skill - Decision Logger
# Usage: log.sh <EVENT_TYPE> <DOMAIN> <DETAIL>
# Event types: RECIPE_HIT, RECIPE_MISS, README_FALLBACK, BROWSE_AVOIDED, BROWSE_USED, FACT_CACHE_HIT

LOG_DIR="$(dirname "$0")/../logs"
LOG_FILE="$LOG_DIR/wix-mcp.log"

mkdir -p "$LOG_DIR"

EVENT_TYPE="${1:-UNKNOWN}"
DOMAIN="${2:-unknown}"
DETAIL="${3:-}"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "${TIMESTAMP} | ${EVENT_TYPE} | ${DOMAIN} | ${DETAIL}" >> "$LOG_FILE"
echo "Logged: ${EVENT_TYPE} | ${DOMAIN} | ${DETAIL}"
