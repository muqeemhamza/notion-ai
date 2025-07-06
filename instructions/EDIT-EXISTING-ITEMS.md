# ✏️ Editing Existing Items Guide

This guide explains how to edit and update existing Projects, Epics, Stories, and Tasks using Notion MCP while maintaining data integrity.

## Prerequisites
- Notion MCP access with appropriate permissions
- Item IDs or ability to search for items
- Understanding of the impact of changes on related items

---

## General Editing Principles

### 1. Before Making Changes
- **Check Dependencies**: Verify what items are linked
- **Document Changes**: Note why changes are being made
- **Preserve History**: Don't delete historical information
- **Update Related Items**: Ensure consistency across linked items

### 2. What Can Be Safely Edited
✅ **Safe to Edit:**
- Descriptions and details
- Status updates
- Priority changes
- Adding new acceptance criteria
- Updating estimates
- Adding comments/notes
- Fixing typos

⚠️ **Edit with Caution:**
- Item relationships (epic↔story↔task links)
- Core identifiers (IDs, numbers)
- Historical dates
- Original requirements

❌ **Never Edit:**
- Database IDs
- Creation timestamps
- Original author information
- Audit trail data

---

## Editing Tasks

### 1. Common Task Updates

#### Updating Status
```javascript
// Using Notion MCP
notion.pages.update({
  page_id: "task-page-id",
  properties: {
    "Status": { 
      status: { name: "In Progress" } // Not Started → In Progress → Review → Done
    }
  }
})
```

#### Updating Time Estimates
```javascript
notion.pages.update({
  page_id: "task-page-id",
  properties: {
    "Estimated Time": { 
      rich_text: [{ text: { content: "8-12 hours" } }] 
    },
    "Actual Time": { 
      number: 10.5 
    }
  }
})
```

#### Adding Implementation Notes
```javascript
// Append to existing content
notion.blocks.children.append({
  block_id: "task-page-id",
  children: [{
    object: "block",
    type: "heading_2",
    heading_2: {
      rich_text: [{ text: { content: "Implementation Notes" } }]
    }
  }, {
    object: "block",
    type: "paragraph",
    paragraph: {
      rich_text: [{ text: { content: "Your implementation details here..." } }]
    }
  }]
})
```

### 2. Task File Updates
When updating task markdown files:

```markdown
## ⏳ Status & Priority
- **Status:** ~~Not Started~~ → In Progress  <!-- Show the change -->
- **Priority:** High
- **Difficulty:** Complex
- **Assignee:** ~~TBD~~ → John Doe
- **Due Date:** 2025-07-15
- **Estimated Time:** 8-12 hours
- **Actual Time:** ~~TBD~~ → 10.5 hours

## 📝 Implementation Notes (Added YYYY-MM-DD)
[New section with implementation details, lessons learned, etc.]
```

---

## Editing Stories

### 1. Common Story Updates

#### Adding/Modifying Acceptance Criteria
```javascript
// Fetch existing criteria first
const story = await notion.pages.retrieve({ page_id: "story-page-id" });

// Add new criterion
notion.pages.update({
  page_id: "story-page-id",
  properties: {
    "Acceptance Criteria": {
      rich_text: [
        ...existingCriteria,
        { text: { content: "\n- [ ] New criterion added on YYYY-MM-DD" } }
      ]
    }
  }
})
```

#### Updating Story Status Based on Task Completion
```javascript
// Check all related tasks
const tasks = await notion.databases.query({
  database_id: "21e0d2195e1c80a28c67dc2a8ed20e1b",
  filter: {
    property: "Related Story",
    relation: { contains: "story-id" }
  }
});

// Update story status if all tasks complete
if (allTasksComplete) {
  notion.pages.update({
    page_id: "story-page-id",
    properties: {
      "Status": { status: { name: "Done" } }
    }
  });
}
```

### 2. Story File Updates
```markdown
## Acceptance Criteria
- [x] Given [context], when [action], then [outcome] ✓ Completed 2025-06-30
- [x] Given [context], when [action], then [outcome] ✓ Completed 2025-06-30
- [ ] Given [context], when [action], then [outcome]
- [ ] **NEW (2025-07-01):** Given [new context], when [action], then [outcome]

## Change Log
- **2025-07-01**: Added new acceptance criterion for [reason]
- **2025-06-30**: Completed first two criteria
```

---

## Editing Epics

### 1. Epic Status Updates
Epics should reflect the aggregate status of their stories:

```javascript
// Calculate epic progress
const stories = await notion.databases.query({
  database_id: "21e0d2195e1c806a947ff1806bffa2fb",
  filter: {
    property: "Related Epic",
    relation: { contains: "epic-id" }
  }
});

const progress = calculateProgress(stories);

notion.pages.update({
  page_id: "epic-page-id",
  properties: {
    "Progress": { number: progress },
    "Status": { status: { name: determineStatus(progress) } }
  }
});
```

### 2. Adding Epic Notes
```markdown
## Progress Updates

### 2025-07-01 Update
- Completed 3 of 10 stories
- Blocker identified in Story 06-04 (EHR integration)
- Adjusted timeline by 2 weeks due to additional security requirements

### 2025-06-15 Update
- Epic kicked off, all stories defined
- Resources allocated
```

---

## Editing Projects

### 1. Project-Level Changes
Projects are high-level containers, so edits should be strategic:

```javascript
// Update project timeline
notion.pages.update({
  page_id: "project-page-id",
  properties: {
    "End Date": { date: { start: "2025-12-31" } },
    "Status": { status: { name: "In Progress" } },
    "Notes": { 
      rich_text: [{ 
        text: { 
          content: "Timeline extended due to scope expansion. See epic updates for details." 
        } 
      }] 
    }
  }
});
```

---

## Bulk Editing Operations

### 1. Updating Multiple Tasks
```javascript
// Example: Update all tasks in a story
const tasksToUpdate = await notion.databases.query({
  database_id: "21e0d2195e1c80a28c67dc2a8ed20e1b",
  filter: {
    and: [
      { property: "Related Story", relation: { contains: "story-id" } },
      { property: "Status", status: { equals: "Not Started" } }
    ]
  }
});

for (const task of tasksToUpdate.results) {
  await notion.pages.update({
    page_id: task.id,
    properties: {
      "Priority": { select: { name: "High" } },
      "Due Date": { date: { start: "2025-08-01" } }
    }
  });
}
```

### 2. Search and Replace
For file-based updates:
```bash
# Example: Update all instances of old terminology
find /epics-stories-tasks -name "*.md" -type f -exec sed -i '' 's/old-term/new-term/g' {} +
```

---

## Best Practices for Editing

### 1. Maintain Audit Trail
Always document:
- **Who** made the change
- **When** it was made
- **Why** it was necessary
- **What** was changed

### 2. Use Comments for Context
```markdown
## 💬 Comments
- **2025-07-01 @user**: Updated priority to High due to customer escalation
- **2025-06-30 @user**: Added security requirements per compliance review
```

### 3. Version Important Changes
For significant changes, consider:
- Creating a Knowledge Base entry documenting the change
- Keeping old version in comments
- Using strikethrough instead of deletion

### 4. Notify Stakeholders
- Update related team members when changing assignments
- Document blockers when changing status
- Link to discussion threads for major changes

---

## Integration with n8n Workflows

### Automated Edit Triggers
Configure n8n to:
- Auto-update parent items when children change
- Send notifications on status changes
- Create audit logs for significant edits
- Validate data consistency after bulk edits

### Edit Webhooks
```javascript
// n8n webhook for tracking edits
{
  "event": "page.updated",
  "database": "tasks",
  "changes": {
    "status": { "from": "Not Started", "to": "In Progress" },
    "assignee": { "from": null, "to": "user-id" }
  },
  "timestamp": "2025-07-01T10:30:00Z"
}
```

---

## Common Editing Scenarios

### 1. Task Blocked
- Update status to "Blocked"
- Add comment explaining blocker
- Update related story status if needed
- Create Knowledge Base entry if learning

### 2. Scope Change
- Update acceptance criteria
- Adjust estimates
- Document reason for change
- Update epic scope if significant

### 3. Reprioritization
- Update priority fields
- Adjust due dates
- Update sprint/iteration assignments
- Notify affected team members

### 4. Completion
- Update status to "Done"
- Record actual time spent
- Add implementation notes
- Link any created Knowledge Base entries

Remember: Every edit should improve clarity and maintain the integrity of the project management system!