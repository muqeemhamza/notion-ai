# Smart Dependency Management Workflow

## Overview
This workflow automatically tracks and updates dependencies between tasks, stories, and epics when status changes occur, ensuring proper sequencing and notification of blocked or unblocked work.

## Workflow Components

### 1. Trigger: Notion - On Database Item Updated
- **Databases**: Tasks, Stories, Epics (multiple triggers)
- **Filter**: Status property changed
- **Authentication**: Notion API

### 2. Get Updated Item Details
- **Node**: Notion - Get
- **Purpose**: Fetch complete item details including all relations
- **Fields**: All properties, especially Dependencies and Blocked By

### 3. Determine Dependency Type
- **Node**: Function
- **Code**:
```javascript
const item = $node['Get Updated Item Details'].json;
const itemType = $node['Trigger'].json.database_id;
const newStatus = item.properties.Status.status.name;
const oldStatus = $node['Trigger'].json.previous.properties.Status.status.name;

// Map database IDs to types
const dbTypeMap = {
  '21e0d2195e1c80a28c67dc2a8ed20e1b': 'task',
  '21e0d2195e1c806a947ff1806bffa2fb': 'story',
  '21e0d2195e1c809bae77f183b66a78b2': 'epic'
};

return {
  itemType: dbTypeMap[itemType],
  itemId: item.id,
  statusChange: {
    from: oldStatus,
    to: newStatus
  },
  isNowComplete: ['Completed', 'Done'].includes(newStatus),
  wasBlocked: oldStatus === 'Blocked',
  isNowBlocked: newStatus === 'Blocked'
};
```

### 4. Get Dependencies Network
#### 4a. Get Direct Dependencies
- **Node**: Notion - Get Many
- **Filter**: ID in Dependencies relation field
- **Purpose**: Items that this item depends on

#### 4b. Get Dependent Items
- **Node**: Notion - Get Many
- **Filter**: Dependencies relation contains current item ID
- **Purpose**: Items that depend on this item

#### 4c. Build Dependency Graph
- **Node**: Function
- **Purpose**: Create full dependency network
```javascript
const currentItem = $node['Determine Dependency Type'].json;
const dependencies = $node['Get Direct Dependencies'].json;
const dependents = $node['Get Dependent Items'].json;

// Build graph structure
const graph = {
  current: currentItem,
  blockedBy: dependencies.filter(d => d.properties.Status.status.name !== 'Completed'),
  blocking: dependents.filter(d => d.properties.Status.status.name === 'Blocked'),
  canUnblock: dependents.filter(d => {
    // Check if this was the only blocker
    const blockers = d.properties.Dependencies.relation;
    const otherBlockers = blockers.filter(b => b.id !== currentItem.itemId);
    return otherBlockers.length === 0;
  })
};

return graph;
```

### 5. Process Status Change Impact
- **Node**: Switch
- **Mode**: Based on status change type

#### Branch A: Item Completed
##### 5a. Check Dependents to Unblock
- **Node**: Loop Over Items
- **Items**: Potentially unblockable dependents

###### Inside Loop:
1. **Check All Dependencies**
   - Get all dependencies for dependent item
   - Verify all are now complete
   
2. **Update Status if Unblocked**
   - Change from "Blocked" to "To Do" or "Ready"
   - Add comment about unblocking
   
3. **Send Notification**
   - Notify assignee that work is unblocked
   - Include link to newly available item

##### 5b. Update Parent Progress
- Check if all sibling items are complete
- Update parent story/epic progress percentage
- Potentially mark parent as complete

#### Branch B: Item Blocked
##### 5a. Cascade Block Status
- **Node**: Loop Over Items
- **Items**: Dependent items not already blocked

###### Inside Loop:
1. **Update to Blocked**
   - Change status to "Blocked"
   - Add blocking reason in comments
   
2. **Notify Affected Teams**
   - Send notifications about new blockers
   - Include dependency chain information

#### Branch C: Item Reactivated
##### 5a. Re-evaluate Dependencies
- Check if dependencies are still valid
- Update dependency health scores
- Flag any circular dependencies

### 6. AI Dependency Analysis (OpenAI Chat)
```json
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "system",
      "content": "Analyze this dependency change and provide:\n1. Impact assessment\n2. Suggested actions\n3. Risk identification\n4. Timeline implications\n5. Alternative approaches\n\nConsider project context and deadlines."
    },
    {
      "role": "user",
      "content": "Status Change: {{JSON.stringify($node['Determine Dependency Type'].json)}}\n\nDependency Graph: {{JSON.stringify($node['Build Dependency Graph'].json)}}\n\nProject Context: {{$node['Get Updated Item Details'].json.properties.Project}}"
    }
  ],
  "temperature": 0.5,
  "max_tokens": 1000
}
```

### 7. Process AI Recommendations
- **Node**: Function
- Parse AI analysis and create actionable items

### 8. Update Dependency Health Metrics
- **Node**: Notion - Update (Multiple)
- **Updates**:
  - Dependency health score
  - Blocked duration (if applicable)
  - Critical path indicator
  - Risk level

### 9. Create/Update Dependency Visualization
- **Node**: Function
- **Purpose**: Generate mermaid diagram or similar
```javascript
const graph = $node['Build Dependency Graph'].json;

let mermaid = 'graph TD\n';
mermaid += `  ${graph.current.itemId}[${graph.current.title} - ${graph.current.statusChange.to}]\n`;

// Add blocked by connections
graph.blockedBy.forEach(item => {
  mermaid += `  ${item.id}[${item.properties.Name.title[0].plain_text}] --> ${graph.current.itemId}\n`;
});

// Add blocking connections
graph.blocking.forEach(item => {
  mermaid += `  ${graph.current.itemId} --> ${item.id}[${item.properties.Name.title[0].plain_text}]\n`;
});

return { diagram: mermaid };
```

### 10. Knowledge Base Update
- **Node**: Notion - Create/Update
- **Purpose**: Track dependency patterns
- **Content**:
  - Common blocking patterns
  - Resolution strategies
  - Timeline impacts
  - Team dependencies

## Advanced Features

### Critical Path Analysis
```javascript
// Identify items on critical path
const findCriticalPath = (items) => {
  // Implementation of CPM algorithm
  const criticalPath = [];
  
  // Calculate earliest start/finish times
  // Calculate latest start/finish times
  // Identify zero-slack activities
  
  return criticalPath;
};
```

### Circular Dependency Detection
```javascript
const detectCircular = (graph) => {
  const visited = new Set();
  const recursionStack = new Set();
  
  const hasCycle = (node) => {
    visited.add(node);
    recursionStack.add(node);
    
    for (const neighbor of graph[node] || []) {
      if (!visited.has(neighbor)) {
        if (hasCycle(neighbor)) return true;
      } else if (recursionStack.has(neighbor)) {
        return true;
      }
    }
    
    recursionStack.delete(node);
    return false;
  };
  
  // Check all nodes
  for (const node of Object.keys(graph)) {
    if (!visited.has(node)) {
      if (hasCycle(node)) return true;
    }
  }
  
  return false;
};
```

### Smart Notifications
Notification rules based on:
- **Urgency**: Critical path items get immediate notifications
- **Impact**: High-impact unblocking gets priority
- **Team**: Notify only relevant team members
- **Time**: Respect working hours and time zones

## Error Handling

### Dependency Conflicts
- Detect when manual changes conflict with dependencies
- Flag inconsistent states
- Suggest resolution steps

### Recovery Mechanisms
- Store dependency state history
- Allow rollback of dependency changes
- Maintain audit trail

## Example Scenarios

### Scenario 1: Task Completion Cascade
**Trigger**: Development task "API Implementation" marked complete
**Process**:
1. Find dependent task "API Testing" (blocked)
2. Check other dependencies - all complete
3. Unblock "API Testing" → "Ready for Testing"
4. Notify QA team
5. Update story progress to 60%

### Scenario 2: Story Blocked
**Trigger**: Story "Payment Integration" marked blocked
**Process**:
1. Find all child tasks
2. Mark uncompleted tasks as blocked
3. Find dependent stories
4. Add warning to dependent stories
5. Calculate project impact
6. Suggest mitigation strategies

### Scenario 3: Circular Dependency Detected
**Trigger**: New dependency added creating cycle
**Process**:
1. Detect circular reference
2. Prevent dependency addition
3. Alert user with visualization
4. Suggest alternative structure
5. Log attempt for analysis

## Performance Optimization

### Caching Strategy
- Cache dependency graphs for complex projects
- Update incrementally on changes
- Refresh fully on major updates

### Batch Processing
- Group notifications by team
- Batch status updates
- Optimize API calls

## Monitoring & Metrics

### Key Metrics:
- Average blocking duration
- Dependency chain depth
- Unblocking velocity
- Circular dependency frequency
- Critical path accuracy

### Health Indicators:
- Percentage of blocked items
- Average dependencies per item
- Dependency resolution time
- Team interdependency score

## Integration Points

### Triggers:
- Status update notifications
- Timeline adjustment workflows
- Resource reallocation processes
- Risk management systems

### Can Be Triggered By:
- Any status change in tasks/stories/epics
- Manual dependency updates
- Bulk import processes

## Configuration Options

### Customizable Rules:
```javascript
const dependencyRules = {
  autoUnblock: true, // Automatically unblock when dependencies complete
  cascadeBlocks: true, // Cascade blocked status to dependents
  notifyOnUnblock: true, // Send notifications when items unblock
  blockOnIncomplete: false, // Block items with incomplete dependencies
  allowCircular: false, // Prevent circular dependencies
  maxChainDepth: 5 // Maximum dependency chain depth
};
```

### Team Preferences:
- Notification channels (Email, Slack, etc.)
- Working hours for notifications
- Escalation rules for critical blocks
- Dependency visualization preferences

## Future Enhancements

1. **Predictive Blocking**: AI predicts likely blocks before they occur
2. **Auto-Resolution**: Suggest and implement dependency restructuring
3. **Cross-Project Dependencies**: Handle dependencies across projects
4. **Resource-Based Dependencies**: Include people and resource dependencies
5. **Time-Based Dependencies**: Handle date-driven dependencies
6. **Dependency Templates**: Reusable dependency patterns for common workflows