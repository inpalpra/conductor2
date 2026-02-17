#!/bin/bash
# Install Conductor for OpenCode, Claude, Codex, Gemini CLI, Antigravity
# Usage: ./install.sh

set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "Installing Conductor..."

for dir in "$HOME/.opencode/skill/conductor" "$HOME/.claude/skills/conductor" "$HOME/.codex/skills/conductor"; do
    rm -rf "$dir"
    mkdir -p "$dir"
    cp "$ROOT/skill/SKILL.md" "$dir/"
    ln -s "$ROOT/commands" "$dir/commands"
    ln -s "$ROOT/templates" "$dir/templates"
    echo "  $dir"
done

dir="$HOME/.gemini/extensions/conductor"
rm -rf "$dir"
mkdir -p "$dir"
cp "$ROOT/GEMINI.md" "$dir/"
cp "$ROOT/gemini-extension.json" "$dir/"
ln -s "$ROOT/commands" "$dir/commands"
ln -s "$ROOT/templates" "$dir/templates"
echo "  $dir (Gemini CLI)"

dir="$HOME/.gemini/antigravity/skills/conductor"
rm -rf "$dir"
mkdir -p "$dir"
cp "$ROOT/skill/SKILL.md" "$dir/"
ln -s "$ROOT/commands" "$dir/commands"
ln -s "$ROOT/templates" "$dir/templates"
echo "  $dir"

echo "Done. Restart your AI shell."
