#!/bin/bash
# Install Conductor for multiple AI shells
# Copies only the essential LLM-facing files, ignoring repo metadata.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CONDUCTOR_ROOT="$(dirname "$SKILL_DIR")"

echo "Conductor Installer"
echo "==================="
echo ""

if [ ! -f "$CONDUCTOR_ROOT/commands/conductor/setup.toml" ]; then
    echo "Error: Run from within the Conductor repository."
    exit 1
fi

echo "Source: $CONDUCTOR_ROOT"
echo ""

ask_install() {
    local prompt="$1"
    while true; do
        read -p "$prompt [y/N]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* | "" ) return 1;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

install_skill() {
    local TARGET="$1"
    local CONTEXT_FILE="$2"
    echo "  Installing to $TARGET..."
    rm -rf "$TARGET"
    mkdir -p "$TARGET"
    cp "$CONTEXT_FILE" "$TARGET/SKILL.md"
    ln -s "$CONDUCTOR_ROOT/commands" "$TARGET/commands"
    ln -s "$CONDUCTOR_ROOT/templates" "$TARGET/templates"
}

install_gemini() {
    local TARGET="$1"
    echo "  Installing to $TARGET (Gemini CLI)..."
    rm -rf "$TARGET"
    mkdir -p "$TARGET"
    cp "$CONDUCTOR_ROOT/GEMINI.md" "$TARGET/GEMINI.md"
    cp "$CONDUCTOR_ROOT/gemini-extension.json" "$TARGET/gemini-extension.json"
    ln -s "$CONDUCTOR_ROOT/commands" "$TARGET/commands"
    ln -s "$CONDUCTOR_ROOT/templates" "$TARGET/templates"
}

install_copilot() {
    local TARGET="$HOME/.conductor2"
    echo "  Installing to $TARGET (GitHub Copilot)..."
    rm -rf "$TARGET"
    mkdir -p "$TARGET"
    
    ln -s "$CONDUCTOR_ROOT/commands" "$TARGET/commands"
    ln -s "$CONDUCTOR_ROOT/templates" "$TARGET/templates"
    ln -s "$CONDUCTOR_ROOT/skill" "$TARGET/skill"
    ln -s "$CONDUCTOR_ROOT/copilot-agent" "$TARGET/copilot-agent"

    INSTALL_DIR="$HOME/.local/bin"
    WRAPPER="$INSTALL_DIR/conductor-agent"
    mkdir -p "$INSTALL_DIR"

    cat > "$WRAPPER" <<WRAPPER_EOF
#!/usr/bin/env bash
set -euo pipefail

# Wrapper: prefer installed 'conductor' CLI, otherwise invoke repository's skill script
if command -v conductor >/dev/null 2>&1; then
  conductor "\$@"
else
  if [ -x "$TARGET/skill/scripts/run-conductor.sh" ]; then
    "$TARGET/skill/scripts/run-conductor.sh" "\$@"
  else
    echo "No conductor CLI available and no repository invoker found. Use the files in $TARGET/commands/conductor"
    exit 1
  fi
fi
WRAPPER_EOF

    chmod +x "$WRAPPER"
    echo "  Installed conductor-agent wrapper to: $WRAPPER"
}

echo "Select which AI agents to install Conductor for:"
echo ""

if ask_install "Install for OpenCode?"; then
    install_skill "$HOME/.opencode/skill/conductor" "$SKILL_DIR/SKILL.md"
fi
if ask_install "Install for Claude Code?"; then
    install_skill "$HOME/.claude/skills/conductor" "$SKILL_DIR/SKILL.md"
fi
if ask_install "Install for Codex?"; then
    install_skill "$HOME/.codex/skills/conductor" "$SKILL_DIR/SKILL.md"
fi
if ask_install "Install for Gemini CLI?"; then
    install_gemini "$HOME/.gemini/extensions/conductor"
fi
if ask_install "Install for Google Antigravity?"; then
    install_skill "$HOME/.gemini/antigravity/skills/conductor" "$SKILL_DIR/SKILL.md"
fi
if ask_install "Install for GitHub Copilot?"; then
    install_copilot
fi

echo ""
echo "Done."
echo "  commands/   -> setup, newTrack, implement, status, revert"
echo "  templates/  -> workflow.md, code_styleguides/"
echo ""
echo "Restart your AI shell to activate."
