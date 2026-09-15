#!/bin/bash
# Rhino Instagram Tweak - Build & Repository Setup Script

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TWEAK_DIR="$REPO_DIR/tweak"
BUILD_DIR="$REPO_DIR/.build"
OUTPUT_DIR="$REPO_DIR/repo/pool/main/r"

echo "🦏 Rhino Instagram Tweak Build Script"
echo "======================================"

# Check for Theos
if [ ! -d "$THEOS" ]; then
    echo "❌ Theos not found. Please install Theos first:"
    echo "   git clone --recursive https://github.com/theos/theos.git ~/theos"
    echo "   export THEOS=~/theos"
    exit 1
fi

echo "✅ Theos found at: $THEOS"

# Clean previous builds
echo ""
echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR"

# Build tweak
echo ""
echo "🔨 Building tweak..."
cd "$TWEAK_DIR"
make clean 2>/dev/null || true
make package

# Find built .deb
DEB_FILE=$(find "$TWEAK_DIR"/.theos/obj -name "*.deb" 2>/dev/null | head -1)

if [ -z "$DEB_FILE" ]; then
    echo "❌ Build failed - no .deb file found"
    exit 1
fi

echo "✅ Build successful: $DEB_FILE"

# Copy to output
cp "$DEB_FILE" "$OUTPUT_DIR/"

# Generate Packages file
echo ""
echo "📦 Generating Packages file..."
cd "$REPO_DIR/repo"

# Generate Packages file with real SHA256
for deb in pool/main/r/*.deb; do
    if [ -f "$deb" ]; then
        SHA256=$(shasum -a 256 "$deb" | cut -d' ' -f1)
        SIZE=$(stat -f%z "$deb" 2>/dev/null || stat -c%s "$deb" 2>/dev/null)
        PKG=$(basename "$deb" .deb)

        # Extract version from filename
        VERSION=$(echo "$PKG" | sed 's/.*_\(.*\)_iphoneos-arm/\1/')

        cat > Packages << EOF
Package: com.rhino.instagram
Name: Rhino
Version: $VERSION
Architecture: iphoneos-arm
Maintainer: RhinoDev
Depends: mobilesubstrate, preferenceloader
Description: The ultimate Instagram enhancement tweak. Download stories, reels, videos, view stories anonymously, HiFi audio, disable ads and much more.
Section: Tweaks
Size: $SIZE
Filename: $deb
SHA256: $SHA256
Maintainer: RhinoDev
Name: Rhino

Package: com.rhino.prefs
Name: Rhino Prefs
Version: $VERSION
Architecture: iphoneos-arm
Maintainer: RhinoDev
Depends: preferenceloader, com.rhino.instagram
Description: Preference bundle for Rhino Instagram tweak
Section: Tweaks
Size: 0
Filename: pool/main/r/rhinoprefs_${VERSION}_iphoneos-arm.deb
SHA256: $SHA256
Name: Rhino Prefs
EOF
        break
    fi
done

# Generate bzip2 compressed Packages
echo "📦 Creating Packages.bz2..."
bzip2 -f Packages

echo ""
echo "✅ Build complete!"
echo ""
echo "📁 Repository structure:"
find "$REPO_DIR/repo" -type f | head -20
echo ""
echo "🚀 To host this repository:"
echo "   1. Upload the 'repo' folder to GitHub Pages or any web server"
echo "   2. Add the URL to Sileo/Zebra/Cydia"
echo "   3. URL format: https://your-domain.com/InstagramRepo/repo"
echo ""
echo "📋 Repository URL for package managers:"
echo "   https://your-repo-url.github.io/InstagramRepo/repo"
