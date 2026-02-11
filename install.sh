#!/bin/bash
# Wix MCP Skill Installer for Claude Code
# Usage: ./install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$HOME/.claude/skills/wix-mcp"
COMMANDS_DIR="$HOME/.claude/commands"

echo "Installing Wix MCP Skill for Claude Code..."
echo ""

# Install skill files
mkdir -p "$SKILL_DIR"
cp -r "$SCRIPT_DIR/skill/"* "$SKILL_DIR/"
chmod +x "$SKILL_DIR/scripts/log.sh"
echo "  Skill installed to $SKILL_DIR"

# Install command
mkdir -p "$COMMANDS_DIR"
cp "$SCRIPT_DIR/commands/update-wix-recipes.md" "$COMMANDS_DIR/"
echo "  Command installed to $COMMANDS_DIR/update-wix-recipes.md"

# Create logs directory
mkdir -p "$SKILL_DIR/logs"

echo ""
echo "Done! The skill will auto-trigger in Claude Code for Wix API queries."
echo ""
echo "  /wix-mcp              — invoke manually"
echo "  /update-wix-recipes   — refresh recipes from Wix MCP"
echo ""
