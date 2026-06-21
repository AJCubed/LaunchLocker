#!/bin/bash

set -e

# 0. Configure installation paths
INSTALL_DIR="$HOME/Library/Application Support/LaunchLocker"
BINARY_SOURCE="LaunchLocker.app"
PLIST_LABEL="com.launchlocker.applock"
PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_LABEL}.plist"

echo "Starting LaunchLocker Installation..."

# 1. Ensure the binary exists in the downloaded folder
if [ ! -d "$BINARY_SOURCE" ]; then
    echo "❌ Error: $BINARY_SOURCE not found in the current directory."
    echo "Please run this script from the directory containing LaunchLocker.app."
    exit 1
fi

# 2. If an older version is already running, stop it first
if launchctl print gui/$(id -u)/$PLIST_LABEL >/dev/null 2>&1; then
    echo "🛑 Stopping existing background service..."
    launchctl bootout gui/$(id -u) "$PLIST_PATH" || true
fi

# 3. Create a dedicated permanent directory and copy the application bundle
echo "Copying LaunchLocker to system directories..."
mkdir -p "$INSTALL_DIR"
cp -R "$BINARY_SOURCE" "$INSTALL_DIR/"

# 4. Dynamically generate the .plist file with correct absolute user paths
echo "Generating LaunchAgent configuration at $PLIST_PATH..."
cat << EOF > "$PLIST_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://apple.com">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${PLIST_LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${INSTALL_DIR}/${BINARY_SOURCE}/Contents/MacOS/LaunchLocker</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

# 5. Register and start the newly installed background agent
echo "Registering service with macOS launchctl..."
launchctl bootstrap gui/$(id -u) "$PLIST_PATH"

echo "✅ LaunchLocker is successfully installed and running in the background!"
echo "⚠️ Note: Don't forget to grant 'App Management' permissions in System Settings."