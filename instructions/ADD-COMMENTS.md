# 💬 Adding Comments Guide

This guide explains how to effectively add comments to Projects, Epics, Stories, and Tasks to maintain clear communication and documentation.

## Why Comments Matter

Comments provide:
- **Context**: Why decisions were made
- **History**: What happened and when
- **Communication**: Team updates and discussions
- **Knowledge**: Lessons learned and gotchas
- **Traceability**: Audit trail of changes

---

## Comment Types and Formats

### 1. Status Update Comments
```markdown
## 💬 Comments

**2025-07-01 10:30 AM @username**
Status Update: Moved to In Progress. Started implementation of core functionality.
- Completed initial setup
- Database schema ready
- Next: API endpoint development

---
```

### 2. Blocker/Issue Comments
```markdown
**2025-07-01 2:45 PM @username** 🚨 **BLOCKER**
Cannot proceed with integration - API credentials not received from vendor.
- Contacted vendor support (Ticket #12345)
- Expected resolution: 2025-07-03
- Workaround: Using mock data for development

---
```

### 3. Decision Comments
```markdown
**2025-07-01 4:00 PM @teamlead** 📋 **DECISION**
Chose PostgreSQL over MongoDB for this service.
- Reason: Strong consistency requirements
- Trade-off: Slightly more complex queries
- Approved by: @architect
[Link to decision record in Knowledge Base]

---
```

### 4. Review/Feedback Comments
```markdown
**2025-07-02 11:00 AM @reviewer** 👀 **REVIEW**
Code review completed. Suggestions:
- [ ] Add error handling for edge case X
- [ ] Improve variable naming in function Y
- [x] Update documentation
Overall looks good, minor changes requested.

---
```

### 5. Completion Comments
```markdown
**2025-07-03 3:30 PM @developer** ✅ **COMPLETED**
Task completed successfully.
- All acceptance criteria met
- Unit tests passing (98% coverage)
- Documentation updated
- Actual time: 12 hours (vs 10 hour estimate)
Lessons learned: Authentication setup took longer than expected.

---
```

---

## Adding Comments via Notion MCP

### 1. Adding to Task/Story/Epic Page
```javascript
// Add comment block to page
notion.blocks.children.append({
  block_id: "page-id",
  children: [{
    object: "block",
    type: "divider",
    divider: {}
  }, {
    object: "block",
    type: "paragraph",
    paragraph: {
      rich_text: [{
        text: {
          content: `**${new Date().toISOString().split('T')[0]} @${user}**\n${commentText}`
        },
        annotations: {
          bold: true
        }
      }]
    }
  }]
});
```

### 2. Using Notion's Native Comments
```javascript
// Add comment to specific property
notion.comments.create({
  parent: { page_id: "page-id" },
  rich_text: [{
    text: {
      content: "This is a comment on the specific property or page"
    }
  }]
});
```

### 3. Structured Comment System
```javascript
// Add structured comment with metadata
const comment = {
  timestamp: new Date().toISOString(),
  author: "username",
  type: "STATUS_UPDATE", // BLOCKER, DECISION, REVIEW, etc.
  content: "Comment content here",
  tags: ["important", "technical-debt"],
  relatedItems: ["task-123", "story-456"]
};

notion.blocks.children.append({
  block_id: "page-id",
  children: [{
    object: "block",
    type: "callout",
    callout: {
      rich_text: [{
        text: { content: formatComment(comment) }
      }],
      icon: { emoji: getEmojiForType(comment.type) }
    }
  }]
});
```

---

## Comment Best Practices

### 1. Be Specific and Actionable
❌ Bad: "This doesn't work"
✅ Good: "API returns 404 error when calling /users endpoint with empty ID parameter"

### 2. Include Context
❌ Bad: "Changed the approach"
✅ Good: "Switched from REST to GraphQL API due to N+1 query issues discovered during load testing"

### 3. Tag Relevant People
```markdown
**2025-07-01 @developer**
Need input from @designer on the UI mockups before proceeding.
@projectmanager - FYI, this might delay our timeline by 2 days.
```

### 4. Use Consistent Formatting
```markdown
**Date Time @Author** [Optional Emoji/Tag]
[Comment content]
- Bullet points for lists
- [ ] Checkboxes for action items
[Links to relevant resources]
---
```

---

## Comment Templates

### 1. Daily Standup Comment
```markdown
**2025-07-01 Daily Update @username**
📅 **Yesterday:** Completed API endpoint for user creation
📅 **Today:** Working on validation logic and error handling
🚧 **Blockers:** None
💭 **Notes:** Might finish earlier than estimated
```

### 2. Sprint Retrospective Comment
```markdown
**2025-07-01 Sprint Retro @teamlead**
🎯 **What went well:**
- Completed all planned stories
- Good collaboration on complex features

🔧 **What could improve:**
- Better estimation on integration tasks
- More frequent code reviews

💡 **Action items:**
- [ ] Set up daily code review sessions
- [ ] Create integration checklist
```

### 3. Technical Note Comment
```markdown
**2025-07-01 Technical Note @developer** ⚙️
Important: This service requires minimum Node.js v18.0
- Uses native fetch API
- Requires ES modules
- Environment variables must be set before startup
See setup guide: [link to documentation]
```

### 4. Customer Feedback Comment
```markdown
**2025-07-01 Customer Feedback @productowner** 💬
Customer (Acme Corp) requested:
- Ability to export data in CSV format
- Bulk operations for efficiency
- API rate limiting concerns
Priority: High - Major client
[Link to full feedback document]
```

---

## Automated Comments via n8n

### 1. Status Change Notifications
```javascript
// n8n workflow to add automatic status comments
if (statusChanged) {
  const comment = `**${timestamp} @system** 🔄
Status changed from '${oldStatus}' to '${newStatus}'
Triggered by: ${triggerEvent}`;
  
  addCommentToNotion(taskId, comment);
}
```

### 2. Due Date Reminders
```javascript
// Automated reminder comments
const daysUntilDue = calculateDaysUntilDue(task.dueDate);
if (daysUntilDue === 3) {
  const comment = `**${timestamp} @system** ⏰ **REMINDER**
This task is due in 3 days (${task.dueDate})
Current status: ${task.status}
Assignee: @${task.assignee}`;
  
  addCommentToNotion(task.id, comment);
}
```

### 3. Integration Comments
```javascript
// Comments from external systems
const githubPR = webhook.data;
const comment = `**${timestamp} @github-bot** 🔗
Pull Request #${githubPR.number} ${githubPR.action}
Title: ${githubPR.title}
Author: ${githubPR.author}
[View PR](${githubPR.url})`;

addCommentToNotion(relatedTaskId, comment);
```

---

## Comment Organization

### 1. Pinned/Important Comments
Mark critical comments at the top:
```markdown
## 📌 Pinned Comments

**⚠️ IMPORTANT - READ FIRST**
This feature requires security review before deployment.
Contact @security-team before merging.

---

## 💬 Discussion Thread
[Regular comments below...]
```

### 2. Threaded Discussions
Organize related comments:
```markdown
## 💬 Comment Thread: API Design Discussion

**2025-07-01 @architect** - Initial proposal
Should we use REST or GraphQL for this service?

  **2025-07-01 @developer1** - Reply
  GraphQL would solve our over-fetching problem
  
    **2025-07-01 @developer2** - Reply to reply
    Agree, but adds complexity. Team familiar with it?

**2025-07-02 @architect** - Conclusion
Decision: Going with GraphQL. Team training scheduled.
```

### 3. Comment Categories
Organize by type:
```markdown
## 💬 Comments

### 🚨 Blockers & Issues
[Blocker comments here]

### 📋 Decisions & Changes
[Decision comments here]

### 📝 Status Updates
[Progress comments here]

### 💡 Ideas & Suggestions
[Improvement comments here]
```

---

## Quick Reference

### Comment Emojis
- 🚨 Blocker/Critical Issue
- 📋 Decision Made
- 💡 Idea/Suggestion
- ✅ Completed/Resolved
- 🔄 Status Change
- 👀 Review/Feedback
- ⏰ Time-Sensitive
- 🔗 External Link/Integration
- ⚙️ Technical Note
- 💬 Discussion/Question

### Comment Triggers for n8n
1. Status changes
2. Assignment changes
3. Due date approaching
4. Blocker added
5. External system updates
6. Review completed
7. Milestone reached

Remember: Good comments tell the story of your project and help future team members understand the journey!