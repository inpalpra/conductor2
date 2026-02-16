#!/bin/bash
# Install Conductor skill for all supported agents
# Usage: ./install.sh
#
# This script creates a skill directory with symlinks to the Conductor repository,
# so updates to the repo are automatically reflected in the skill.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CONDUCTOR_ROOT="$(dirname "$SKILL_DIR")"

echo "Conductor Skill Installer"
echo "========================="
echo ""

# Check if we're running from within a conductor repo
if [ ! -f "$CONDUCTOR_ROOT/commands/conductor/setup.toml" ]; then
    echo "Error: This script must be run from within the Conductor repository."
    echo "Expected to find: $CONDUCTOR_ROOT/commands/conductor/setup.toml"
    echo ""
    echo "Please clone the repository first:"
    echo "  git clone https://github.com/gemini-cli-extensions/conductor.git"
    echo "  cd conductor"
    echo "  ./skill/scripts/install.sh"
    exit 1
fi

echo "Conductor repository found at: $CONDUCTOR_ROOT"
echo ""
echo "Installing skill for all supported agents:"
echo "  - OpenCode global       (~/.opencode/skill/conductor/)"
echo "  - Claude CLI global     (~/.claude/skills/conductor/)"
echo "  - Codex global          (~/.codex/skills/conductor/)"
echo "  - Gemini CLI extension  (~/.gemini/extensions/conductor/)"
echo "  - Google Antigravity    (~/.gemini/antigravity/skills/conductor/)"
echo ""

TARGETS=(
    "$HOME/.opencode/skill/conductor"
    "$HOME/.claude/skills/conductor"
    "$HOME/.codex/skills/conductor"
    "$HOME/.gemini/extensions/conductor"
    "$HOME/.gemini/antigravity/skills/conductor"
)

for TARGET_DIR in "${TARGETS[@]}"; do
    echo ""
    echo "Installing to: $TARGET_DIR"
    
    # Remove existing installation
    rm -rf "$TARGET_DIR"
    
    # Create skill directory
    mkdir -p "$TARGET_DIR"
    
    # Copy SKILL.md (the only actual file)
    cp "$SKILL_DIR/SKILL.md" "$TARGET_DIR/"

    # Copy Codex/OpenAI skill metadata when present
    if [ -d "$SKILL_DIR/agents" ]; then
        cp -R "$SKILL_DIR/agents" "$TARGET_DIR/"
    fi
    
    # Create symlinks to conductor repo directories
    ln -s "$CONDUCTOR_ROOT/commands" "$TARGET_DIR/commands"
    ln -s "$CONDUCTOR_ROOT/templates" "$TARGET_DIR/templates"
    
    echo "  Created: $TARGET_DIR/SKILL.md"
    if [ -f "$TARGET_DIR/agents/openai.yaml" ]; then
        echo "  Created: $TARGET_DIR/agents/openai.yaml"
    fi
    echo "  Symlink: $TARGET_DIR/commands -> $CONDUCTOR_ROOT/commands"
    echo "  Symlink: $TARGET_DIR/templates -> $CONDUCTOR_ROOT/templates"
done

echo ""
echo "Conductor skill installed successfully!"
echo ""
echo "Structure:"
for TARGET_DIR in "${TARGETS[@]}"; do
    ls -la "$TARGET_DIR" 2>/dev/null || true
done
echo ""
echo "The skill references the Conductor repo at: $CONDUCTOR_ROOT"
echo "Updates to the repo (git pull) will be reflected automatically."
echo ""
echo "Restart your AI CLI to load the skill."
