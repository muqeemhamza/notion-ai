# Dynamic Entity Update Workflow

## Overview
This workflow processes inbox notes containing update instructions and intelligently applies changes to existing epics, stories, or tasks based on context matching and relevance scoring.

## Workflow Components

### 1. Trigger: Webhook from Inbox Processing
- **Source**: Called by Intelligent Inbox Processing when action_type = "update_existing"
- **Payload**: 
  - Inbox note content
  - Related items identified by AI
  - Update instructions
  - Context tags

### 2. Enrich Context
#### 2a. Get Full Related Items
- **Node**: Loop Over Items
- **Items**: Related item IDs from trigger
- **Inside Loop**: Notion - Get
  - Fetch complete details for each related item
  - Include all properties and relations

#### 2b. Get Parent/Child Relations
- **Node**: Function
- **Purpose**: Build relationship tree
- **Code**:
```javascript
const items = $items;
const relationships = {};

for (const item of items) {
  relationships[item.id] = {
    type: item.database, // epic, story, or task
    parents: [],
    children: []
  };
  
  // Map relations based on type
  if (item.database === 'task' && item.properties.Story) {
    relationships[item.id].parents.push(item.properties.Story.relation[0].id);
  }
  // Continue for other relations...
}

return relationships;
```

### 3. Analyze Update Intent (OpenAI Chat)
```json
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "system",
      "content": "Analyze the update request and determine:\n1. Specific changes to make\n2. Which items to update (with confidence scores)\n3. Change type (append, replace, modify)\n4. Dependencies that might be affected\n5. Validation requirements\n\nOutput detailed update plan as JSON."
    },
    {
      "role": "user",
      "content": "Update Request: {{$node['Trigger'].json.update_content}}\n\nRelated Items: {{JSON.stringify($node['Get Full Related Items'].json)}}\n\nRelationships: {{JSON.stringify($node['Get Parent/Child Relations'].json)}}\n\nOriginal Note: {{$node['Trigger'].json.inbox_note}}"
    }
  ],
  "temperature": 0.3,
  "max_tokens": 2000
}
```

### 4. Parse Update Plan
- **Node**: Function
- **Code**:
```javascript
const plan = JSON.parse($node['Analyze Update Intent'].json.choices[0].message.content);

// Sort updates by confidence score
plan.updates.sort((a, b) => b.confidence - a.confidence);

// Filter out low confidence updates (< 0.7)
const confirmedUpdates = plan.updates.filter(u => u.confidence >= 0.7);
const needsReview = plan.updates.filter(u => u.confidence < 0.7);

return {
  confirmed: confirmedUpdates,
  review: needsReview,
  dependencies: plan.dependencies,
  validation: plan.validation
};
```

### 5. Validation Branch
- **Node**: IF
- **Condition**: `{{$node['Parse Update Plan'].json.validation.required}}`

#### 5a. Run Validation Checks
- Check for conflicts with other pending updates
- Verify user permissions
- Validate data format requirements
- Check business rules

#### 5b. Handle Validation Failures
- Log validation errors
- Create review task for human intervention
- Send notification with details

### 6. Apply Updates Loop
- **Node**: Loop Over Items
- **Items**: Confirmed updates

#### Inside Loop:
##### 6a. Prepare Update Data
- **Node**: Function
- **Purpose**: Format update based on change type
```javascript
const update = $item;
const changeType = update.change_type;
const currentValue = update.current_value;
const newContent = update.new_content;

let finalValue;

switch(changeType) {
  case 'append':
    finalValue = currentValue + '\n\n' + newContent;
    break;
  case 'replace':
    finalValue = newContent;
    break;
  case 'modify':
    // Use regex or string manipulation
    finalValue = currentValue.replace(update.pattern, newContent);
    break;
  case 'insert':
    // Insert at specific position
    const position = update.position || currentValue.length;
    finalValue = currentValue.slice(0, position) + newContent + currentValue.slice(position);
    break;
}

return { 
  property: update.property,
  value: finalValue,
  item_id: update.item_id
};
```

##### 6b. Update Notion Item
- **Node**: Notion - Update
- **Database**: Dynamic based on item type
- **Properties**: From prepared update data

##### 6c. Add Update Comment
- **Node**: Notion - Add Comment
- **Content**: 
```
Update applied via Dynamic Entity Update workflow
Source: {{$node['Trigger'].json.inbox_note.title}}
Changes: {{$item.change_summary}}
Timestamp: {{$now.format('YYYY-MM-DD HH:mm:ss')}}
```

### 7. Handle Dependencies
- **Node**: IF
- **Condition**: Dependencies exist

#### 7a. Update Dependent Items
- Propagate date changes
- Update status based on rules
- Recalculate computed fields

#### 7b. Send Notifications
- Notify owners of dependent items
- Create follow-up tasks if needed

### 8. Process Review Items
- **Node**: IF
- **Condition**: Review items exist

#### 8a. Create Review Task
- **Node**: Notion - Create
- **Database**: Tasks
- **Properties**:
  - Title: "Review Update Request: [Summary]"
  - Description: Include original request and uncertainty reasons
  - Attachments: Link to related items
  - Priority: Based on impact

#### 8b. Human Review Loop (Optional)
- Send Slack notification
- Wait for human decision
- Apply approved updates

### 9. Update Knowledge Base
- **Node**: Notion - Create/Update
- **Purpose**: Capture update patterns
- **Entry Type**: "Update Pattern"
- **Content**:
  - Original request format
  - Successful interpretation
  - Applied changes
  - Confidence scores

### 10. Complete Inbox Item
- **Node**: Notion - Update
- **Database**: Inbox
- **Updates**:
  - Status: "Processed"
  - Category: "Update Applied"
  - Summary: List of updated items
  - Links: Relations to all updated items

## Advanced Features

### Semantic Search Enhancement
```javascript
// Use embeddings for better matching
const semanticSearch = async (query, items) => {
  const queryEmbedding = await getEmbedding(query);
  const scores = [];
  
  for (const item of items) {
    const itemEmbedding = await getEmbedding(item.content);
    const similarity = cosineSimilarity(queryEmbedding, itemEmbedding);
    scores.push({ item, similarity });
  }
  
  return scores.sort((a, b) => b.similarity - a.similarity);
};
```

### Update Patterns Library
Common patterns to recognize:
1. **Addition**: "Also add...", "Don't forget to include..."
2. **Correction**: "Change X to Y", "It should be..."
3. **Removal**: "Remove...", "Delete the part about..."
4. **Clarification**: "To clarify...", "More specifically..."
5. **Priority Change**: "Make this urgent", "This can wait"

### Conflict Resolution
When multiple items could be updated:
1. Score by relevance
2. Check recency (prefer recent items)
3. Consider hierarchy (prefer higher-level items)
4. Use explicit identifiers if provided

## Error Handling

### Rollback Capability
- Store original values before updates
- Implement undo functionality
- Log all changes for audit trail

### Partial Success Handling
- Continue with successful updates
- Report failed updates separately
- Maintain consistency across related items

## Example Scenarios

### Scenario 1: Adding to Task List
**Input**: "For the financial report task, also include YoY comparison charts"
**Process**:
1. Find tasks with "financial report" in title/description
2. Identify specific task based on context
3. Append requirement to task description
4. Update acceptance criteria if applicable
5. Add comment about the addition

### Scenario 2: Correcting Information
**Input**: "The API endpoint in the integration story should be /v2/data not /v1/data"
**Process**:
1. Search stories for "API endpoint" and "integration"
2. Find text pattern "/v1/data"
3. Replace with "/v2/data"
4. Flag dependent tasks for review
5. Update technical documentation links

### Scenario 3: Multi-Item Update
**Input**: "All Q1 marketing tasks should now include social media metrics"
**Process**:
1. Find all tasks with "Q1" and "marketing" tags
2. Append social media metrics requirement
3. Update acceptance criteria
4. Create knowledge base entry for new requirement
5. Notify task owners

## Performance Considerations

### Batch Processing
- Group updates by database
- Use bulk update operations where possible
- Minimize round trips to APIs

### Caching Strategy
- Cache frequently accessed items
- Store embeddings for semantic search
- Maintain update history for patterns

## Monitoring & Analytics

### Key Metrics:
- Update accuracy rate
- Average confidence score
- Updates per inbox note
- Rollback frequency
- Processing time

### Quality Checks:
- Human validation sampling
- Confidence score distribution
- Update pattern effectiveness
- User satisfaction with updates

## Integration Points

### Triggered By:
- Intelligent Inbox Processing Workflow
- Manual API calls
- Scheduled review processes

### Triggers:
- Dependency Management Workflow
- Notification workflows
- Audit logging systems

## Future Enhancements

1. **Version Control**: Track all changes with full history
2. **Bulk Operations**: Handle multiple updates in single request
3. **Smart Scheduling**: Time updates based on team availability
4. **Impact Analysis**: Predict ripple effects before applying
5. **Learning System**: Improve accuracy based on corrections
6. **Natural Language Variations**: Handle more conversational updates