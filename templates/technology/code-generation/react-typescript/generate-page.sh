#!/bin/bash

###############################################################################
# Page Generator Script
#
# Generate React page components from templates
#
# Usage:
#   ./generate-page.sh <PageName> [output-dir]
#
# Examples:
#   ./generate-page.sh Dashboard
#   ./generate-page.sh UserProfile ./src/pages
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR"

# Parse arguments
PAGE_NAME=$1
OUTPUT_DIR=${2:-"./src/pages"}

# Validation
if [ -z "$PAGE_NAME" ]; then
  echo -e "${RED}Error: Page name is required${NC}"
  echo "Usage: $0 <PageName> [output-dir]"
  exit 1
fi

# Create output directory
PAGE_DIR="$OUTPUT_DIR/$PAGE_NAME"
mkdir -p "$PAGE_DIR"

echo -e "${BLUE}Generating page: $PAGE_NAME${NC}"
echo -e "${BLUE}Output directory: $PAGE_DIR${NC}"
echo ""

# Generate page file
echo -e "${GREEN}Creating page file...${NC}"
sed "s/{{PAGE_NAME}}/$PAGE_NAME/g" \
  "$TEMPLATE_DIR/page.tsx.template" > "$PAGE_DIR/$PAGE_NAME.tsx"
echo "  ✓ $PAGE_NAME.tsx"

# Generate index file
echo -e "${GREEN}Creating index file...${NC}"
cat > "$PAGE_DIR/index.ts" << EOF
export { ${PAGE_NAME} } from './${PAGE_NAME}';
EOF
echo "  ✓ index.ts"

echo ""
echo -e "${GREEN}✓ Page $PAGE_NAME generated successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Implement data fetching logic"
echo "  2. Add page-specific components"
echo "  3. Update SEO meta tags"
echo "  4. Add route to your router configuration"
echo ""
