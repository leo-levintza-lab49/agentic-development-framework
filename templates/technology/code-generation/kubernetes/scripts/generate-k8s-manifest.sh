#!/usr/bin/env bash
#
# Kubernetes Manifest Generator
# Generates Kubernetes manifests from templates with placeholder replacement
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/.."
OUTPUT_DIR="${OUTPUT_DIR:-./manifests}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print functions
print_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
print_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Usage information
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Generate Kubernetes manifests from templates.

OPTIONS:
    -t, --template TEMPLATE     Template name (deployment, service, etc.)
    -c, --config CONFIG_FILE    Configuration file with placeholder values
    -o, --output OUTPUT_FILE    Output file path
    -d, --dry-run              Print output to stdout instead of file
    -h, --help                 Show this help message

EXAMPLES:
    # Generate deployment manifest
    $0 -t deployment -c app-config.env -o deployment.yaml

    # Generate service manifest (dry-run)
    $0 -t service -c app-config.env -d

    # Generate all manifests
    $0 -c app-config.env

CONFIGURATION FILE FORMAT:
    Key-value pairs, one per line:
    APP_NAME=my-app
    IMAGE=nginx:latest
    REPLICAS=3
    CPU_REQUEST=100m
    MEMORY_REQUEST=128Mi

AVAILABLE TEMPLATES:
    - deployment
    - service
    - configmap
    - secret
    - ingress
    - hpa
    - statefulset
    - pvc
    - job
    - cronjob
    - daemonset
    - namespace

EOF
    exit 1
}

# Load configuration file
load_config() {
    local config_file="$1"

    if [[ ! -f "$config_file" ]]; then
        print_error "Configuration file not found: $config_file"
        exit 1
    fi

    print_info "Loading configuration from: $config_file"

    # Source the config file
    # shellcheck disable=SC1090
    source "$config_file"
}

# Replace placeholders in template
replace_placeholders() {
    local template_file="$1"
    local output=""

    if [[ ! -f "$template_file" ]]; then
        print_error "Template file not found: $template_file"
        exit 1
    fi

    output=$(cat "$template_file")

    # Get all environment variables and replace placeholders
    while IFS='=' read -r key value; do
        if [[ -n "$key" && ! "$key" =~ ^# ]]; then
            # Escape special characters in value
            value=$(echo "$value" | sed 's/[&/\]/\\&/g')
            output=$(echo "$output" | sed "s|{{${key}}}|${value}|g")
        fi
    done < <(env)

    echo "$output"
}

# Generate manifest
generate_manifest() {
    local template="$1"
    local config_file="$2"
    local output_file="${3:-}"
    local dry_run="${4:-false}"

    local template_file="${TEMPLATE_DIR}/${template}.yaml.template"

    if [[ ! -f "$template_file" ]]; then
        print_error "Template not found: $template_file"
        return 1
    fi

    print_info "Generating manifest from template: $template"

    # Load configuration
    load_config "$config_file"

    # Generate manifest with placeholder replacement
    local manifest
    manifest=$(replace_placeholders "$template_file")

    # Output handling
    if [[ "$dry_run" == "true" ]]; then
        print_info "Dry-run output:"
        echo "---"
        echo "$manifest"
    else
        if [[ -z "$output_file" ]]; then
            output_file="${OUTPUT_DIR}/${template}.yaml"
        fi

        # Create output directory
        mkdir -p "$(dirname "$output_file")"

        # Write manifest
        echo "$manifest" > "$output_file"
        print_info "Manifest written to: $output_file"
    fi
}

# Generate all common manifests
generate_all() {
    local config_file="$1"
    local templates=("deployment" "service" "configmap" "ingress" "hpa")

    print_info "Generating all common manifests..."

    for template in "${templates[@]}"; do
        local output_file="${OUTPUT_DIR}/${template}.yaml"
        generate_manifest "$template" "$config_file" "$output_file" "false" || true
    done

    print_info "All manifests generated in: $OUTPUT_DIR"
}

# Validate manifest
validate_manifest() {
    local manifest_file="$1"

    if ! command -v kubectl &> /dev/null; then
        print_warn "kubectl not found, skipping validation"
        return 0
    fi

    print_info "Validating manifest: $manifest_file"

    if kubectl apply --dry-run=client -f "$manifest_file" &> /dev/null; then
        print_info "Validation successful"
        return 0
    else
        print_error "Validation failed"
        return 1
    fi
}

# Main function
main() {
    local template=""
    local config_file=""
    local output_file=""
    local dry_run=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--template)
                template="$2"
                shift 2
                ;;
            -c|--config)
                config_file="$2"
                shift 2
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$config_file" ]]; then
        print_error "Configuration file is required"
        usage
    fi

    # Generate manifest(s)
    if [[ -z "$template" ]]; then
        generate_all "$config_file"
    else
        generate_manifest "$template" "$config_file" "$output_file" "$dry_run"
    fi
}

# Run main function
main "$@"
