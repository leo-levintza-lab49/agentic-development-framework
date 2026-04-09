# Skill: Agent Handoff

## Metadata
- **Name**: agent-handoff
- **Aliases**: handoff, hand-off, transfer
- **Category**: Collaboration
- **Team**: All teams

## Description

Create structured handoff issues to transfer work between agents, ensuring all context is preserved and the receiving agent can continue seamlessly.

## How It Works

1. Parses command arguments (description and target)
2. Gathers current context (files, decisions, state)
3. Invokes agent-handoff agent
4. Agent creates comprehensive GitHub Issue
5. Agent notifies target or team
6. Reports handoff details

## Usage

### Syntax

```
/agent-handoff [description] [options]
```

### Parameters

- `description`: Brief description of work to hand off
- `--to`: Target agent or team (backend, frontend, mobile, etc.)
- `--priority`: Priority level (high, medium, low)
- `--repo`: Target repository (auto-detects if omitted)
- `--context`: Additional context or notes

### Examples

**Simple handoff**:
```
/agent-handoff "Complete user authentication tests"
```

**Targeted handoff to team**:
```
/agent-handoff "Fix database migration" --to backend
```

**High priority handoff**:
```
/agent-handoff "Critical auth bug" --to backend --priority high
```

**With additional context**:
```
/agent-handoff "Implement OAuth refresh" --to backend --context "Already implemented base flow, needs token refresh logic"
```

**Specific repository**:
```
/agent-handoff "Update API docs" --repo polybase-poc/user-service --to backend
```

## Prerequisites

- GitHub CLI (`gh`) must be authenticated
- Repository must be accessible
- User must have write access to create issues

## Validation Rules

- Description must be provided
- Repository must exist or be detectable
- Target team (if specified) must be valid

## Expected Outcomes

**Success**:
```
🤝 Handoff Created

Repository: polybase-poc/user-service
Issue: #142
Title: Agent Handoff: Complete user authentication tests

Target: backend team
Priority: medium
Estimated Effort: 4 hours

Context Included:
✓ Completed work summary
✓ Remaining tasks checklist
✓ Technical setup instructions
✓ Files and configuration notes
✓ Blockers and dependencies
✓ References and documentation

Next Steps for Receiving Agent:
1. Review handoff issue: https://github.com/polybase-poc/user-service/issues/142
2. Self-assign if interested
3. Comment to acknowledge receipt
4. Execute setup instructions
5. Update progress via comments
6. Close when complete or hand off again

View Handoff: https://github.com/polybase-poc/user-service/issues/142
```

**Issue structure created**:
```markdown
# Agent Handoff: Complete user authentication tests

## 🤝 Handoff Context

**From**: Current Agent
**To**: backend team
**Priority**: medium
**Effort**: 4 hours

---

## ✅ Work Completed

- Implemented basic authentication flow
- Created user registration endpoint
- Set up JWT token generation

### Files Changed
\`\`\`
src/auth/AuthController.java
src/auth/AuthService.java
src/config/SecurityConfig.java
\`\`\`

### Decisions Made
- Using JWT for stateless auth
- 15-minute token expiry with refresh tokens
- Password hashing with BCrypt

---

## 🚧 Remaining Work

- Add comprehensive unit tests for AuthService
- Add integration tests for auth endpoints
- Test token refresh flow
- Test password reset flow
- Add negative test cases (invalid credentials, expired tokens)

### Acceptance Criteria
- [ ] Unit test coverage >80%
- [ ] All auth endpoints have integration tests
- [ ] Edge cases covered (expired tokens, invalid refresh)
- [ ] Tests pass in CI pipeline

---

## 📋 Technical Context

**Repository**: polybase-poc/user-service
**Branch**: feature/auth-implementation
**Technologies**: Java 17, Spring Boot 3.2, JUnit 5, Mockito

### Setup Instructions
\`\`\`bash
cd ~/wrk/polybase/user-service
git checkout feature/auth-implementation
./mvnw clean install
./mvnw test
\`\`\`

### Key Files
- \`src/auth/AuthController.java\` - REST endpoints
- \`src/auth/AuthService.java\` - Business logic
- \`src/auth/JwtUtil.java\` - Token generation/validation

### Configuration
Tests use H2 in-memory database. Config in \`src/test/resources/application-test.yml\`.

---

## 🚨 Blockers & Dependencies

None. All dependencies resolved.

---

## 📖 References

- Related Issue: #128 (User Authentication)
- API Spec: docs/API.md#authentication
- Security Requirements: docs/SECURITY.md

---

## 💬 Handoff Notes

The authentication implementation is complete and working. What's needed now is comprehensive test coverage. Focus on edge cases like expired tokens and invalid refresh tokens, as these are critical for security.

---

🤖 Handoff created by agent-handoff agent  
📅 2026-04-09 17:45:00
```

## Handoff Patterns

### When to Hand Off

**Good reasons**:
- ✅ Work requires different expertise
- ✅ Agent session ending with work incomplete
- ✅ Blocked on external dependency
- ✅ Work needs to continue in different context
- ✅ Parallel work splitting

**Poor reasons**:
- ❌ Minor issue that can be resolved quickly
- ❌ Incomplete context gathering
- ❌ Avoiding learning opportunity
- ❌ Work almost complete (just finish it!)

### Handoff Quality

**High quality handoff**:
- Clear what's done and what's not
- Runnable setup instructions
- Decision rationale explained
- Specific files listed
- Acceptance criteria defined
- Blockers explicitly stated

**Low quality handoff**:
- Vague "finish this"
- No setup instructions
- Missing context
- Unclear done state
- No file references

## Error Handling

- **Repository not found**: Auto-detects or prompts for repo
- **Insufficient context**: Prompts for missing information
- **Issue creation fails**: Retries then reports error
- **Target unclear**: Defaults to unassigned with label

## Tips

💡 **Be thorough**: Include all context the next agent needs

💡 **Test setup**: Verify setup instructions actually work

💡 **Be specific**: List exact files, not "the auth code"

💡 **Document decisions**: Explain why, not just what

💡 **Set expectations**: Clear acceptance criteria

💡 **Link references**: Issues, docs, designs

## Related Skills

- `/issue-sync` - Sync completed tasks to GitHub
- `/roadmap-sync` - Update project roadmap
- `/commit` - Commit work before handoff

## Implementation

This skill invokes the `agent-handoff` agent:

```javascript
Agent({
  name: "create-handoff",
  subagent_type: "agent-handoff",
  model: "haiku",  // Fast for coordination
  prompt: `Create agent handoff issue.

Description: ${description}
Target: ${target || 'unassigned'}
Priority: ${priority || 'medium'}
Repository: ${repo || 'auto-detect'}

Context to include:
- Current work state
- Completed items
- Remaining tasks
- Technical setup
- Blockers
- References

Create comprehensive GitHub Issue with all handoff context.`
})
```

## Maintenance

This skill is maintained by the Platform SRE team and uses:
- agent-handoff agent (Haiku)
- GitHub CLI (`gh`)
- Claude Code task system

---

**Version**: 1.0  
**Last Updated**: 2026-04-09  
**Maintained By**: Platform SRE Team
