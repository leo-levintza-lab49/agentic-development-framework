# YAML Parser Library for Bash

A robust YAML parsing library for reading PR configuration files in bash scripts.

## Requirements

- **Bash 4.0+** (required for associative arrays)
- Optional: `yq` for improved parsing performance
- Optional: Python 3 with PyYAML for fallback parsing

The library automatically detects bash 3.x and attempts to upgrade to bash 4+ if available (e.g., via Homebrew on macOS).

## Installation

Source the library in your bash script:

```bash
source "path/to/yaml-parser.sh"
```

## Features

- Pure bash YAML parsing (no external dependencies required)
- Stores PR configurations in global associative arrays for fast access
- Caches full PR YAML blocks for retrieval
- Multiple parsing strategies (yq, Python, pure bash)
- Field extraction, filtering, and validation
- Compatible with multi-file PR definition sets

## Data Structures

The library uses three global data structures:

```bash
declare -A PR_CONFIGS      # Associative array: PR_CONFIGS["1_repo"]="db-schemas"
declare -a ALL_PRS         # Regular array: ALL_PRS=(1 2 3 4 ...)
declare -A PR_DATA_CACHE   # Associative array: PR_DATA_CACHE["1"]="<full yaml>"
```

## Core Functions

### Parse and Load

#### `parse_yaml_file <yaml_file>`
Parses a single YAML file and populates global arrays.

```bash
parse_yaml_file "$PROJECT_ROOT/config/pr-definitions-month1-2.yaml"
```

#### `load_all_pr_configs [config_dir]`
Loads all PR configuration files from a directory.

```bash
load_all_pr_configs "$PROJECT_ROOT/config"
```

Note: Will fail if duplicate PR IDs are detected across files.

### Query Functions

#### `get_pr_count`
Returns the total number of PRs loaded.

```bash
count=$(get_pr_count)
echo "Loaded $count PRs"
```

#### `get_all_pr_ids`
Returns all PR IDs (one per line).

```bash
for pr_id in $(get_all_pr_ids); do
    echo "Processing PR #$pr_id"
done
```

#### `get_pr_field <pr_id> <field_name>`
Extracts a specific field from a PR configuration.

```bash
title=$(get_pr_field 1 title)
repo=$(get_pr_field 1 repo)
team=$(get_pr_field 1 team)
branch=$(get_pr_field 1 branch)
complexity=$(get_pr_field 1 complexity)
created=$(get_pr_field 1 created)
review_hours=$(get_pr_field 1 review_hours)
dependencies=$(get_pr_field 1 dependencies)
```

#### `get_pr_config <pr_id>`
Returns the full YAML block for a PR.

```bash
config=$(get_pr_config 1)
echo "$config"
```

#### `get_pr_dependencies <pr_id>`
Returns space-separated list of dependency PR IDs.

```bash
deps=$(get_pr_dependencies 2)
# Returns: "1"
```

#### `get_pr_files <pr_id>`
Returns newline-separated list of files for a PR.

```bash
get_pr_files 1
# Returns:
# schemas/users.sql
# migrations/001_create_users_table.sql
# docs/schema-users.md
```

### Filter Functions

#### `get_prs_by_repo <repo_name>`
Returns PR IDs for a specific repository.

```bash
for pr_id in $(get_prs_by_repo 'db-schemas'); do
    echo "PR #$pr_id is for db-schemas"
done
```

#### `get_prs_by_team <team_name>`
Returns PR IDs for a specific team.

```bash
backend_prs=$(get_prs_by_team 'backend' | paste -sd ',' -)
echo "Backend PRs: $backend_prs"
```

#### `get_prs_by_complexity <complexity_level>`
Returns PR IDs matching a complexity level.

```bash
senior_prs=$(get_prs_by_complexity 'senior-level')
```

### Utility Functions

#### `print_pr_summary <pr_id>`
Prints a formatted summary of a PR.

```bash
print_pr_summary 1
# Output:
# PR #1: Add user schema with audit fields
#   Repository: db-schemas
#   Team: data-platform
#   Branch: schema/v1.0.0/user-table
#   Complexity: mid-level
#   Review Hours: 6
#   Dependencies: [none]
#   Created: 2025-10-07T09:00:00Z
```

#### `get_metadata_field <yaml_file> <field_name>`
Extracts metadata fields from YAML file.

```bash
phase=$(get_metadata_field "$yaml_file" phase)
start_date=$(get_metadata_field "$yaml_file" start_date)
```

### Validation Functions

#### `validate_yaml_file <yaml_file>`
Validates YAML file structure and required fields.

```bash
if validate_yaml_file "$yaml_file"; then
    echo "Valid YAML file"
else
    echo "Invalid YAML file"
fi
```

#### `validate_all_configs [config_dir]`
Validates all configuration files in a directory.

```bash
validate_all_configs "$PROJECT_ROOT/config"
```

## Expected YAML Structure

```yaml
metadata:
  phase: foundation
  month: 1-2
  start_date: "2025-10-07"
  end_date: "2025-11-28"
  total_prs: 28

prs:
  - id: 1
    repo: db-schemas
    team: data-platform
    branch: schema/v1.0.0/user-table
    title: "Add user schema with audit fields"
    description: |
      Creates the foundational user table with:
      - Standard user fields
      - Audit columns
    files:
      - schemas/users.sql
      - migrations/001_create_users_table.sql
    dependencies: []
    complexity: mid-level
    created: "2025-10-07T09:00:00Z"
    review_hours: 6

  - id: 2
    repo: db-schemas
    team: data-platform
    branch: schema/v1.0.0/order-table
    title: "Add order schema"
    files:
      - schemas/orders.sql
    dependencies: [1]
    complexity: mid-level
    created: "2025-10-08T10:00:00Z"
    review_hours: 6
```

## Required Fields

Each PR must have the following fields:
- `id`: Unique numeric identifier
- `repo`: Repository name
- `team`: Team name
- `branch`: Git branch name
- `title`: PR title
- `description`: PR description (can be multi-line)
- `files`: Array of files to be modified
- `dependencies`: Array of PR IDs this PR depends on (can be empty: `[]`)
- `complexity`: One of: `mid-level`, `senior-level`
- `created`: ISO 8601 timestamp
- `review_hours`: Numeric review time estimate

## Usage Examples

See `yaml-parser-example.sh` for comprehensive examples.

### Basic Usage

```bash
#!/bin/bash
source "scripts/lib/yaml-parser.sh"

# Parse a YAML file
parse_yaml_file "config/pr-definitions-month1-2.yaml"

# Get PR count
echo "Loaded $(get_pr_count) PRs"

# Get specific PR details
title=$(get_pr_field 1 title)
echo "PR #1: $title"

# Iterate through all PRs
for pr_id in $(get_all_pr_ids); do
    print_pr_summary "$pr_id"
    echo ""
done
```

### Dependency Analysis

```bash
# Build dependency graph
for pr_id in $(get_all_pr_ids); do
    deps=$(get_pr_dependencies $pr_id)
    if [ -n "$deps" ]; then
        echo "PR #$pr_id depends on: $deps"
    fi
done
```

### Team-based Filtering

```bash
# Generate PRs for specific team
for pr_id in $(get_prs_by_team 'backend'); do
    repo=$(get_pr_field $pr_id repo)
    branch=$(get_pr_field $pr_id branch)
    echo "Creating PR #$pr_id in $repo on branch $branch"
done
```

## Testing

Run the test suite:

```bash
# Simple direct tests (recommended)
bash scripts/lib/test-yaml-parser-simple.sh

# Comprehensive test suite
bash scripts/lib/test-yaml-parser.sh
```

## Parsing Strategy

The library uses multiple parsing strategies in order of preference:

1. **yq** - If available, uses yq for fast and accurate YAML parsing
2. **Python + PyYAML** - If Python 3 with yaml module is available (not fully implemented)
3. **Pure Bash** - Fallback parser using awk, grep, and sed

The pure bash parser handles the specific YAML structure used in PR definition files but may not work with arbitrary YAML.

## Performance

- Parsing 28 PRs from month1-2 YAML: ~0.1s (pure bash)
- Accessing cached fields: instant (O(1) hash lookup)
- Filtering operations: O(n) where n = number of PRs

## Limitations

- Requires bash 4.0+ (associative arrays)
- Pure bash parser is tailored to PR definition YAML structure
- Does not support all YAML features (anchors, aliases, complex nesting)
- Multi-file loading fails if PR IDs overlap across files

## Known Issues

- PR configuration files have overlapping IDs across months:
  - month1-2: IDs 1-28
  - month3-4: IDs 20-59 (overlaps 20-28)
  - month5-6: IDs 58-95 (overlaps 58-59)
- Use `load_all_pr_configs` carefully or load files individually

## Files

- `yaml-parser.sh` - Main library
- `test-yaml-parser.sh` - Comprehensive test suite
- `test-yaml-parser-simple.sh` - Simple direct tests
- `yaml-parser-example.sh` - Usage examples
- `YAML_PARSER_README.md` - This file

## Author

Created as part of the first-agentic-ai project for automated PR generation and Git history simulation.

## License

MIT License
