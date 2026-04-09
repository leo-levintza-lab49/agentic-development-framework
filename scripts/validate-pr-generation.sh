#!/bin/bash
#
# validate-pr-generation.sh - Validate PR generation script and dependencies
#
# This script checks that all prerequisites are met before running
# the main PR generation script.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

print_header() {
    echo -e "\n${BLUE}==== $1 ====${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate tools
validate_tools() {
    print_header "Validating Required Tools"

    local required_tools=("gh" "git" "jq")

    for tool in "${required_tools[@]}"; do
        if command_exists "$tool"; then
            local version=""
            case "$tool" in
                gh) version=$(gh --version 2>&1 | head -1) ;;
                git) version=$(git --version) ;;
                jq) version=$(jq --version) ;;
            esac
            print_success "$tool installed: $version"
        else
            print_error "$tool not found (required)"
        fi
    done

    # Optional tools
    if command_exists "yq"; then
        print_success "yq installed: $(yq --version 2>&1 | head -1)"
    else
        print_warning "yq not found (optional but recommended for faster YAML parsing)"
    fi
}

# Validate GitHub authentication
validate_github_auth() {
    print_header "Validating GitHub Authentication"

    if ! command_exists "gh"; then
        print_error "GitHub CLI not installed, skipping auth check"
        return
    fi

    if gh auth status >/dev/null 2>&1; then
        local user=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
        print_success "GitHub CLI authenticated as: $user"

        # Check token scopes
        local scopes=$(gh auth status 2>&1 | grep "Token scopes" || echo "")
        if [[ "$scopes" == *"repo"* ]]; then
            print_success "Token has 'repo' scope (required)"
        else
            print_warning "Token may be missing 'repo' scope"
        fi
    else
        print_error "GitHub CLI not authenticated (run: gh auth login)"
    fi
}

# Validate script files
validate_scripts() {
    print_header "Validating Script Files"

    local main_script="$SCRIPT_DIR/generate-pr-history.sh"
    if [ -f "$main_script" ]; then
        print_success "Main script found: $(basename "$main_script")"

        # Check if executable
        if [ -x "$main_script" ]; then
            print_success "Main script is executable"
        else
            print_warning "Main script not executable (run: chmod +x $main_script)"
        fi

        # Check syntax
        if bash -n "$main_script" 2>/dev/null; then
            print_success "Main script syntax is valid"
        else
            print_error "Main script has syntax errors"
        fi
    else
        print_error "Main script not found: $main_script"
    fi
}

# Validate library files
validate_libraries() {
    print_header "Validating Library Files"

    local required_libs=(
        "utils.sh"
        "yaml-parser.sh"
        "pr-generator.sh"
        "template-engine.sh"
        "timeline-manager.sh"
        "dependency-resolver.sh"
    )

    for lib in "${required_libs[@]}"; do
        local lib_path="$SCRIPT_DIR/lib/$lib"
        if [ -f "$lib_path" ]; then
            print_success "Library found: $lib"

            # Check syntax
            if bash -n "$lib_path" 2>/dev/null; then
                print_success "  ✓ Syntax valid"
            else
                print_error "  ✗ Syntax errors in $lib"
            fi
        else
            print_error "Library not found: $lib"
        fi
    done
}

# Validate configuration files
validate_config() {
    print_header "Validating Configuration Files"

    local config_dir="$PROJECT_ROOT/config"

    if [ ! -d "$config_dir" ]; then
        print_error "Config directory not found: $config_dir"
        return
    fi

    print_success "Config directory found: $config_dir"

    # Check for YAML files
    local yaml_count=0

    for yaml_file in "$config_dir"/pr-definitions-*.yaml "$config_dir"/monorepo-pr-definitions.yaml; do
        if [ -f "$yaml_file" ]; then
            ((yaml_count++))
            print_success "Found: $(basename "$yaml_file")"

            # Validate YAML syntax if yq is available
            if command_exists "yq"; then
                if yq eval . "$yaml_file" >/dev/null 2>&1; then
                    print_success "  ✓ YAML syntax valid"

                    # Check for required sections
                    if yq eval '.metadata' "$yaml_file" >/dev/null 2>&1; then
                        print_success "  ✓ Has metadata section"
                    else
                        print_warning "  ⚠ Missing metadata section"
                    fi

                    if yq eval '.prs' "$yaml_file" >/dev/null 2>&1; then
                        local pr_count=$(yq eval '.prs | length' "$yaml_file")
                        print_success "  ✓ Has prs section ($pr_count PRs)"
                    else
                        print_error "  ✗ Missing prs section"
                    fi
                else
                    print_error "  ✗ YAML syntax invalid"
                fi
            fi
        fi
    done

    if [ $yaml_count -eq 0 ]; then
        print_error "No PR definition YAML files found"
    else
        print_success "Found $yaml_count PR definition files"
    fi

    # Check workspace config
    if [ -f "$config_dir/workspace.conf" ]; then
        print_success "Workspace configuration found"
    else
        print_warning "Workspace configuration not found (will use defaults)"
    fi
}

# Validate repository structure
validate_repositories() {
    print_header "Validating Repository Structure"

    # Check workspace config for paths
    local polybase_dir="${POLYBASE_LOCAL_DIR:-$HOME/wrk/polybase}"
    local omnibase_dir="${OMNIBASE_LOCAL_DIR:-$HOME/wrk/omnybase}"

    if [ -f "$PROJECT_ROOT/config/workspace.conf" ]; then
        source "$PROJECT_ROOT/config/workspace.conf"
        polybase_dir="${POLYBASE_LOCAL_DIR:-$HOME/wrk/polybase}"
        omnibase_dir="${OMNIBASE_LOCAL_DIR:-$HOME/wrk/omnybase}"
    fi

    # Check polybase directory
    if [ -d "$polybase_dir" ]; then
        print_success "Polybase directory found: $polybase_dir"

        local repo_count=$(find "$polybase_dir" -maxdepth 1 -type d -name "*" ! -name "." ! -name ".." | wc -l)
        print_info "  Found $repo_count repositories"
    else
        print_warning "Polybase directory not found: $polybase_dir"
        print_info "  Set POLYBASE_LOCAL_DIR or create directory"
    fi

    # Check omnibase directory
    if [ -d "$omnibase_dir" ]; then
        print_success "Omnibase directory found: $omnibase_dir"

        if [ -d "$omnibase_dir/enterprise-monorepo" ]; then
            print_success "  Monorepo found"
        else
            print_warning "  enterprise-monorepo not found"
        fi
    else
        print_warning "Omnibase directory not found: $omnibase_dir"
        print_info "  Set OMNIBASE_LOCAL_DIR or create directory"
    fi
}

# Validate templates
validate_templates() {
    print_header "Validating Code Generation Templates"

    local template_dir="$PROJECT_ROOT/templates/code-generation"

    if [ ! -d "$template_dir" ]; then
        print_error "Template directory not found: $template_dir"
        return
    fi

    print_success "Template directory found: $template_dir"

    # Check for template subdirectories
    local template_types=("java-spring-boot" "nodejs-typescript" "react" "database" "terraform" "kubernetes")

    for type in "${template_types[@]}"; do
        if [ -d "$template_dir/$type" ]; then
            local template_count=$(find "$template_dir/$type" -name "*.template" | wc -l)
            print_success "Found $type templates ($template_count files)"
        else
            print_warning "No $type template directory"
        fi
    done
}

# Validate environment
validate_environment() {
    print_header "Validating Environment Variables"

    if [ -n "${GITHUB_TOKEN:-}" ]; then
        print_success "GITHUB_TOKEN is set"
    else
        print_warning "GITHUB_TOKEN not set (may cause rate limiting)"
    fi

    if [ -n "${POLYBASE_LOCAL_DIR:-}" ]; then
        print_info "POLYBASE_LOCAL_DIR: $POLYBASE_LOCAL_DIR"
    else
        print_info "POLYBASE_LOCAL_DIR not set (will use default: $HOME/wrk/polybase)"
    fi

    if [ -n "${OMNIBASE_LOCAL_DIR:-}" ]; then
        print_info "OMNIBASE_LOCAL_DIR: $OMNIBASE_LOCAL_DIR"
    else
        print_info "OMNIBASE_LOCAL_DIR not set (will use default: $HOME/wrk/omnybase)"
    fi
}

# Print summary
print_summary() {
    print_header "Validation Summary"

    if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
        print_success "All validations passed! Ready to generate PRs."
        echo ""
        echo "Next steps:"
        echo "  1. Review configuration files in config/"
        echo "  2. Run dry-run: ./scripts/generate-pr-history.sh --dry-run"
        echo "  3. Execute: ./scripts/generate-pr-history.sh"
        echo ""
        return 0
    elif [ $ERRORS -eq 0 ]; then
        echo ""
        echo -e "${YELLOW}Validation completed with $WARNINGS warnings${NC}"
        echo "You can proceed, but some features may not work optimally."
        echo ""
        return 0
    else
        echo ""
        echo -e "${RED}Validation failed with $ERRORS errors and $WARNINGS warnings${NC}"
        echo "Please fix the errors before running the PR generation script."
        echo ""
        return 1
    fi
}

# Main execution
main() {
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║           PR GENERATION VALIDATION                        ║
║                                                           ║
║  Checking prerequisites and configuration                ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

EOF

    validate_tools
    validate_github_auth
    validate_scripts
    validate_libraries
    validate_config
    validate_repositories
    validate_templates
    validate_environment
    print_summary
}

main "$@"
