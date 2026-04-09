#!/bin/bash

###############################################################################
# Hook Generator Script
#
# Generate custom React hooks from templates
#
# Usage:
#   ./generate-hook.sh <HookName> <ApiEndpoint> [output-dir]
#
# Examples:
#   ./generate-hook.sh useUserData /api/users
#   ./generate-hook.sh useProducts /api/products ./src/hooks
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
HOOK_NAME=$1
API_ENDPOINT=$2
OUTPUT_DIR=${3:-"./src/hooks"}

# Validation
if [ -z "$HOOK_NAME" ]; then
  echo -e "${RED}Error: Hook name is required${NC}"
  echo "Usage: $0 <HookName> <ApiEndpoint> [output-dir]"
  exit 1
fi

if [ -z "$API_ENDPOINT" ]; then
  echo -e "${RED}Error: API endpoint is required${NC}"
  echo "Usage: $0 <HookName> <ApiEndpoint> [output-dir]"
  exit 1
fi

# Ensure hook name starts with 'use'
if [[ ! "$HOOK_NAME" =~ ^use[A-Z] ]]; then
  echo -e "${RED}Error: Hook name must start with 'use' followed by a capital letter${NC}"
  exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${BLUE}Generating hook: $HOOK_NAME${NC}"
echo -e "${BLUE}API endpoint: $API_ENDPOINT${NC}"
echo -e "${BLUE}Output directory: $OUTPUT_DIR${NC}"
echo ""

# Generate hook file
echo -e "${GREEN}Creating hook file...${NC}"
sed "s/{{HOOK_NAME}}/$HOOK_NAME/g; s|{{API_ENDPOINT}}|$API_ENDPOINT|g" \
  "$TEMPLATE_DIR/use-hook.ts.template" > "$OUTPUT_DIR/$HOOK_NAME.ts"
echo "  ✓ $HOOK_NAME.ts"

echo ""
echo -e "${GREEN}✓ Hook $HOOK_NAME generated successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Update response and request types"
echo "  2. Implement actual API call logic"
echo "  3. Configure query options as needed"
echo ""
echo -e "${BLUE}Import your hook:${NC}"
echo "  import { $HOOK_NAME } from '@/hooks/$HOOK_NAME';"
echo ""
