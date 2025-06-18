#!/bin/bash

# Usage: ./generate-macos-app-icons.sh your-icon.png

INPUT="$1"

if [ -z "$INPUT" ]; then
  echo "❌ Please provide the input PNG file."
  echo "Usage: $0 <icon-filename.png>"
  exit 1
fi

BASENAME=$(basename "$INPUT" .png)

mkdir -p appicon.iconset

sips -Z 512 "$INPUT" --out appicon.iconset/icon_512x512.png
sips -Z 256 "$INPUT" --out appicon.iconset/icon_256x256.png
sips -Z 128 "$INPUT" --out appicon.iconset/icon_128x128.png
sips -Z 64  "$INPUT" --out appicon.iconset/icon_64x64.png
sips -Z 32  "$INPUT" --out appicon.iconset/icon_32x32.png
sips -Z 16  "$INPUT" --out appicon.iconset/icon_16x16.png

sips -Z 1024 "$INPUT" --out appicon.iconset/icon_512x512@2x.png
sips -Z 512  "$INPUT" --out appicon.iconset/icon_256x256@2x.png
sips -Z 256  "$INPUT" --out appicon.iconset/icon_128x128@2x.png
sips -Z 128  "$INPUT" --out appicon.iconset/icon_64x64@2x.png
sips -Z 64   "$INPUT" --out appicon.iconset/icon_32x32@2x.png
sips -Z 32   "$INPUT" --out appicon.iconset/icon_16x16@2x.png

iconutil -c icns appicon.iconset -o "${BASENAME}.icns"

echo "🖼️ App icons generated in appicon.iconset"
