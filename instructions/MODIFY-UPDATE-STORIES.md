# 📖 Modifying and Updating Stories Guide

This guide provides detailed instructions for modifying user stories, including scope changes, requirement updates, and story splitting/combining.

## Story Modification Scenarios

### 1. Adding Requirements to Existing Story

#### When to Add vs. Create New Story
**Add to Existing** when:
- Change is minor clarification
- Fits within original story scope
- Doesn't significantly increase complexity
- Same user persona and goal

**Create New Story** when:
- Introduces new user persona
- Significantly different goal
- Would double story size
- Different technical approach needed

#### Adding Requirements Process
```markdown
## Acceptance Criteria
- [x] Original criterion 1 ✓
- [x] Original criterion 2 ✓
- [ ] Original criterion 3
- [ ] **ADDED 2025-07-01:** New requirement based on [reason]
- [ ] **ADDED 2025-07-01:** Additional validation for [use case]

## Technical Requirements
- Original requirement 1
- Original requirement 2
- **NEW:** Additional security requirement (added 2025-07-01)
- **NEW:** Performance requirement: <100ms response time

## Change History
- **2025-07-01**: Added 2 new acceptance criteria for [business reason]
  - Approved by: [Stakeholder]
  - Impact: Extends timeline by ~2 days
```

### 2. Splitting a Large Story

#### When to Split
- Story is too large (>13 story points)
- Multiple user personas involved
- Can deliver value incrementally
- Different technical components

#### Split Pattern Example
Original Story: "User Management System"

Split into:
```markdown
## Story 07-04-A: User Registration and Authentication
As a new user, I want to register and login
- Focus: Registration, login, password reset
- Points: 5

## Story 07-04-B: User Profile Management  
As a registered user, I want to manage my profile
- Focus: Profile CRUD, preferences
- Points: 3

## Story 07-04-C: User Administration
As an admin, I want to manage all users
- Focus: Admin panel, user search, bulk operations
- Points: 5
```

#### MCP Commands for Splitting
```javascript
// 1. Create new stories
const newStories = await Promise.all([
  notion.pages.create({
    parent: { database_id: "21e0d2195e1c806a947ff1806bffa2fb" },
    properties: {
      "Title": { title: [{ text: { content: "Story 07-04-A: User Registration" } }] },
      "Related Epic": { relation: [{ id: "epic-id" }] },
      "Original Story": { rich_text: [{ text: { content: "Split from 07-04" } }] }
    }
  }),
  // ... more stories
]);

// 2. Update original story
await notion.pages.update({
  page_id: "original-story-id",
  properties: {
    "Status": { status: { name: "Split" } },
    "Notes": { 
      rich_text: [{ 
        text: { content: "Split into 07-04-A, 07-04-B, 07-04-C on 2025-07-01" } 
      }] 
    }
  }
});

// 3. Move tasks to appropriate new stories
// ... task reassignment logic
```

### 3. Combining Related Stories

#### When to Combine
- Stories are too granular
- Strong dependencies between stories
- Same developer/team working on both
- Reduces overhead

#### Combination Process
```markdown
## Combined Story: 08-02-03: Product and Pricing Analysis
**Formed by combining:**
- Story 08-02: Product Solution Analysis
- Story 08-03: Pricing Model Research

## Updated Acceptance Criteria
### From Story 08-02:
- [ ] Analyze competitor product features
- [ ] Document solution architectures

### From Story 08-03:
- [ ] Research pricing strategies
- [ ] Create pricing comparison matrix

## Estimation
- Original 08-02: 5 points
- Original 08-03: 3 points
- Combined: 7 points (1 point efficiency gain)
```

### 4. Scope Reduction

#### Deferring Requirements
```markdown
## Acceptance Criteria
- [x] Core feature 1 ✓
- [x] Core feature 2 ✓
- [ ] Core feature 3
- [ ] ~~Advanced feature 1~~ **DEFERRED to Story 09-XX**
- [ ] ~~Advanced feature 2~~ **DEFERRED to Phase 2**

## Scope Change Log
- **2025-07-01**: Deferred advanced features to meet deadline
  - Reason: Focus on MVP for Q3 release
  - Approved by: Product Owner
  - New stories created: 09-XX, 09-XY
```

#### Creating Deferred Story
```javascript
// Create follow-up story for deferred items
notion.pages.create({
  parent: { database_id: "21e0d2195e1c806a947ff1806bffa2fb" },
  properties: {
    "Title": { title: [{ text: { content: "Advanced Features (Deferred from 08-02)" } }] },
    "Status": { status: { name: "Backlog" } },
    "Priority": { select: { name: "Medium" } },
    "Notes": { 
      rich_text: [{ 
        text: { content: "Deferred from Story 08-02 on 2025-07-01 to meet MVP deadline" } 
      }] 
    }
  }
});
```

### 5. Technical Approach Changes

#### Documenting Technical Pivots
```markdown
## Technical Requirements

### Original Approach (Deprecated)
- ~~Build custom authentication system~~
- ~~Implement own session management~~

### New Approach (As of 2025-07-01)
- **USE:** Auth0 for authentication
- **USE:** JWT tokens for session management
- **REASON:** Reduce development time, improve security

## Impact Analysis
- **Timeline:** Reduces by 2 weeks
- **Cost:** Adds $200/month for Auth0
- **Risk:** Reduced security risks
- **Tasks Affected:** Need to update tasks 07-04-01 through 07-04-03
```

### 6. Story State Transitions

#### Valid Status Transitions
```
Backlog → To Do → In Progress → Review → Done
           ↓         ↓            ↓
        Blocked   Blocked     Needs Revision
           ↓         ↓            ↓
        To Do    To Do      In Progress

Special States:
- Split: Story has been split into multiple stories
- Deprecated: Story no longer needed
- Duplicate: Merged with another story
```

#### Status Update with Context
```javascript
notion.pages.update({
  page_id: "story-id",
  properties: {
    "Status": { status: { name: "Blocked" } },
    "Blocked Reason": { 
      rich_text: [{ 
        text: { content: "Waiting for API access from vendor (ETA: 2025-07-15)" } 
      }] 
    },
    "Last Status Update": { 
      date: { start: new Date().toISOString() } 
    }
  }
});
```

---

## Story Modification Best Practices

### 1. Communication Protocol
- **Before**: Discuss with team/stakeholders
- **During**: Update in real-time
- **After**: Notify affected parties

### 2. Documentation Standards
Always document:
- **What** changed
- **Why** it changed
- **Who** approved
- **When** it changed
- **Impact** on timeline/resources

### 3. Maintaining Traceability
```markdown
## Story Relationships
- **Parent Epic:** 07 - Talent Acquisition
- **Original Story:** 07-04 (if split/modified)
- **Related Stories:** 07-05 (dependency)
- **Child Stories:** 07-04-A, 07-04-B (if split)
```

### 4. Version Control for Major Changes
For significant modifications, create a version history:

```markdown
## Version History

### v2.0 (2025-07-01) - Current
- Reduced scope to MVP features
- Changed technical approach to use Auth0
- Split admin features to separate story

### v1.0 (2025-06-15) - Original
- Full user management system
- Custom authentication
- All features in single story
```

---

## Automated Story Updates via n8n

### Trigger Patterns
```yaml
Story Modification Triggers:
  - Task Completion: Update story progress
  - All Tasks Complete: Mark story as Done
  - Task Blocked: Check if story should be blocked
  - Epic Update: Cascade priority changes
  - Sprint Change: Update story assignments
```

### Progress Calculation
```javascript
// n8n function to calculate story progress
const tasks = $node["GetStoryTasks"].json;
const totalTasks = tasks.length;
const completedTasks = tasks.filter(t => t.status === "Done").length;
const progress = Math.round((completedTasks / totalTasks) * 100);

return {
  progress: progress,
  status: progress === 100 ? "Review" : "In Progress",
  summary: `${completedTasks}/${totalTasks} tasks complete`
};
```

---

## Quick Reference: Common Modifications

| Modification Type | When to Use | Key Actions |
|------------------|-------------|-------------|
| Add Requirements | Scope clarification | Update criteria, adjust estimates |
| Split Story | Too large/complex | Create child stories, redistribute tasks |
| Combine Stories | Too granular | Merge criteria, consolidate tasks |
| Defer Scope | Timeline pressure | Move to backlog, create follow-up |
| Technical Pivot | Better solution found | Update approach, revise tasks |
| Cancel Story | No longer needed | Mark deprecated, document reason |

Remember: Every story modification should improve project clarity and delivery efficiency!