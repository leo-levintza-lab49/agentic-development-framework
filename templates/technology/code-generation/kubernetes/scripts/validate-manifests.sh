#!/usr/bin/env bash
#
# Kubernetes Manifest Validator
# Validates Kubernetes manifests using kubectl, kubeval, or kustomize
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
print_error() { echo -e "${RED}[ERROR]${NC} $*"; }
print_success() { echo -e "${BLUE}[SUCCESS]${NC} $*"; }

# Usage information
usage() {
    cat <<EOF
Usage: $0 [OPTIONS] MANIFEST_FILE...

Validate Kubernetes manifests using multiple validation tools.

OPTIONS:
    -d, --directory DIR     Validate all YAML files in directory
    -t, --tool TOOL         Validation tool (kubectl, kubeval, all)
    -s, --strict            Enable strict validation
    -h, --help              Show this help message

EXAMPLES:
    # Validate single manifest
    $0 deployment.yaml

    # Validate all manifests in directory
    $0 -d ./manifests

    # Validate with specific tool
    $0 -t kubeval deployment.yaml

    # Strict validation
    $0 -s deployment.yaml

EOF
    exit 1
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Validate with kubectl
validate_kubectl() {
    local file="$1"
    local strict="${2:-false}"

    if ! command_exists kubectl; then
        print_warn "kubectl not found, skipping kubectl validation"
        return 0
    fi

    print_info "Validating with kubectl: $file"

    local kubectl_args="--dry-run=client"
    if [[ "$strict" == "true" ]]; then
        kubectl_args="$kubectl_args --validate=strict"
    fi

    if kubectl apply $kubectl_args -f "$file" 2>&1 | grep -q "error"; then
        print_error "kubectl validation failed for: $file"
        return 1
    else
        print_success "kubectl validation passed: $file"
        return 0
    fi
}

# Validate with kubeval
validate_kubeval() {
    local file="$1"
    local strict="${2:-false}"

    if ! command_exists kubeval; then
        print_warn "kubeval not found, skipping kubeval validation"
        return 0
    fi

    print_info "Validating with kubeval: $file"

    local kubeval_args="--strict"
    if [[ "$strict" == "true" ]]; then
        kubeval_args="$kubeval_args --ignore-missing-schemas"
    fi

    if kubeval $kubeval_args "$file"; then
        print_success "kubeval validation passed: $file"
        return 0
    else
        print_error "kubeval validation failed for: $file"
        return 1
    fi
}

# Validate YAML syntax
validate_yaml() {
    local file="$1"

    print_info "Validating YAML syntax: $file"

    if command_exists yamllint; then
        if yamllint -d relaxed "$file"; then
            print_success "YAML syntax valid: $file"
            return 0
        else
            print_error "YAML syntax invalid: $file"
            return 1
        fi
    elif command_exists python3; then
        if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
            print_success "YAML syntax valid: $file"
            return 0
        else
            print_error "YAML syntax invalid: $file"
            return 1
        fi
    else
        print_warn "No YAML validator found, skipping YAML validation"
        return 0
    fi
}

# Check for common issues
check_common_issues() {
    local file="$1"

    print_info "Checking for common issues: $file"

    local issues=0

    # Check for missing resource limits
    if ! grep -q "resources:" "$file" || ! grep -q "limits:" "$file"; then
        print_warn "Missing resource limits in: $file"
        ((issues++))
    fi

    # Check for missing liveness/readiness probes in Deployments
    if grep -q "kind: Deployment" "$file"; then
        if ! grep -q "livenessProbe:" "$file"; then
            print_warn "Missing livenessProbe in Deployment: $file"
            ((issues++))
        fi
        if ! grep -q "readinessProbe:" "$file"; then
            print_warn "Missing readinessProbe in Deployment: $file"
            ((issues++))
        fi
    fi

    # Check for latest tag
    if grep -q "image:.*:latest" "$file"; then
        print_warn "Using 'latest' tag is not recommended: $file"
        ((issues++))
    fi

    # Check for pull policy with latest tag
    if grep -q "imagePullPolicy: IfNotPresent" "$file" && grep -q ":latest" "$file"; then
        print_warn "IfNotPresent with :latest tag may cause issues: $file"
        ((issues++))
    fi

    # Check for security context
    if grep -q "kind: Deployment\|kind: StatefulSet\|kind: DaemonSet" "$file"; then
        if ! grep -q "securityContext:" "$file"; then
            print_warn "Missing securityContext: $file"
            ((issues++))
        fi
    fi

    if [[ $issues -eq 0 ]]; then
        print_success "No common issues found: $file"
    else
        print_info "Found $issues potential issues in: $file"
    fi

    return 0
}

# Validate single file
validate_file() {
    local file="$1"
    local tool="${2:-all}"
    local strict="${3:-false}"

    if [[ ! -f "$file" ]]; then
        print_error "File not found: $file"
        return 1
    fi

    if [[ ! "$file" =~ \.(yaml|yml)$ ]]; then
        print_warn "Skipping non-YAML file: $file"
        return 0
    fi

    print_info "Validating: $file"
    echo "---"

    local validation_failed=false

    # YAML syntax validation
    if ! validate_yaml "$file"; then
        validation_failed=true
    fi

    # Tool-specific validation
    case "$tool" in
        kubectl)
            if ! validate_kubectl "$file" "$strict"; then
                validation_failed=true
            fi
            ;;
        kubeval)
            if ! validate_kubeval "$file" "$strict"; then
                validation_failed=true
            fi
            ;;
        all)
            if ! validate_kubectl "$file" "$strict"; then
                validation_failed=true
            fi
            if ! validate_kubeval "$file" "$strict"; then
                validation_failed=true
            fi
            ;;
    esac

    # Common issues check
    check_common_issues "$file"

    echo ""

    if [[ "$validation_failed" == "true" ]]; then
        return 1
    fi

    return 0
}

# Validate directory
validate_directory() {
    local dir="$1"
    local tool="$2"
    local strict="$3"

    if [[ ! -d "$dir" ]]; then
        print_error "Directory not found: $dir"
        return 1
    fi

    print_info "Validating all YAML files in: $dir"

    local total=0
    local failed=0

    while IFS= read -r -d '' file; do
        ((total++))
        if ! validate_file "$file" "$tool" "$strict"; then
            ((failed++))
        fi
    done < <(find "$dir" -type f \( -name "*.yaml" -o -name "*.yml" \) -print0)

    echo "================================"
    print_info "Validation Summary"
    echo "Total files: $total"
    echo "Failed: $failed"
    echo "Passed: $((total - failed))"
    echo "================================"

    if [[ $failed -gt 0 ]]; then
        return 1
    fi

    return 0
}

# Main function
main() {
    local directory=""
    local tool="all"
    local strict=false
    local files=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--directory)
                directory="$2"
                shift 2
                ;;
            -t|--tool)
                tool="$2"
                shift 2
                ;;
            -s|--strict)
                strict=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                files+=("$1")
                shift
                ;;
        esac
    done

    # Validate directory if specified
    if [[ -n "$directory" ]]; then
        validate_directory "$directory" "$tool" "$strict"
        exit $?
    fi

    # Validate files if specified
    if [[ ${#files[@]} -eq 0 ]]; then
        print_error "No files or directory specified"
        usage
    fi

    local failed=0
    for file in "${files[@]}"; do
        if ! validate_file "$file" "$tool" "$strict"; then
            ((failed++))
        fi
    done

    if [[ $failed -gt 0 ]]; then
        print_error "$failed file(s) failed validation"
        exit 1
    fi

    print_success "All files validated successfully"
}

# Run main function
main "$@"
