#!/bin/bash

###############################################################################
# Context Generator Script
#
# Generate React Context providers from templates
#
# Usage:
#   ./generate-context.sh <ContextName> [output-dir]
#
# Examples:
#   ./generate-context.sh Auth
#   ./generate-context.sh Theme ./src/contexts
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
CONTEXT_NAME=$1
OUTPUT_DIR=${2:-"./src/contexts"}

# Validation
if [ -z "$CONTEXT_NAME" ]; then
  echo -e "${RED}Error: Context name is required${NC}"
  echo "Usage: $0 <ContextName> [output-dir]"
  exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${BLUE}Generating context: $CONTEXT_NAME${NC}"
echo -e "${BLUE}Output directory: $OUTPUT_DIR${NC}"
echo ""

# Generate context file
echo -e "${GREEN}Creating context file...${NC}"
sed "s/{{CONTEXT_NAME}}/$CONTEXT_NAME/g" \
  "$TEMPLATE_DIR/context.tsx.template" > "$OUTPUT_DIR/${CONTEXT_NAME}Context.tsx"
echo "  ✓ ${CONTEXT_NAME}Context.tsx"

echo ""
echo -e "${GREEN}✓ Context $CONTEXT_NAME generated successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Update state interface with your properties"
echo "  2. Add action types to the reducer"
echo "  3. Implement reducer logic"
echo "  4. Wrap your app with the provider"
echo ""
echo -e "${BLUE}Usage:${NC}"
echo "  // Wrap your app"
echo "  import { ${CONTEXT_NAME}Provider } from '@/contexts/${CONTEXT_NAME}Context';"
echo ""
echo "  <${CONTEXT_NAME}Provider>"
echo "    <App />"
echo "  </${CONTEXT_NAME}Provider>"
echo ""
echo "  // Use in components"
echo "  import { use${CONTEXT_NAME} } from '@/contexts/${CONTEXT_NAME}Context';"
echo ""
echo "  const { state, actions } = use${CONTEXT_NAME}();"
echo ""
