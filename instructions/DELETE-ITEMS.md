# 🗑️ Deleting Items Guide

This guide explains how to safely delete or archive items while maintaining data integrity and traceability in your project management system.

## ⚠️ Before You Delete - Critical Checklist

### Always Check:
1. **Dependencies**: What items link to this?
2. **History**: Is this needed for audit/compliance?
3. **Knowledge**: Any lessons learned to preserve?
4. **Alternative**: Can you archive instead of delete?
5. **Approval**: Do you have permission to delete?

> **Golden Rule**: When in doubt, archive don't delete!

---

## Deletion vs. Archiving

### When to Archive (Recommended)
- ✅ Completed items with historical value
- ✅ Cancelled items that had work done
- ✅ Items needed for reporting/metrics
- ✅ Anything with Knowledge Base entries
- ✅ Items with important comments/decisions

### When to Delete (Rare)
- ❌ Duplicate items created in error
- ❌ Test items in production
- ❌ Items with sensitive data that must be purged
- ❌ Spam or completely irrelevant items

---

## Safe Deletion Process

### 1. Pre-Deletion Checklist

```markdown
## Deletion Checklist for [Item Name]
- [ ] Check for dependent tasks/stories
- [ ] Check for Knowledge Base references
- [ ] Export any important comments
- [ ] Save any attachments elsewhere
- [ ] Document reason for deletion
- [ ] Get approval if required
- [ ] Create archive entry if needed
```

### 2. Checking Dependencies

```javascript
// Check task dependencies
const dependencies = await notion.databases.query({
  database_id: "21e0d2195e1c80a28c67dc2a8ed20e1b",
  filter: {
    or: [
      { property: "Related Story", relation: { contains: itemId } },
      { property: "Blocked By", relation: { contains: itemId } },
      { property: "Blocks", relation: { contains: itemId } }
    ]
  }
});

if (dependencies.results.length > 0) {
  console.warn(`⚠️ Found ${dependencies.results.length} dependent items!`);
  // Handle dependencies before deletion
}
```

### 3. Creating Deletion Record

Before deleting, create an audit entry:

```javascript
// Create deletion record in Knowledge Base
const deletionRecord = await notion.pages.create({
  parent: { database_id: "21e0d2195e1c802ca067e05dd1e4e908" },
  properties: {
    "Title": { 
      title: [{ 
        text: { content: `DELETED: ${itemTitle} (${itemId})` } 
      }] 
    },
    "Type": { select: { name: "Audit Log" } },
    "Tags": { 
      multi_select: [
        { name: "deletion" },
        { name: "audit" }
      ] 
    },
    "Status": { select: { name: "Archived" } }
  },
  children: [{
    object: "block",
    type: "paragraph",
    paragraph: {
      rich_text: [{
        text: {
          content: `
Deletion Record
===============
Item: ${itemTitle}
ID: ${itemId}
Type: ${itemType}
Deleted By: ${user}
Date: ${new Date().toISOString()}
Reason: ${reason}

Dependencies Handled: ${dependencyList}
Knowledge Preserved: ${knowledgeItems}
          `
        }
      }]
    }
  }]
});
```

---

## Deletion by Item Type

### Deleting Tasks

#### Safe Task Deletion
```javascript
async function safeDeleteTask(taskId, reason) {
  // 1. Get task details
  const task = await notion.pages.retrieve({ page_id: taskId });
  
  // 2. Check if task is completed
  if (task.properties.Status.status.name !== "Done" && 
      task.properties.Status.status.name !== "Cancelled") {
    throw new Error("Cannot delete active tasks. Complete or cancel first.");
  }
  
  // 3. Remove from story relationship
  const storyId = task.properties["Related Story"].relation[0]?.id;
  if (storyId) {
    // Update story to note task removal
    await addCommentToStory(storyId, `Task ${taskId} deleted: ${reason}`);
  }
  
  // 4. Archive before deletion
  await archiveItem(task, reason);
  
  // 5. Delete
  await notion.pages.update({
    page_id: taskId,
    archived: true  // Soft delete in Notion
  });
}
```

#### Task Deletion Rules
- ✅ Can delete if: Done, Cancelled, or Duplicate
- ❌ Cannot delete if: In Progress, Blocked, or has active dependencies
- ⚠️ Must preserve: Implementation notes, lessons learned

### Deleting Stories

#### Story Deletion is Complex
Stories should rarely be deleted. Instead:

```javascript
async function archiveStory(storyId, reason) {
  // 1. Check all tasks are handled
  const tasks = await getStoryTasks(storyId);
  const activeTasks = tasks.filter(t => 
    !["Done", "Cancelled", "Deleted"].includes(t.status)
  );
  
  if (activeTasks.length > 0) {
    throw new Error(`Cannot archive story with ${activeTasks.length} active tasks`);
  }
  
  // 2. Update story status
  await notion.pages.update({
    page_id: storyId,
    properties: {
      "Status": { status: { name: "Archived" } },
      "Archive Reason": { 
        rich_text: [{ text: { content: reason } }] 
      },
      "Archive Date": { 
        date: { start: new Date().toISOString() } 
      }
    }
  });
  
  // 3. Move to archive in file system
  await moveToArchive(`story-${storyId}`, reason);
}
```

### Deleting Epics

#### Epic Deletion Process
Epics should almost never be deleted. Archive instead:

```markdown
## Archived Epic: [Epic Name]

**Archive Date**: 2025-07-01
**Archived By**: @username
**Reason**: Project cancelled due to strategic pivot

### Summary of Work Completed
- Stories Completed: 5/10
- Tasks Completed: 23/50
- Time Invested: 120 hours

### Lessons Learned
[Preserve any important learnings]

### Related Documents
[Links to any preserved artifacts]
```

### Deleting Projects

Projects should NEVER be deleted. Only archive:

```javascript
// Archive project and all children
async function archiveProject(projectId, reason) {
  // This is a major operation requiring approval
  if (!hasApproval(projectId, 'ARCHIVE_PROJECT')) {
    throw new Error("Project archival requires executive approval");
  }
  
  // Archive all epics
  const epics = await getProjectEpics(projectId);
  for (const epic of epics) {
    await archiveEpic(epic.id, `Project archived: ${reason}`);
  }
  
  // Update project status
  await notion.pages.update({
    page_id: projectId,
    properties: {
      "Status": { status: { name: "Archived" } },
      "Archive Note": { 
        rich_text: [{ text: { content: generateArchiveReport(projectId) } }] 
      }
    }
  });
}
```

---

## Bulk Deletion Operations

### Cleaning Up Test Data
```javascript
// Safe bulk deletion of test items
async function cleanupTestData() {
  const testItems = await notion.databases.query({
    database_id: "21e0d2195e1c80a28c67dc2a8ed20e1b",
    filter: {
      property: "Tags",
      multi_select: { contains: "test-data" }
    }
  });
  
  console.log(`Found ${testItems.results.length} test items to delete`);
  
  // Create bulk deletion record
  const deletionBatch = {
    id: generateBatchId(),
    timestamp: new Date().toISOString(),
    items: testItems.results.map(i => ({ id: i.id, title: i.properties.Title })),
    reason: "Cleanup test data"
  };
  
  await createDeletionRecord(deletionBatch);
  
  // Delete items
  for (const item of testItems.results) {
    await notion.pages.update({
      page_id: item.id,
      archived: true
    });
  }
}
```

### Removing Duplicates
```javascript
// Intelligent duplicate removal
async function removeDuplicates(databaseId) {
  const items = await notion.databases.query({ database_id: databaseId });
  
  const duplicates = findDuplicates(items.results);
  
  for (const duplicate of duplicates) {
    // Keep the oldest, delete newer duplicates
    const toDelete = duplicate.items.slice(1);
    
    for (const item of toDelete) {
      // Merge any unique data into the kept item
      await mergeItemData(duplicate.items[0], item);
      
      // Delete the duplicate
      await safeDelete(item.id, "Duplicate removal");
    }
  }
}
```

---

## Recovery Procedures

### Soft Delete Recovery
```javascript
// Notion keeps archived items for 30 days
async function recoverItem(itemId) {
  try {
    await notion.pages.update({
      page_id: itemId,
      archived: false
    });
    
    // Add recovery note
    await addComment(itemId, "Item recovered from archive");
    
    return true;
  } catch (error) {
    console.error("Recovery failed:", error);
    return false;
  }
}
```

### Backup Before Deletion
```javascript
async function backupBeforeDelete(itemId) {
  const item = await notion.pages.retrieve({ page_id: itemId });
  
  // Export to JSON
  const backup = {
    metadata: {
      id: itemId,
      type: item.object,
      createdTime: item.created_time,
      lastEditedTime: item.last_edited_time,
      deletionTime: new Date().toISOString()
    },
    properties: item.properties,
    content: await getPageContent(itemId)
  };
  
  // Save backup
  await saveBackup(`backup-${itemId}.json`, backup);
  
  return backup;
}
```

---

## File System Cleanup

### Archiving Task Files
```bash
# Create archive structure
mkdir -p /archive/$(date +%Y)/$(date +%m)/tasks

# Move files to archive
mv task-*.md /archive/$(date +%Y)/$(date +%m)/tasks/

# Create archive manifest
cat > /archive/$(date +%Y)/$(date +%m)/MANIFEST.md << EOF
# Archive Manifest - $(date +%Y-%m-%d)

## Archived Items
- Tasks: $(ls tasks/*.md | wc -l) files
- Reason: ${REASON}
- Archived by: ${USER}

## File List
$(ls -la tasks/*.md)
EOF
```

### Cleanup Scripts
```bash
#!/bin/bash
# cleanup-completed-tasks.sh

# Archive completed tasks older than 90 days
find /epics-stories-tasks -name "task-*.md" -mtime +90 | while read file; do
  if grep -q "Status:.*Done" "$file"; then
    archive_path="/archive/$(date +%Y)/completed-tasks"
    mkdir -p "$archive_path"
    mv "$file" "$archive_path/"
    echo "Archived: $file"
  fi
done
```

---

## n8n Automation for Deletions

### Scheduled Cleanup Workflow
```json
{
  "name": "Scheduled Cleanup",
  "nodes": [
    {
      "name": "Monthly Trigger",
      "type": "n8n-nodes-base.cron",
      "parameters": {
        "cronTimes": {
          "item": [{
            "mode": "everyMonth",
            "dayOfMonth": 1,
            "hour": 2
          }]
        }
      }
    },
    {
      "name": "Find Old Completed Items",
      "type": "notion-query",
      "parameters": {
        "database": "{{ $json.database_id }}",
        "filter": {
          "and": [
            { "property": "Status", "equals": "Done" },
            { "property": "Last Modified", "before": "90 days ago" }
          ]
        }
      }
    },
    {
      "name": "Archive Items",
      "type": "custom-function",
      "parameters": {
        "code": "// Archive logic here"
      }
    }
  ]
}
```

### Deletion Approval Workflow
```javascript
// Require approval for deletions
async function requestDeletionApproval(itemId, reason) {
  // Create approval request
  const approval = await createApprovalRequest({
    type: "DELETION",
    item: itemId,
    reason: reason,
    requestedBy: currentUser,
    approvers: ["manager", "data-owner"]
  });
  
  // Wait for approval
  if (await waitForApproval(approval.id)) {
    await performDeletion(itemId);
  } else {
    throw new Error("Deletion request denied");
  }
}
```

---

## Best Practices Summary

### Do's ✅
- Always check dependencies first
- Create audit trails
- Preserve knowledge and lessons learned
- Use archiving over deletion
- Get approval for major deletions
- Backup before permanent deletion

### Don'ts ❌
- Never delete active items
- Don't delete without checking relationships
- Avoid deleting items with historical value
- Don't bypass approval processes
- Never bulk delete without review

### Recovery Tips 💡
- Notion keeps deleted items for 30 days
- Always create backups for critical items
- Use soft delete (archive) when possible
- Maintain deletion logs
- Test recovery procedures regularly

Remember: Deletion is permanent. Archive is reversible. Choose wisely!