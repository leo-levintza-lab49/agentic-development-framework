# Timeline Manager Overview

## Purpose

The Timeline Manager library provides realistic timestamp spreading for commits and pull requests in the case study implementation. It ensures that generated git history appears authentic by respecting business hours, weekends, and holidays.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Timeline Manager                          │
│                 (timeline-manager.sh)                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Core Time Functions         Business Logic                 │
│  ┌──────────────────┐       ┌──────────────────┐          │
│  │ normalize_to_    │       │ calculate_merge  │          │
│  │ business_hours() │       │ _time()          │          │
│  └────────┬─────────┘       └────────┬─────────┘          │
│           │                           │                     │
│  ┌────────▼─────────┐       ┌────────▼─────────┐          │
│  │ add_business_    │       │ generate_commit_ │          │
│  │ hours()          │       │ timestamps()     │          │
│  └────────┬─────────┘       └────────┬─────────┘          │
│           │                           │                     │
│  ┌────────▼─────────────────────────▼─────────┐          │
│  │        Validation & Utilities               │          │
│  │  • is_business_hours()                      │          │
│  │  • is_weekend()                             │          │
│  │  • is_holiday()                             │          │
│  │  • is_valid_timestamp()                     │          │
│  │  • to_git_timestamp()                       │          │
│  └─────────────────────────────────────────────┘          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Integration Points

### 1. PR Generation Script

```bash
scripts/generate-prs.sh
    │
    ├─> Load timeline-manager.sh
    │
    ├─> For each PR:
    │   ├─> calculate_merge_time()
    │   ├─> generate_commit_timestamps()
    │   └─> to_git_timestamp()
    │
    └─> Create commits & PRs with realistic times
```

### 2. Repository Scaffolding

```bash
scripts/lib/scaffolding.sh
    │
    ├─> Load timeline-manager.sh
    │
    └─> Initial commits:
        └─> get_current_business_timestamp()
```

### 3. Monorepo Migration

```bash
scripts/lib/monorepo-scaffolding.sh
    │
    ├─> Load timeline-manager.sh
    │
    └─> Migration commits:
        └─> add_business_hours()
```

## Data Flow

```
┌─────────────────┐
│  Configuration  │
│  ┌───────────┐  │
│  │ PR Type   │  │──┐
│  │ Complexity│  │  │
│  │ Team      │  │  │
│  └───────────┘  │  │
└─────────────────┘  │
                     │
                     ▼
         ┌───────────────────────┐
         │  Timeline Manager     │
         │                       │
         │  Input:               │
         │  • Created time       │
         │  • # commits          │
         │  • Complexity         │
         │  • Review hours       │
         │                       │
         │  Processing:          │
         │  • Normalize times    │
         │  • Skip weekends      │
         │  • Skip holidays      │
         │  • Spread commits     │
         │                       │
         │  Output:              │
         │  • Commit timestamps  │
         │  • Merge time         │
         │  • Git-format times   │
         └───────────────────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │  Git Operations       │
         │                       │
         │  GIT_AUTHOR_DATE=...  │
         │  git commit           │
         │                       │
         │  GIT_COMMITTER_DATE=..│
         │  git commit           │
         └───────────────────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │  Realistic Git        │
         │  History              │
         └───────────────────────┘
```

## Key Features

### 1. Business Hours Enforcement

- Working hours: 9am - 6pm EST/EDT
- Automatically rolls times outside hours to next business day
- Configurable timezone support

### 2. Weekend & Holiday Handling

- Detects weekends (Saturday, Sunday)
- Pre-configured with 2026 US federal holidays
- Moves timestamps to next available business day

### 3. Realistic Commit Patterns

| Pattern | Commits | Time Span | Use Case |
|---------|---------|-----------|----------|
| Simple | 1 | 4 hours | Hotfix, config change |
| Medium | 2-3 | 16 hours | Standard feature |
| Complex | 4-5 | 24 hours | Refactor, large feature |

### 4. Smart Time Arithmetic

```
Add 10 business hours starting Wednesday 2pm:
├─ Wednesday 2pm → 6pm (4 hours)
├─- Thursday 9am → 6pm (9 hours) 
├─- Friday 9am → 10am (1 hour)
└─> Result: Friday 10am
```

## Real-World Patterns

### Pattern 1: Quick Fix Flow
```
Time: Same Day
Commits: 1
Timeline:
  10:00 AM - PR created
  10:05 AM - Initial commit
  12:00 PM - Review & approval
  12:15 PM - Merged
```

### Pattern 2: Feature Development
```
Time: 2 Days
Commits: 3
Timeline:
  Day 1, 9:30 AM  - PR created
  Day 1, 9:30 AM  - Initial implementation
  Day 1, 3:00 PM  - Address review comments
  Day 2, 11:00 AM - Final polish
  Day 2, 1:30 PM  - Merged
```

### Pattern 3: Complex Refactor
```
Time: 3-4 Days
Commits: 5
Timeline:
  Day 1, 10:00 AM - PR created & initial work
  Day 1, 4:00 PM  - First iteration
  Day 2, 11:00 AM - Address feedback
  Day 3, 9:30 AM  - More changes
  Day 3, 2:00 PM  - Final commit
  Day 4, 10:00 AM - Merged after thorough review
```

## Configuration Examples

### Standard Configuration
```bash
source scripts/lib/timeline-manager.sh

# Uses defaults:
# - Timezone: America/New_York
# - Business hours: 9am-6pm
# - Holidays: 2026 US federal
```

### Custom Timezone
```bash
export TIMELINE_TZ="America/Los_Angeles"
source scripts/lib/timeline-manager.sh

# Now all times in Pacific
```

### Team-Specific Patterns

```bash
# Backend team - thorough reviews
backend_review_hours() {
    case "$PR_TYPE" in
        hotfix)    echo 3 ;;
        feature)   echo 16 ;;
        refactor)  echo 24 ;;
    esac
}

# Frontend team - faster iterations
frontend_review_hours() {
    case "$PR_TYPE" in
        hotfix)    echo 2 ;;
        feature)   echo 8 ;;
        refactor)  echo 16 ;;
    esac
}
```

## Testing Strategy

### Unit Tests
```bash
./scripts/lib/test-timeline-manager.sh
```
- 27 test cases
- Covers all core functions
- Validates edge cases (weekends, holidays, wraparound)

### Integration Tests
```bash
./scripts/lib/timeline-manager-example.sh
```
- 6 example scenarios
- Shows real-world usage
- Demonstrates full workflow

### Visual Validation
Generated commits should show:
- No weekend commits
- No commits outside 9am-6pm
- Natural spacing between commits
- Realistic review times

## Performance

- Pure bash implementation
- Minimal dependencies (date command)
- Fast execution (~0.1s per timestamp calculation)
- Suitable for generating thousands of commits

## Limitations

1. **Platform**: Currently macOS/BSD date only
2. **Holidays**: Only 2026 US federal holidays pre-configured
3. **Business Hours**: Fixed per script, not per-call configurable
4. **Timezone**: Single timezone per execution

## Future Enhancements

### Phase 1: Compatibility
- [ ] Add Linux/GNU date support
- [ ] Add Windows Git Bash compatibility
- [ ] Cross-platform testing

### Phase 2: Flexibility
- [ ] Configurable business hours per call
- [ ] Multiple timezone support in single run
- [ ] Custom holiday calendars
- [ ] Developer PTO/availability calendars

### Phase 3: Intelligence
- [ ] ML-based commit pattern analysis
- [ ] Team velocity metrics integration
- [ ] Code review time prediction
- [ ] Sprint/release cycle awareness

## Usage in Case Study

The Timeline Manager is critical for:

1. **Authenticity**: Makes generated history believable
2. **Compliance**: Respects business practices
3. **Analysis**: Enables realistic metrics
4. **Patterns**: Shows typical development flows

Without proper timestamp management, generated PRs would:
- Show commits at 2am or on Sundays (unrealistic)
- Have instant reviews (unrealistic)
- Lack natural development rhythm
- Be obviously synthetic

## Dependencies

```bash
# Required
- bash 4.0+
- date command (BSD/macOS)
- bc (basic calculator)

# Optional
- Git (for commit operations)
- GitHub CLI (for PR operations)
```

## Files

```
scripts/lib/
├── timeline-manager.sh           # Main library
├── test-timeline-manager.sh      # Test suite
├── timeline-manager-example.sh   # Usage examples
├── README.md                     # Full documentation
├── QUICK_REFERENCE.md            # Quick lookup
└── TIMELINE_MANAGER_OVERVIEW.md  # This file
```

## Quick Start

```bash
# Load library
source scripts/lib/timeline-manager.sh

# Generate PR timeline
PR_START="2026-04-09T10:00:00"
COMMITS=$(generate_commit_timestamps "$PR_START" 3 "medium")
MERGE=$(calculate_merge_time "$PR_START" 12)

# Create commits
for commit_time in $COMMITS; do
    GIT_TS=$(to_git_timestamp "$commit_time")
    GIT_AUTHOR_DATE="$GIT_TS" GIT_COMMITTER_DATE="$GIT_TS" \
        git commit -m "Feature update"
done
```

## Support

For issues or questions:
1. Check QUICK_REFERENCE.md for common patterns
2. Review README.md for detailed function docs
3. Run test suite to verify installation
4. Examine examples for usage patterns

---

**Last Updated**: 2026-04-09  
**Version**: 1.0.0  
**Status**: Production Ready
