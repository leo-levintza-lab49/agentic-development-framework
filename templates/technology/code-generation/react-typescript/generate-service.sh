#!/bin/bash

###############################################################################
# API Service Generator Script
#
# Generate API service classes from templates
#
# Usage:
#   ./generate-service.sh <ServiceName> <BaseURL> [output-dir]
#
# Examples:
#   ./generate-service.sh User https://api.example.com/v1
#   ./generate-service.sh Product https://api.example.com/v1 ./src/services
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
SERVICE_NAME=$1
BASE_URL=$2
OUTPUT_DIR=${3:-"./src/services"}

# Validation
if [ -z "$SERVICE_NAME" ]; then
  echo -e "${RED}Error: Service name is required${NC}"
  echo "Usage: $0 <ServiceName> <BaseURL> [output-dir]"
  exit 1
fi

if [ -z "$BASE_URL" ]; then
  echo -e "${RED}Error: Base URL is required${NC}"
  echo "Usage: $0 <ServiceName> <BaseURL> [output-dir]"
  exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${BLUE}Generating service: $SERVICE_NAME${NC}"
echo -e "${BLUE}Base URL: $BASE_URL${NC}"
echo -e "${BLUE}Output directory: $OUTPUT_DIR${NC}"
echo ""

# Generate service file
echo -e "${GREEN}Creating service file...${NC}"
sed "s/{{SERVICE_NAME}}/$SERVICE_NAME/g; s|{{BASE_URL}}|$BASE_URL|g" \
  "$TEMPLATE_DIR/api-service.ts.template" > "$OUTPUT_DIR/${SERVICE_NAME}Service.ts"
echo "  ✓ ${SERVICE_NAME}Service.ts"

echo ""
echo -e "${GREEN}✓ Service $SERVICE_NAME generated successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Add type-specific methods to the service"
echo "  2. Configure request/response interceptors"
echo "  3. Handle authentication tokens"
echo ""
echo -e "${BLUE}Usage:${NC}"
echo "  import { ${SERVICE_NAME}Api } from '@/services/${SERVICE_NAME}Service';"
echo ""
echo "  // GET request"
echo "  const response = await ${SERVICE_NAME}Api.get('/endpoint');"
echo ""
echo "  // POST request"
echo "  const response = await ${SERVICE_NAME}Api.post('/endpoint', { data });"
echo ""
