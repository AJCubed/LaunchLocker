#!/bin/bash

set -euo pipefail

echo "🚀 Starting LaunchLocker installation..."
echo

# 0. Configure installation paths
APP_NAME="LaunchLocker.app"
ZIP_NAME="LaunchLocker.zip"

RELEASE_URL="https://github.com/AJCubed/LaunchLocker/releases/latest/download/${ZIP_NAME}"

INSTALL_DIR="$HOME/Applications"
CONFIG_DIR="$HOME/Library/Application Support/LaunchLocker"
CONFIG_FILE="$CONFIG_DIR/protectedList.txt"

PLIST_LABEL="com.launchlocker.applock"
PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_LABEL}.plist"

# 1. Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$HOME/Library/LaunchAgents"
TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

# 2. If existing version is running, stop it first
if launchctl print "gui/$(id -u)/${PLIST_LABEL}" >/dev/null 2>&1; then
    echo "🛑 Stopping existing LaunchLocker service..."
    echo
    launchctl bootout "gui/$(id -u)" "$PLIST_PATH" || true
fi

# 3. Download latest release]
echo "⬇️  Downloading latest release..."
echo

curl -fL "$RELEASE_URL" -o "$TMP_DIR/$ZIP_NAME"
unzip -q "$TMP_DIR/$ZIP_NAME" -d "$TMP_DIR"

if [ ! -d "$TMP_DIR/$APP_NAME" ]; then
    echo "❌ Failed to locate ${APP_NAME} in downloaded archive."
    exit 1
fi

# 4. Install application
echo "📁 Installing application..."
echo

rm -rf "$INSTALL_DIR/$APP_NAME"
mv "$TMP_DIR/$APP_NAME" "$INSTALL_DIR/"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "📝 Creating empty configuration file..."
    touch "$CONFIG_FILE"
fi

# 5. Create LaunchAgent
echo "⚙️  Creating LaunchAgent..."
echo

cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">

<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${PLIST_LABEL}</string>

    <key>ProgramArguments</key>
    <array>
        <string>${INSTALL_DIR}/${APP_NAME}/Contents/MacOS/LaunchLocker</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

# 6. Register LaunchAgent
echo "🔄 Registering LaunchLocker with launchctl..."
launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH"

# 7. Success!
echo
echo "Application: $INSTALL_DIR/$APP_NAME"
echo "Configuration: $CONFIG_FILE"
echo
echo "✅ To access your new blocklist, run:"
echo "  nano "$CONFIG_FILE""
echo "Reference the README for instructions on how to populate the list."
echo
echo "⚠️  Note: Don't forget to grant 'App Management' permissions in System Settings > Privacy & Security."
echo
echo "LaunchLocker installed successfully."
echo