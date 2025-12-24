#!/bin/bash

# ═══════════════════════════════════════════════════════════
#  ShadowFlow Repo - Package Builder
#  Generates Packages files for Cydia/Sileo repository
# ═══════════════════════════════════════════════════════════

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
REPO_URL="https://shadowflow-repo.zios.tools"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${PURPLE}"
echo "═══════════════════════════════════════════════════════════"
echo "       🌑 ShadowFlow Repo Builder"
echo "═══════════════════════════════════════════════════════════"
echo -e "${NC}"

cd "$REPO_DIR"

# Check if debs folder exists
if [ ! -d "debs" ]; then
    echo -e "${RED}❌ Error: debs/ folder not found${NC}"
    exit 1
fi

# Count .deb files
DEB_COUNT=$(find debs -name "*.deb" 2>/dev/null | wc -l | tr -d ' ')

if [ "$DEB_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No .deb files found in debs/ folder${NC}"
    exit 1
fi

echo -e "${CYAN}📦 Found ${DEB_COUNT} package(s) in debs/${NC}"
echo ""

# List packages
echo -e "${BLUE}Packages:${NC}"
for deb in debs/*.deb; do
    if [ -f "$deb" ]; then
        echo -e "   • $(basename "$deb")"
    fi
done
echo ""

# Generate Packages file
echo -e "${YELLOW}🔧 Generating Packages file...${NC}"
dpkg-scanpackages debs /dev/null > Packages.tmp 2>&1 || {
    echo -e "${RED}❌ Failed to generate Packages file${NC}"
    exit 1
}

# Add depiction URLs to Packages
echo -e "${YELLOW}🔗 Adding depiction URLs...${NC}"
while IFS= read -r line; do
    echo "$line"
    # After Package line, check if we have depiction for it
    if [[ "$line" =~ ^Package:\ (.+)$ ]]; then
        PKG_ID="${BASH_REMATCH[1]}"
    fi
    # Add depictions after the last field before empty line
    if [[ -z "$line" && -n "$PKG_ID" ]]; then
        # Check if depiction exists
        if [ -f "depictions/web/${PKG_ID}.html" ]; then
            echo "Depiction: ${REPO_URL}/depictions/web/${PKG_ID}.html"
        fi
        if [ -f "depictions/native/${PKG_ID}/depiction.json" ]; then
            echo "SileoDepiction: ${REPO_URL}/depictions/native/${PKG_ID}/depiction.json"
        fi
        echo ""
        PKG_ID=""
    fi
done < Packages.tmp > Packages

# Remove temp file
rm -f Packages.tmp

# Create compressed versions
echo -e "${YELLOW}🗜️  Creating compressed versions...${NC}"
bzip2 -k -f Packages
xz -k -f Packages  
gzip -k -f Packages

# Optional: Create zstd if available
if command -v zstd &> /dev/null; then
    zstd -k -f Packages 2>/dev/null
    echo -e "   ${GREEN}✓${NC} Packages.zst"
fi

echo -e "   ${GREEN}✓${NC} Packages"
echo -e "   ${GREEN}✓${NC} Packages.bz2"
echo -e "   ${GREEN}✓${NC} Packages.xz"
echo -e "   ${GREEN}✓${NC} Packages.gz"
echo ""

# Show package info
echo -e "${BLUE}📋 Package Info:${NC}"
echo "─────────────────────────────────────────────────────────"
cat Packages
echo "─────────────────────────────────────────────────────────"
echo ""

# Show file sizes
echo -e "${BLUE}📊 Generated Files:${NC}"
ls -lh Packages* | awk '{print "   " $9 " (" $5 ")"}'
echo ""

# Show depictions
if [ -d "depictions" ]; then
    echo -e "${BLUE}🎨 Depictions:${NC}"
    find depictions -type f \( -name "*.json" -o -name "*.html" \) | while read f; do
        echo -e "   ${GREEN}✓${NC} $f"
    done
    echo ""
fi

echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}       ✅ Build completed successfully!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo -e "   1. git add ."
echo -e "   2. git commit -m \"Update packages\""
echo -e "   3. git push"
echo ""
