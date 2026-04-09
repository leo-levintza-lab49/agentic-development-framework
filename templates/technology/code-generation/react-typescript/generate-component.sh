#!/bin/bash

###############################################################################
# Component Generator Script
#
# Generate React/TypeScript components from templates
#
# Usage:
#   ./generate-component.sh <ComponentName> [output-dir] [--with-styles] [--with-test]
#
# Examples:
#   ./generate-component.sh Button
#   ./generate-component.sh UserCard ./src/components --with-styles --with-test
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR"

# Parse arguments
COMPONENT_NAME=$1
OUTPUT_DIR=${2:-"./src/components"}
WITH_STYLES=false
WITH_TEST=false

# Parse flags
for arg in "$@"; do
  case $arg in
    --with-styles)
      WITH_STYLES=true
      shift
      ;;
    --with-test)
      WITH_TEST=true
      shift
      ;;
  esac
done

# Validation
if [ -z "$COMPONENT_NAME" ]; then
  echo -e "${RED}Error: Component name is required${NC}"
  echo "Usage: $0 <ComponentName> [output-dir] [--with-styles] [--with-test]"
  exit 1
fi

# Check if component name is valid (PascalCase)
if ! [[ "$COMPONENT_NAME" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
  echo -e "${YELLOW}Warning: Component name should be in PascalCase (e.g., MyComponent)${NC}"
fi

# Create output directory
COMPONENT_DIR="$OUTPUT_DIR/$COMPONENT_NAME"
mkdir -p "$COMPONENT_DIR"

echo -e "${BLUE}Generating component: $COMPONENT_NAME${NC}"
echo -e "${BLUE}Output directory: $COMPONENT_DIR${NC}"
echo ""

# Generate main component file
echo -e "${GREEN}Creating component file...${NC}"
sed "s/{{COMPONENT_NAME}}/$COMPONENT_NAME/g; s/{{PROPS}}//g" \
  "$TEMPLATE_DIR/component.tsx.template" > "$COMPONENT_DIR/$COMPONENT_NAME.tsx"
echo "  ✓ $COMPONENT_NAME.tsx"

# Generate styles if requested
if [ "$WITH_STYLES" = true ]; then
  echo -e "${GREEN}Creating styles file...${NC}"
  sed "s/{{COMPONENT_NAME}}/$COMPONENT_NAME/g" \
    "$TEMPLATE_DIR/component.styles.ts.template" > "$COMPONENT_DIR/$COMPONENT_NAME.styles.ts"
  echo "  ✓ $COMPONENT_NAME.styles.ts"
fi

# Generate test if requested
if [ "$WITH_TEST" = true ]; then
  echo -e "${GREEN}Creating test file...${NC}"
  sed "s/{{COMPONENT_NAME}}/$COMPONENT_NAME/g" \
    "$TEMPLATE_DIR/component.test.tsx.template" > "$COMPONENT_DIR/$COMPONENT_NAME.test.tsx"
  echo "  ✓ $COMPONENT_NAME.test.tsx"
fi

# Generate index file for easier imports
echo -e "${GREEN}Creating index file...${NC}"
cat > "$COMPONENT_DIR/index.ts" << EOF
export { ${COMPONENT_NAME} } from './${COMPONENT_NAME}';
export type { ${COMPONENT_NAME}Props } from './${COMPONENT_NAME}';
EOF
echo "  ✓ index.ts"

echo ""
echo -e "${GREEN}✓ Component $COMPONENT_NAME generated successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Update the props interface in $COMPONENT_NAME.tsx"
echo "  2. Implement the component logic"
if [ "$WITH_STYLES" = true ]; then
  echo "  3. Customize styles in $COMPONENT_NAME.styles.ts"
fi
if [ "$WITH_TEST" = true ]; then
  echo "  4. Add tests in $COMPONENT_NAME.test.tsx"
fi
echo ""
echo -e "${BLUE}Import your component:${NC}"
echo "  import { $COMPONENT_NAME } from '@/components/$COMPONENT_NAME';"
echo ""
