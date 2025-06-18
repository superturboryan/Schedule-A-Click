#!/bin/bash

# Replace this with your app's bundle identifier
BUNDLE_ID="com.SuperTurboRyan.Schedule-A-Click"

echo "🧼 Resetting TCC (Privacy & Security) permissions for $BUNDLE_ID..."
tccutil reset All "$BUNDLE_ID"

echo "🏖️ Removing sandbox container at ~/Library/Containers/$BUNDLE_ID..."
rm -rf "$HOME/Library/Containers/$BUNDLE_ID"

echo "✅ Done. App has been reset to a clean state ✨"
