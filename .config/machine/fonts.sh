mkdir -p ~/.config/machine

cat > ~/.config/machine/fonts.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

FONT_DIR="$HOME/.local/share/fonts"
FONT_FAMILY="JetBrainsMono Nerd Font Mono"
ZIP_NAME="JetBrainsMono.zip"
ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

echo "🔤 Fonts: ensuring Nerd Font is installed ($FONT_FAMILY)"

mkdir -p "$FONT_DIR"

# If already installed, do nothing
if fc-list | grep -qi "$FONT_FAMILY"; then
  echo "✅ Fonts: already installed"
  exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "⬇️  Fonts: downloading Nerd Font..."
cd "$tmp"
curl -fLo "$ZIP_NAME" "$ZIP_URL"

echo "📦 Fonts: extracting to $FONT_DIR..."
unzip -o "$ZIP_NAME" -d "$FONT_DIR" >/dev/null

echo "🔄 Fonts: rebuilding font cache..."
fc-cache -fv >/dev/null

echo "🧪 Fonts: verifying..."
fc-match "$FONT_FAMILY" || true

echo "🎉 Fonts: done"
EOF

chmod +x ~/.config/machine/fonts.sh

