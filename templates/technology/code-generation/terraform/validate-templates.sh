#!/bin/bash

# Terraform Template Validation Script
# Purpose: Validate all templates are complete and properly formatted

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "======================================"
echo "Terraform Template Validation"
echo "======================================"
echo ""

# Check if templates exist
echo "Checking template files..."
TEMPLATES=(
    "main.tf.template"
    "variables.tf.template"
    "outputs.tf.template"
    "vpc.tf.template"
    "eks.tf.template"
    "rds.tf.template"
    "s3.tf.template"
    "alb.tf.template"
    "security-group.tf.template"
    "iam-role.tf.template"
)

MISSING_COUNT=0
for template in "${TEMPLATES[@]}"; do
    if [ -f "$template" ]; then
        echo -e "${GREEN}✓${NC} Found: $template"
    else
        echo -e "${RED}✗${NC} Missing: $template"
        ((MISSING_COUNT++))
    fi
done

if [ $MISSING_COUNT -gt 0 ]; then
    echo -e "\n${RED}Error: $MISSING_COUNT template(s) missing!${NC}"
    exit 1
fi

echo -e "\n${GREEN}All templates found!${NC}\n"

# Check documentation files
echo "Checking documentation files..."
DOCS=(
    "README.md"
    "QUICK_REFERENCE.md"
    "GETTING_STARTED.md"
    "INDEX.md"
)

DOC_MISSING_COUNT=0
for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        echo -e "${GREEN}✓${NC} Found: $doc"
    else
        echo -e "${RED}✗${NC} Missing: $doc"
        ((DOC_MISSING_COUNT++))
    fi
done

if [ $DOC_MISSING_COUNT -gt 0 ]; then
    echo -e "\n${YELLOW}Warning: $DOC_MISSING_COUNT documentation file(s) missing${NC}"
fi

echo -e "\n${GREEN}Documentation check complete!${NC}\n"

# Check for common placeholders in templates
echo "Checking for placeholder consistency..."
PLACEHOLDERS=(
    "{{PROJECT_NAME}}"
    "{{ENVIRONMENT}}"
    "{{REGION}}"
    "{{ACCOUNT_ID}}"
)

for placeholder in "${PLACEHOLDERS[@]}"; do
    count=$(grep -r "$placeholder" *.template 2>/dev/null | wc -l)
    if [ $count -gt 0 ]; then
        echo -e "${GREEN}✓${NC} $placeholder found in templates ($count occurrences)"
    else
        echo -e "${YELLOW}⚠${NC} $placeholder not found (might be optional)"
    fi
done

echo ""

# Check template file sizes
echo "Checking template sizes..."
for template in "${TEMPLATES[@]}"; do
    if [ -f "$template" ]; then
        size=$(wc -c < "$template")
        if [ $size -lt 1000 ]; then
            echo -e "${YELLOW}⚠${NC} $template is suspiciously small ($size bytes)"
        else
            echo -e "${GREEN}✓${NC} $template size: $size bytes"
        fi
    fi
done

echo ""

# Check for syntax issues (basic checks)
echo "Checking for common syntax issues..."
ISSUES_FOUND=0

# Check for unclosed braces
for template in "${TEMPLATES[@]}"; do
    if [ -f "$template" ]; then
        open_braces=$(grep -o '{' "$template" | wc -l)
        close_braces=$(grep -o '}' "$template" | wc -l)

        if [ $open_braces -ne $close_braces ]; then
            echo -e "${RED}✗${NC} $template: Mismatched braces (open: $open_braces, close: $close_braces)"
            ((ISSUES_FOUND++))
        fi
    fi
done

# Check for common typos in resource names
TYPO_PATTERNS=(
    "resouce"
    "varriable"
    "ouput"
    "moduel"
)

for template in "${TEMPLATES[@]}"; do
    if [ -f "$template" ]; then
        for typo in "${TYPO_PATTERNS[@]}"; do
            if grep -qi "$typo" "$template"; then
                echo -e "${RED}✗${NC} $template: Found potential typo: $typo"
                ((ISSUES_FOUND++))
            fi
        done
    fi
done

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No common syntax issues found"
else
    echo -e "${RED}✗${NC} Found $ISSUES_FOUND potential issue(s)"
fi

echo ""

# Summary statistics
echo "======================================"
echo "Summary Statistics"
echo "======================================"
echo "Templates: $(ls -1 *.template 2>/dev/null | wc -l)"
echo "Documentation: $(ls -1 *.md 2>/dev/null | wc -l)"
echo "Scripts: $(ls -1 *.sh 2>/dev/null | wc -l)"
echo "Total Files: $(ls -1 | wc -l)"
echo "Total Size: $(du -sh . | awk '{print $1}')"
echo "Total Lines: $(cat *.template *.md 2>/dev/null | wc -l)"
echo ""

# Resource counting
echo "Resource Types by Template:"
for template in "${TEMPLATES[@]}"; do
    if [ -f "$template" ]; then
        resource_count=$(grep -c "^resource" "$template" 2>/dev/null || echo 0)
        data_count=$(grep -c "^data" "$template" 2>/dev/null || echo 0)
        echo "  $template: $resource_count resources, $data_count data sources"
    fi
done

echo ""

# Final result
if [ $MISSING_COUNT -eq 0 ] && [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}======================================"
    echo "✓ All validations passed!"
    echo "======================================${NC}"
    exit 0
else
    echo -e "${RED}======================================"
    echo "✗ Validation completed with issues"
    echo "======================================${NC}"
    exit 1
fi
