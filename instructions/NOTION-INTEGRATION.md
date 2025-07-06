# 🔗 Notion Integration Guide

This guide explains how to integrate with Notion databases using MCP and prepare for n8n automation workflows.

## Integration Setup

### 1. Official Notion MCP Configuration
```bash
# Initialize Official Notion MCP with your integration token
# Note: We now use the official Notion MCP for comprehensive features
export NOTION_API_KEY="ntn_f35248778523jpOe6IQngDnseZlexMBsf2YC7jt6WEb9NF"

# The official Notion MCP provides enhanced capabilities including:
# - Full database operations (create, read, update, delete)
# - Advanced querying and filtering
# - Block-level content manipulation
# - Relationship management
# - Batch operations support
```

### 2. Database IDs Quick Reference
```javascript
const DATABASES = {
  projects: "2200d219-5e1c-81e4-9522-fba13a081601",
  epics: "21e0d2195e1c809bae77f183b66a78b2",
  stories: "21e0d2195e1c806a947ff1806bffa2fb",
  tasks: "21e0d2195e1c80a28c67dc2a8ed20e1b",
  inbox: "21e0d2195e1c80228d8cf8ffd2a27275",
  knowledgeBase: "21e0d2195e1c802ca067e05dd1e4e908"
};
```

---

## Common MCP Operations

### 1. Querying Items

#### Get All Tasks for a Story
```javascript
const storyTasks = await notion.databases.query({
  database_id: DATABASES.tasks,
  filter: {
    property: "Related Story",
    relation: {
      contains: "story-page-id"
    }
  },
  sorts: [{
    property: "Task Number",
    direction: "ascending"
  }]
});
```

#### Find Items by Status
```javascript
const activeTasks = await notion.databases.query({
  database_id: DATABASES.tasks,
  filter: {
    and: [
      {
        property: "Status",
        status: {
          equals: "In Progress"
        }
      },
      {
        property: "Assignee",
        people: {
          contains: "user-id"
        }
      }
    ]
  }
});
```

#### Search by Tags
```javascript
const aiTasks = await notion.databases.query({
  database_id: DATABASES.tasks,
  filter: {
    property: "Tags",
    multi_select: {
      contains: "AI-Products"
    }
  }
});
```

### 2. Creating Items with Relations

#### Create Task Linked to Story and Epic
```javascript
const newTask = await notion.pages.create({
  parent: { database_id: DATABASES.tasks },
  properties: {
    "Title": {
      title: [{
        text: { content: "Implement user authentication" }
      }]
    },
    "Task Number": {
      rich_text: [{
        text: { content: "06-01-01" }
      }]
    },
    "Status": {
      status: { name: "Not Started" }
    },
    "Priority": {
      select: { name: "High" }
    },
    "Related Story": {
      relation: [{ id: "story-page-id" }]
    },
    "Related Epic": {
      relation: [{ id: "epic-page-id" }]
    },
    "Tags": {
      multi_select: [
        { name: "Backend" },
        { name: "Security" }
      ]
    },
    "Estimated Time": {
      number: 8
    }
  },
  children: [
    {
      object: "block",
      type: "heading_1",
      heading_1: {
        rich_text: [{
          text: { content: "✅ Task Overview" }
        }]
      }
    },
    {
      object: "block",
      type: "paragraph",
      paragraph: {
        rich_text: [{
          text: { content: "Task description and details..." }
        }]
      }
    }
  ]
});
```

### 3. Updating Items

#### Update Multiple Properties
```javascript
await notion.pages.update({
  page_id: "task-page-id",
  properties: {
    "Status": {
      status: { name: "In Progress" }
    },
    "Assignee": {
      people: [{ id: "user-id" }]
    },
    "Start Date": {
      date: { start: new Date().toISOString() }
    },
    "Progress": {
      number: 25
    }
  }
});
```

#### Add Content Blocks
```javascript
await notion.blocks.children.append({
  block_id: "page-id",
  children: [
    {
      object: "block",
      type: "heading_2",
      heading_2: {
        rich_text: [{
          text: { content: "📝 Implementation Notes" }
        }]
      }
    },
    {
      object: "block",
      type: "bulleted_list_item",
      bulleted_list_item: {
        rich_text: [{
          text: { content: "Note 1: Important consideration" }
        }]
      }
    }
  ]
});
```

### 4. Bulk Operations

#### Update All Tasks in Epic
```javascript
async function updateEpicTasks(epicId, updates) {
  // Get all tasks for epic
  const tasks = await notion.databases.query({
    database_id: DATABASES.tasks,
    filter: {
      property: "Related Epic",
      relation: { contains: epicId }
    }
  });

  // Update each task
  const results = await Promise.all(
    tasks.results.map(task =>
      notion.pages.update({
        page_id: task.id,
        properties: updates
      })
    )
  );

  return {
    updated: results.length,
    taskIds: results.map(r => r.id)
  };
}
```

---

## Database Schema Reference

### Tasks Database Properties
```typescript
interface TaskProperties {
  Title: string;
  Status: "Not Started" | "In Progress" | "Review" | "Done" | "Blocked";
  Priority: "Critical" | "High" | "Medium" | "Low";
  Difficulty: "Simple" | "Moderate" | "Complex";
  Assignee: Person[];
  "Due Date": Date;
  "Start Date": Date;
  "Estimated Time": number;
  "Actual Time": number;
  "Related Story": Relation;
  "Related Epic": Relation;
  Tags: MultiSelect[];
  "Task Number": string;
  Progress: number;
  "Blocked Reason": string;
  "Created By": Person;
  "Last Updated": Date;
}
```

### Stories Database Properties
```typescript
interface StoryProperties {
  Title: string;
  Status: "To Do" | "In Progress" | "Review" | "Done";
  Priority: "Critical" | "High" | "Medium" | "Low";
  "Acceptance Criteria": string;
  "Technical Requirements": string;
  "Related Epic": Relation;
  "Related Tasks": Relation[];
  Tags: MultiSelect[];
  "Story Number": string;
  "Story Points": number;
  Dependencies: Relation[];
}
```

### Epics Database Properties
```typescript
interface EpicProperties {
  Title: string;
  Status: "Planning" | "In Progress" | "Blocked" | "Completed";
  Objective: string;
  "Related Project": Relation;
  "Related Stories": Relation[];
  "Related Tasks": Relation[];
  Tags: MultiSelect[];
  "Epic Number": string;
  Progress: number;
  "Start Date": Date;
  "End Date": Date;
  Owner: Person;
}
```

---

## n8n Integration Patterns

### 1. Webhook Triggers
```javascript
// n8n webhook configuration
{
  "webhookUrl": "https://your-n8n.com/webhook/notion-updates",
  "events": [
    "page.created",
    "page.updated",
    "page.deleted"
  ],
  "filters": {
    "database_id": DATABASES.tasks,
    "properties": ["Status", "Assignee"]
  }
}
```

### 2. Status Change Automation
```javascript
// n8n workflow: Auto-update story when all tasks complete
async function checkStoryCompletion(storyId) {
  const tasks = await notion.databases.query({
    database_id: DATABASES.tasks,
    filter: {
      property: "Related Story",
      relation: { contains: storyId }
    }
  });

  const allComplete = tasks.results.every(
    task => task.properties.Status.status.name === "Done"
  );

  if (allComplete) {
    await notion.pages.update({
      page_id: storyId,
      properties: {
        Status: { status: { name: "Review" } }
      }
    });
    
    // Trigger notification
    await sendNotification({
      type: "STORY_READY_FOR_REVIEW",
      storyId: storyId
    });
  }
}
```

### 3. Progress Calculation
```javascript
// Calculate and update epic progress
async function updateEpicProgress(epicId) {
  const stories = await notion.databases.query({
    database_id: DATABASES.stories,
    filter: {
      property: "Related Epic",
      relation: { contains: epicId }
    }
  });

  const totalPoints = stories.results.reduce(
    (sum, story) => sum + (story.properties["Story Points"]?.number || 0),
    0
  );

  const completedPoints = stories.results
    .filter(story => story.properties.Status.status.name === "Done")
    .reduce((sum, story) => sum + (story.properties["Story Points"]?.number || 0), 0);

  const progress = totalPoints > 0 ? Math.round((completedPoints / totalPoints) * 100) : 0;

  await notion.pages.update({
    page_id: epicId,
    properties: {
      Progress: { number: progress }
    }
  });
}
```

### 4. Cross-Database Sync
```javascript
// Sync task creation to inbox for review
async function createInboxEntry(task) {
  await notion.pages.create({
    parent: { database_id: DATABASES.inbox },
    properties: {
      Title: {
        title: [{
          text: { content: `Review: ${task.properties.Title.title[0].text.content}` }
        }]
      },
      Status: {
        select: { name: "To Convert" }
      },
      Tags: {
        multi_select: [{ name: "task-review" }]
      },
      Source: {
        rich_text: [{
          text: { content: `Auto-generated from task ${task.id}` }
        }]
      }
    }
  });
}
```

---

## Advanced Integration Patterns

### 1. Transactional Updates
```javascript
// Ensure all updates succeed or rollback
async function transactionalUpdate(updates) {
  const rollbackActions = [];
  
  try {
    for (const update of updates) {
      const original = await notion.pages.retrieve({ 
        page_id: update.pageId 
      });
      
      rollbackActions.push({
        pageId: update.pageId,
        properties: original.properties
      });
      
      await notion.pages.update({
        page_id: update.pageId,
        properties: update.properties
      });
    }
  } catch (error) {
    // Rollback on failure
    for (const action of rollbackActions) {
      await notion.pages.update(action);
    }
    throw error;
  }
}
```

### 2. Batch Processing
```javascript
// Process items in batches to respect rate limits
async function batchProcess(items, batchSize = 10) {
  const results = [];
  
  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    
    const batchResults = await Promise.all(
      batch.map(item => processItem(item))
    );
    
    results.push(...batchResults);
    
    // Rate limit pause
    if (i + batchSize < items.length) {
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }
  
  return results;
}
```

### 3. Change Detection
```javascript
// Detect what changed between versions
function detectChanges(oldPage, newPage) {
  const changes = {};
  
  for (const [key, value] of Object.entries(newPage.properties)) {
    const oldValue = oldPage.properties[key];
    
    if (JSON.stringify(oldValue) !== JSON.stringify(value)) {
      changes[key] = {
        old: oldValue,
        new: value
      };
    }
  }
  
  return changes;
}
```

### 4. Relationship Integrity
```javascript
// Ensure bidirectional relationships
async function linkStoryToEpic(storyId, epicId) {
  // Update story
  await notion.pages.update({
    page_id: storyId,
    properties: {
      "Related Epic": {
        relation: [{ id: epicId }]
      }
    }
  });
  
  // Update epic (if using bidirectional relation)
  const epic = await notion.pages.retrieve({ page_id: epicId });
  const currentStories = epic.properties["Related Stories"]?.relation || [];
  
  await notion.pages.update({
    page_id: epicId,
    properties: {
      "Related Stories": {
        relation: [...currentStories, { id: storyId }]
      }
    }
  });
}
```

---

## Error Handling

### Common Errors and Solutions
```javascript
async function robustNotionCall(fn, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (error.code === 'rate_limited') {
        // Wait and retry
        await new Promise(resolve => 
          setTimeout(resolve, Math.pow(2, i) * 1000)
        );
      } else if (error.code === 'validation_error') {
        // Log and handle validation errors
        console.error('Validation error:', error.message);
        throw error;
      } else if (error.status === 404) {
        // Page not found
        console.error('Page not found');
        throw error;
      }
    }
  }
  throw new Error('Max retries exceeded');
}
```

---

## Testing Integration

### Integration Test Template
```javascript
// Test your Notion integration
async function testIntegration() {
  console.log('Testing Notion Integration...');
  
  try {
    // Test 1: Connection
    const databases = await notion.search({
      filter: { property: 'object', value: 'database' }
    });
    console.log('✅ Connection successful');
    
    // Test 2: Query
    const tasks = await notion.databases.query({
      database_id: DATABASES.tasks,
      page_size: 1
    });
    console.log('✅ Query successful');
    
    // Test 3: Create (in test workspace)
    const testPage = await notion.pages.create({
      parent: { database_id: DATABASES.tasks },
      properties: {
        Title: {
          title: [{ text: { content: 'TEST - Delete Me' } }]
        },
        Tags: {
          multi_select: [{ name: 'test-data' }]
        }
      }
    });
    console.log('✅ Create successful');
    
    // Test 4: Update
    await notion.pages.update({
      page_id: testPage.id,
      properties: {
        Status: { status: { name: 'Done' } }
      }
    });
    console.log('✅ Update successful');
    
    // Cleanup
    await notion.pages.update({
      page_id: testPage.id,
      archived: true
    });
    console.log('✅ Cleanup successful');
    
    console.log('\n🎉 All tests passed!');
  } catch (error) {
    console.error('❌ Test failed:', error);
  }
}
```

Remember: Always test integrations in a safe environment before running on production data!