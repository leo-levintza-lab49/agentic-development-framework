#!/bin/bash
#
# Team Management Functions
#

# Source utilities if not already loaded
if [ -z "$UTILS_LOADED" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/utils.sh"
fi

# Create a team
create_team() {
    local org=$1
    local team_name=$2
    local team_slug=$3
    local description=$4
    local privacy=${5:-closed}

    print_info "Creating team '$team_name' in $org..."

    # Check if team exists
    if gh api "/orgs/$org/teams/$team_slug" >/dev/null 2>&1; then
        print_warning "Team '$team_name' already exists"
        return 2
    fi

    # Create team
    if gh api "/orgs/$org/teams" \
        -X POST \
        -f name="$team_name" \
        -f description="$description" \
        -f privacy="$privacy" >/dev/null 2>&1; then
        print_success "Created team '$team_name'"
        return 0
    else
        print_error "Failed to create team '$team_name'"
        return 1
    fi
}

# Delete a team
delete_team() {
    local org=$1
    local team_slug=$2

    print_warning "Deleting team '$team_slug' from $org..."

    if gh api "/orgs/$org/teams/$team_slug" -X DELETE >/dev/null 2>&1; then
        print_success "Deleted team '$team_slug'"
        return 0
    else
        print_error "Failed to delete team '$team_slug'"
        return 1
    fi
}

# Add repository to team
add_repo_to_team() {
    local org=$1
    local team_slug=$2
    local repo=$3
    local permission=${4:-push}

    print_info "Adding $repo to team $team_slug..."

    if gh api "/orgs/$org/teams/$team_slug/repos/$org/$repo" \
        -X PUT \
        -f permission="$permission" >/dev/null 2>&1; then
        print_success "Added $repo to team $team_slug"
        return 0
    else
        print_error "Failed to add $repo to team $team_slug"
        return 1
    fi
}

# List teams in organization
list_teams() {
    local org=$1

    print_info "Teams in $org:"
    gh api "/orgs/$org/teams" --jq '.[] | "\(.name) (\(.slug))"'
}

# Get team information
get_team_info() {
    local org=$1
    local team_slug=$2

    gh api "/orgs/$org/teams/$team_slug" --jq '{
        name,
        slug,
        description,
        privacy,
        members_count,
        repos_count
    }'
}

export -f create_team
export -f delete_team
export -f add_repo_to_team
export -f list_teams
export -f get_team_info
