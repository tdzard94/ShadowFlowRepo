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
dpkg-scanpackages debs /dev/null 2>/dev/null > Packages.tmp || {
    echo -e "${RED}❌ Failed to generate Packages file${NC}"
    exit 1
}

# Process Packages - update depiction URLs if depiction files exist
echo -e "${YELLOW}🔗 Processing depiction URLs...${NC}"
{
    PKG_ID=""
    HAS_DEPICTION=false
    HAS_SILEO=false
    BUFFER=""
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Capture Package ID
        if [[ "$line" =~ ^Package:\ (.+)$ ]]; then
            PKG_ID="${BASH_REMATCH[1]}"
            HAS_DEPICTION=false
            HAS_SILEO=false
            BUFFER=""
        fi
        
        # Check if Depiction already exists
        if [[ "$line" =~ ^Depiction: ]]; then
            HAS_DEPICTION=true
            # Replace with correct URL if depiction file exists
            if [ -f "depictions/web/${PKG_ID}.html" ]; then
                echo "Depiction: ${REPO_URL}/depictions/web/${PKG_ID}.html"
                continue
            fi
        fi
        
        # Check if SileoDepiction already exists (case insensitive)
        if [[ "$line" =~ ^[Ss]ileodepiction: ]]; then
            HAS_SILEO=true
            # Replace with correct URL if depiction file exists
            if [ -f "depictions/native/${PKG_ID}/depiction.json" ]; then
                echo "SileoDepiction: ${REPO_URL}/depictions/native/${PKG_ID}/depiction.json"
                continue
            fi
        fi
        
        # On empty line (end of package entry), add missing depictions
        if [[ -z "$line" && -n "$PKG_ID" ]]; then
            if [[ "$HAS_DEPICTION" == false ]] && [ -f "depictions/web/${PKG_ID}.html" ]; then
                echo "Depiction: ${REPO_URL}/depictions/web/${PKG_ID}.html"
            fi
            if [[ "$HAS_SILEO" == false ]] && [ -f "depictions/native/${PKG_ID}/depiction.json" ]; then
                echo "SileoDepiction: ${REPO_URL}/depictions/native/${PKG_ID}/depiction.json"
            fi
            PKG_ID=""
        fi
        
        echo "$line"
    done
} < Packages.tmp > Packages

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
