# Agent Handoff Guide

Complete guide to agent-to-agent collaboration and task handoff patterns using GitHub Issues.

## Philosophy

Traditional software development uses tickets, PRs, and documentation. **Agentic development extends this to agent collaboration**: agents create issues, comment on progress, and hand off work—just like human developers, but faster and with perfect memory.

## Why GitHub Issues for Handoff?

**Persistence**: Context survives session boundaries  
**Discoverability**: Any agent can find handoff issues  
**Trackability**: Full history and timeline  
**Integration**: Works with GitHub Projects and Roadmaps  
**Collaboration**: Humans can participate and review  
**Standards**: Familiar tools and workflows  

## Core Concepts

### Handoff Issue

A **handoff issue** is a structured GitHub Issue containing:
- ✅ Work completed (what's done)
- 🚧 Remaining work (what's left)
- 📋 Technical context (setup, files, config)
- 🚨 Blockers (what's preventing progress)
- 📖 References (docs, designs, related issues)
- 💬 Notes (decisions, warnings, tips)

### Handoff Workflow

```
Current Agent → Handoff Issue → Receiving Agent
     ↓               ↓                    ↓
  Context       Structured            Continues
  Gathered      Documented            Seamlessly
```

**Current Agent**:
1. Recognizes need for handoff
2. Gathers complete context
3. Creates structured handoff issue

**Handoff Issue**:
1. Contains all necessary context
2. Labels identify target team/agent
3. Added to GitHub Project
4. Appears in team's queue

**Receiving Agent**:
1. Finds handoff in their queue
2. Reviews context
3. Self-assigns and starts work
4. Updates progress via comments
5. Completes or hands off again

## When to Hand Off

### Good Reasons ✅

**Expertise Mismatch**:
```
Backend Agent: "Need frontend UI for this API"
→ Hand off to Frontend team
```

**Session Ending**:
```
Agent: "Session timeout approaching, work 60% complete"
→ Hand off for next session
```

**Blocked on External Dependency**:
```
Agent: "Waiting for API key from security team"
→ Hand off with blocker documented
```

**Parallel Work Opportunity**:
```
Agent: "Can split into 3 independent subtasks"
→ Create 3 handoffs for parallel work
```

**Cross-Team Transition**:
```
Backend Agent: "API complete, needs integration"
→ Hand off to BFF team
```

### Poor Reasons ❌

**Minor Issues**:
```
Agent: "This will take 5 more minutes"
→ Just finish it!
```

**Incomplete Context**:
```
Agent: "Not sure what's happening, someone else figure it out"
→ Investigate first, then hand off with findings
```

**Avoiding Learning**:
```
Agent: "I don't know this technology"
→ Try first, then hand off if truly stuck
```

**Near Completion**:
```
Agent: "95% done, just needs final test"
→ Complete it, then sync to GitHub
```

## Creating Handoffs

### Using the Skill

**Simple handoff**:
```
/agent-handoff "Complete user authentication tests"
```

**Targeted handoff**:
```
/agent-handoff "Fix database migration issue" --to backend --priority high
```

**With context**:
```
/agent-handoff "Implement OAuth refresh token" \
  --to backend \
  --priority medium \
  --context "Base OAuth flow implemented in AuthService.java. Token refresh logic needed in JwtUtil.java. See RFC 6749 for spec."
```

### Manual Handoff

If you need more control:

```bash
gh issue create \
  --repo polybase-poc/user-service \
  --title "Agent Handoff: Implement token refresh" \
  --body "$(cat handoff-template.md)" \
  --label "handoff,backend,feat" \
  --project "Polybase Multi-Repo Development Roadmap"
```

## Handoff Quality

### High-Quality Handoff ✅

**Clear completion state**:
```markdown
## ✅ Work Completed
- ✓ Implemented user registration endpoint
- ✓ Added JWT token generation
- ✓ Created AuthController with /login and /register
- ✓ Unit tests for AuthService (85% coverage)

## 🚧 Remaining Work
- Add integration tests for auth endpoints
- Test token expiry and refresh flow
- Add negative test cases (invalid credentials, expired tokens)
```

**Runnable setup instructions**:
```bash
cd ~/wrk/polybase/user-service
git checkout feature/auth-implementation
./mvnw clean install
./mvnw test
```

**Decision rationale**:
```markdown
## Decisions Made
- Using JWT for stateless authentication (vs. session-based)
  Why: Scales better with multiple instances
- 15-minute token expiry with refresh tokens
  Why: Balance between security and UX
- BCrypt for password hashing
  Why: Industry standard, battle-tested
```

**Specific files**:
```markdown
## Key Files
- `src/auth/AuthController.java` - REST endpoints (/login, /register)
- `src/auth/AuthService.java` - Business logic (user creation, validation)
- `src/auth/JwtUtil.java` - Token generation and validation
- `src/config/SecurityConfig.java` - Spring Security configuration
```

**Clear acceptance criteria**:
```markdown
## Acceptance Criteria
- [ ] Integration tests for /login endpoint
- [ ] Integration tests for /register endpoint
- [ ] Test cases for token expiry
- [ ] Test cases for invalid refresh tokens
- [ ] Test coverage >80%
- [ ] All tests pass in CI
```

### Poor-Quality Handoff ❌

**Vague completion state**:
```markdown
## Work Done
Some auth stuff is implemented
```

**No setup instructions**:
```markdown
## Setup
Just run it
```

**Missing decision context**:
```markdown
## Decisions
Used JWT
```

**No file references**:
```markdown
## Files
The auth files
```

**Unclear done state**:
```markdown
## TODO
Finish it
```

## Receiving Handoffs

### Finding Your Handoffs

**Via GitHub CLI**:
```bash
# All open handoffs for your team
gh issue list --search "org:polybase-poc is:open label:handoff label:backend"

# Assigned to you
gh issue list --search "org:polybase-poc is:open label:handoff assignee:@me"

# High priority
gh issue list --search "org:polybase-poc is:open label:handoff label:backend label:high-priority"
```

**Via GitHub Web**:
1. Navigate to organization: https://github.com/polybase-poc
2. Go to Projects → Roadmap
3. Filter: `label:handoff label:backend status:"Planned"`

### Accepting Handoff

**Review the issue**:
```bash
gh issue view 142 --repo polybase-poc/user-service
```

**Self-assign**:
```bash
gh issue edit 142 --repo polybase-poc/user-service --add-assignee @me
```

**Comment to acknowledge**:
```bash
gh issue comment 142 --repo polybase-poc/user-service \
  --body "✅ Accepted. Starting work now. Will update progress here."
```

**Update Project status**:
```bash
# Move to "In Progress"
gh project item-edit --id ITEM_ID --field "Status" --option "In Progress"
```

### Working on Handoff

**Execute setup instructions**:
```bash
cd ~/wrk/polybase/user-service
git checkout feature/auth-implementation
./mvnw clean install
./mvnw test
```

**Update progress regularly**:
```bash
# After 1 hour
gh issue comment 142 --body "📊 Progress: 25% complete. Integration tests setup done."

# After 2 hours
gh issue comment 142 --body "📊 Progress: 50% complete. /login endpoint tests done."

# After 3 hours
gh issue comment 142 --body "📊 Progress: 75% complete. All endpoint tests done. Working on edge cases."
```

**Ask questions if needed**:
```bash
gh issue comment 142 --body "❓ Question: Should we test expired tokens with real delays (slow) or mock clock (fast)?"
```

### Completing Handoff

**Final update**:
```bash
gh issue comment 142 --body "✅ Complete! 

Results:
- Integration tests: 12 new tests added
- Coverage: 92% (up from 85%)
- All tests passing in CI
- Edge cases covered (expired tokens, invalid refresh, missing auth header)

PR: #156"
```

**Close issue**:
```bash
gh issue close 142 --comment "✅ Handoff complete. All acceptance criteria met."
```

**Update Project**:
```bash
# Move to "Done" with completion date
gh project item-edit --id ITEM_ID --field "Status" --option "Done"
gh project item-edit --id ITEM_ID --field "Completion Date" --date "2026-04-09"
```

## Handoff Patterns

### Pattern 1: Simple Continuation

**Scenario**: Session ending, work incomplete

```
Agent 1: Working on feature, 60% done, session timeout
         ↓
     Creates handoff with current state
         ↓
Agent 2: Picks up, continues from checkpoint
         ↓
     Completes work, closes handoff
```

**Example**:
```
/agent-handoff "Complete health check endpoint implementation"
```

### Pattern 2: Cross-Team Handoff

**Scenario**: Work transitions between teams

```
Backend Agent: API complete
         ↓
     Creates handoff for frontend team
         ↓
Frontend Agent: Builds UI using API
         ↓
     Completes, closes handoff
```

**Example**:
```
/agent-handoff "Build dashboard UI for user management API" \
  --to frontend \
  --context "API endpoints documented in docs/API.md. See /api/users/** endpoints."
```

### Pattern 3: Parallel Work Split

**Scenario**: Large task split into parallel subtasks

```
Coordinator Agent: Analyzes large task
         ↓
     Creates 3 handoff issues
         ↓
Agent A, B, C: Work in parallel
         ↓
     All complete independently
```

**Example**:
```bash
# Agent creates 3 handoffs
/agent-handoff "Implement user CRUD operations" --to backend
/agent-handoff "Implement order CRUD operations" --to backend
/agent-handoff "Implement product CRUD operations" --to backend
```

### Pattern 4: Blocked Handoff

**Scenario**: Agent stuck, needs specialist

```
Agent 1: Encounters complex database issue
         ↓
     Creates handoff with problem details
         ↓
Agent 2 (DB Expert): Resolves blocker
         ↓
Agent 1: Continues original work
```

**Example**:
```
/agent-handoff "Fix PostgreSQL connection pool exhaustion" \
  --to data-platform \
  --priority high \
  --context "Users reporting 'Connection timeout after 30s'. Connection pool settings in application.yml. Current max pool size: 10. High load: ~1000 req/sec."
```

### Pattern 5: Review Handoff

**Scenario**: Work complete, needs code review

```
Developer Agent: Completes feature
         ↓
     Creates handoff for review
         ↓
Reviewer Agent: Reviews code, suggests changes
         ↓
Developer Agent: Makes changes
         ↓
Reviewer Agent: Approves, closes handoff
```

**Example**:
```
/agent-handoff "Review authentication implementation" \
  --to platform-sre \
  --priority high \
  --context "New auth system needs security review. Focus on: JWT implementation, password hashing, token storage. PR: #156"
```

## Advanced Techniques

### Handoff Chains

For complex work requiring multiple specialists:

```
Agent A (Backend) → Agent B (Database) → Agent C (Performance) → Agent A (Backend)
     ↓                    ↓                      ↓                      ↓
  API design       Schema design         Indexing strategy        Integration
```

**Implementation**:
1. Agent A creates handoff for B with blocker
2. B completes, comments on A's handoff
3. A creates handoff for C
4. C completes, comments
5. A integrates all work, closes handoffs

### Handoff Templates

Create team-specific templates:

**Backend Handoff Template**:
```markdown
## 🤝 Backend Handoff

**From**: [Current Agent]
**To**: Backend Team
**Priority**: [high|medium|low]

## ✅ Completed
[What's done]

## 🚧 Remaining
- [ ] [Task 1]
- [ ] [Task 2]

## 📋 Technical Context
**Branch**: [branch-name]
**Technologies**: [Java 17, Spring Boot 3.2, etc.]
**Database**: [PostgreSQL, MongoDB, etc.]

### Setup
\`\`\`bash
[Commands to run]
\`\`\`

### Key Files
- [file-1] - [description]
- [file-2] - [description]

## 🚨 Blockers
[Any blockers or none]

## 📖 References
- API Spec: [link]
- Database Schema: [link]
- Related Issue: [#issue]
```

### Handoff Metrics

Track handoff efficiency:

```bash
# Average handoff resolution time
gh issue list --label "handoff" --state closed \
  | jq '.[] | (.closedAt - .createdAt) / 3600' \
  | awk '{sum+=$1; count++} END {print sum/count " hours"}'

# Handoff success rate (closed vs. abandoned)
closed=$(gh issue list --label "handoff" --state closed | wc -l)
total=$(gh issue list --label "handoff" --state all | wc -l)
echo "scale=2; $closed / $total * 100" | bc

# Handoffs by team
gh issue list --label "handoff" --state all \
  | jq -r '.[] | .labels[] | select(.name | test("backend|frontend|mobile")) | .name' \
  | sort | uniq -c
```

## Best Practices

### For Creating Handoffs

✅ **Be thorough**: Include everything the next agent needs  
✅ **Test setup**: Verify setup instructions actually work  
✅ **Be specific**: Exact files, not "the code"  
✅ **Document decisions**: Why, not just what  
✅ **Set expectations**: Clear acceptance criteria  
✅ **Link references**: Issues, docs, designs, specs  
✅ **Update status**: Mark current state in Project  

❌ **Don't hand off trivial work**: Finish small tasks  
❌ **Don't guess**: If unsure, investigate first  
❌ **Don't omit context**: Assume next agent knows nothing  
❌ **Don't hand off broken code**: Ensure it runs first  

### For Receiving Handoffs

✅ **Review fully**: Read entire handoff before starting  
✅ **Acknowledge quickly**: Comment within 1 hour  
✅ **Ask questions**: Better to ask than assume  
✅ **Update progress**: Comment regularly  
✅ **Close properly**: Summarize results  

❌ **Don't ignore context**: Read all provided details  
❌ **Don't stay silent**: Update progress regularly  
❌ **Don't deviate**: Follow setup instructions first  
❌ **Don't close prematurely**: Verify acceptance criteria  

### For Teams

✅ **Define handoff SLAs**: E.g., acknowledge within 4 hours  
✅ **Review handoff quality**: Audit for completeness  
✅ **Create team templates**: Standardize handoff format  
✅ **Monitor handoff queues**: Don't let them pile up  
✅ **Share learnings**: What makes good handoffs?  

## Troubleshooting

### Handoff Not Appearing

**Check labels**:
```bash
gh issue view 142 --json labels
```

Ensure it has both `handoff` and team label.

**Check Project**:
```bash
gh project item-list 1 --owner polybase-poc | grep "#142"
```

If not in Project, add it:
```bash
gh project item-add 1 --owner polybase-poc --url ISSUE_URL
```

### Incomplete Handoff

If handoff lacks context:

```bash
gh issue comment 142 --body "❓ Need more information:
- Which branch should I use?
- What files should I focus on?
- What's the acceptance criteria?
- Are there any blockers?

@previous-agent please provide."
```

### Stale Handoff

If handoff has no activity >7 days:

```bash
gh issue comment 142 --body "⚠️  This handoff has been open for 10 days with no updates.

Options:
1. If still relevant, please acknowledge and update progress
2. If blocked, please document blocker
3. If no longer needed, please close

Will auto-close in 7 days if no response."
```

### Conflicting Handoffs

If multiple handoffs for same work:

```bash
# Close duplicate
gh issue close 143 --comment "Duplicate of #142. Consolidating work there."

# Link to original
gh issue comment 142 --body "Note: Duplicate handoff #143 was closed. All work tracked here."
```

## Examples

### Example 1: Backend to Frontend

```markdown
# Agent Handoff: Build user dashboard UI

## 🤝 Handoff Context
**From**: Backend Agent
**To**: Frontend Team
**Priority**: medium
**Effort**: 8 hours

## ✅ Work Completed
- User management API complete
- Endpoints: GET /api/users, POST /api/users, PUT /api/users/:id, DELETE /api/users/:id
- Full CRUD operations tested
- API documentation in docs/API.md

## 🚧 Remaining Work
- Build dashboard UI to display user list
- Add forms for creating/editing users
- Implement client-side validation
- Connect to API using existing auth
- Add loading states and error handling

### Acceptance Criteria
- [ ] User list displays all users from GET /api/users
- [ ] Create user form posts to POST /api/users
- [ ] Edit user form updates via PUT /api/users/:id
- [ ] Delete confirmation and DELETE /api/users/:id call
- [ ] Proper error messages for API failures
- [ ] Loading spinners during API calls

## 📋 Technical Context
**Repository**: polybase-poc/web-app
**Branch**: feature/user-management
**Technologies**: React 18, Vite, TypeScript, React Query

### Setup
\`\`\`bash
cd ~/wrk/polybase/web-app
git checkout feature/user-management
npm install
npm run dev
\`\`\`

Backend API running at: http://localhost:8080

### Key Files to Create
- `src/pages/UserDashboard.tsx` - Main dashboard page
- `src/components/UserList.tsx` - User list component
- `src/components/UserForm.tsx` - Create/edit form
- `src/api/users.ts` - API client functions

### Existing Auth
Authentication already implemented. Use `useAuth()` hook for current user token.

\`\`\`typescript
import { useAuth } from '@/hooks/useAuth';

const { token } = useAuth();
// Include in API requests: Authorization: Bearer ${token}
\`\`\`

## 📖 References
- API Documentation: http://localhost:8080/swagger-ui.html
- Design Mockups: https://figma.com/file/ABC123
- Backend Issue: #128

## 💬 Handoff Notes
The API is fully tested and stable. Focus on UX - make sure error states are clear and forms are user-friendly. The user object has many fields but dashboard only needs: id, name, email, role, createdAt.

---
🤖 Handoff created by agent-handoff agent
📅 2026-04-09 14:30:00
```

## Summary

Handoffs are **structured knowledge transfer** between agents using GitHub Issues as the medium. High-quality handoffs enable seamless collaboration at scale.

**Key Principles**:
1. **Complete Context**: Everything needed to continue
2. **Runnable Instructions**: Setup that actually works
3. **Clear Boundaries**: What's done, what's not
4. **Explicit Expectations**: Acceptance criteria defined
5. **Regular Updates**: Progress communicated
6. **Proper Closure**: Results summarized

---

**Ready for seamless agent collaboration!** 🤝

---

**Version**: 1.0  
**Last Updated**: 2026-04-09  
**Maintained By**: Platform SRE Team
