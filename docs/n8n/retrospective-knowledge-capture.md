# Retrospective Knowledge Capture Workflow

## Overview
This workflow automatically extracts learnings, patterns, and reusable knowledge from completed stories and tasks, ensuring valuable insights are captured for future reference.

## Workflow Components

### 1. Trigger: Notion - On Database Item Updated
- **Databases**: Tasks and Stories
- **Filter**: Status changed to "Completed" or "Done"
- **Authentication**: Notion API

### 2. Get Complete Item Context
#### 2a. Get Item Details
- **Node**: Notion - Get
- **Purpose**: Fetch all properties, comments, and history
- **Fields**: All properties including timestamps, assignees, descriptions

#### 2b. Get Related Items
- **Node**: Notion - Get Many
- **Purpose**: Fetch parent story/epic and sibling tasks
- **Relations**: Follow Epic → Story → Task hierarchy

#### 2c. Get Item History
- **Node**: Notion - Get Page Property History
- **Properties**: Status, Description, Assignee
- **Purpose**: Track how item evolved over time

### 3. Extract Completion Metrics
- **Node**: Function
- **Code**:
```javascript
const item = $node['Get Item Details'].json;
const history = $node['Get Item History'].json;

// Calculate metrics
const createdAt = new Date(item.created_time);
const completedAt = new Date(item.last_edited_time);
const durationDays = Math.floor((completedAt - createdAt) / (1000 * 60 * 60 * 24));

// Count status changes
const statusChanges = history.filter(h => h.property === 'Status').length;

// Extract blockers from history
const blockPeriods = history
  .filter(h => h.property === 'Status' && h.value === 'Blocked')
  .map(h => ({ start: h.timestamp, reason: h.comment }));

return {
  duration: durationDays,
  statusChanges: statusChanges,
  blockers: blockPeriods,
  completionDate: completedAt,
  assignee: item.properties.Assignee?.people[0]?.name || 'Unassigned'
};
```

### 4. AI Learning Extraction (OpenAI Chat)
```json
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "system",
      "content": "Extract valuable learnings from this completed work item. Focus on:\n1. What worked well (success patterns)\n2. What challenges were faced (and solutions)\n3. Reusable knowledge or templates\n4. Process improvements discovered\n5. Technical insights or code patterns\n6. Time estimates vs actual\n7. Dependencies that weren't obvious\n8. Tools or resources that were helpful\n\nOutput as structured JSON with categories."
    },
    {
      "role": "user",
      "content": "Completed Item: {{JSON.stringify($node['Get Item Details'].json)}}\n\nMetrics: {{JSON.stringify($node['Extract Completion Metrics'].json)}}\n\nRelated Context: {{JSON.stringify($node['Get Related Items'].json)}}\n\nComments/Updates: {{$node['Get Item History'].json.comments}}"
    }
  ],
  "temperature": 0.7,
  "max_tokens": 2000
}
```

### 5. Parse and Categorize Learnings
- **Node**: Function
- **Code**:
```javascript
const learnings = JSON.parse($node['AI Learning Extraction'].json.choices[0].message.content);
const item = $node['Get Item Details'].json;

// Categorize by type
const categories = {
  technical: [],
  process: [],
  tools: [],
  estimation: [],
  dependencies: [],
  templates: []
};

// Sort learnings into categories
for (const learning of learnings.all_learnings) {
  const category = learning.category || 'process';
  if (categories[category]) {
    categories[category].push({
      ...learning,
      source_item: item.id,
      source_title: item.properties.Name.title[0].plain_text,
      project: item.properties.Project?.relation[0]?.id
    });
  }
}

// Generate tags based on content
const tags = [
  ...new Set([
    item.properties.Tags?.multi_select.map(t => t.name) || [],
    learnings.suggested_tags || [],
    categories.technical.length > 0 ? 'Technical' : null,
    categories.process.length > 0 ? 'Process' : null
  ].flat().filter(Boolean))
];

return { categories, tags, summary: learnings.summary };
```

### 6. Check for Similar Knowledge
- **Node**: Notion - Get Many
- **Database**: Knowledge Base
- **Filter**: Tags overlap OR title similarity
- **Purpose**: Avoid duplicates, find patterns

### 7. Create or Update Knowledge Entries
- **Node**: Switch
- **Condition**: New vs Update existing

#### Branch A: Create New Knowledge Entry
- **Node**: Notion - Create
- **Database**: Knowledge Base (`21e0d2195e1c802ca067e05dd1e4e908`)
- **Properties**:
  - Title: Generated from learning type
  - Key Insights: Main learnings
  - Context: Link to source item
  - Tags: Generated tags
  - Category: Primary category
  - Reusability Score: Based on applicability

#### Branch B: Update Existing Entry
- **Node**: Notion - Update
- **Action**: Append new insights
- **Update**: Increment usage counter
- **Add**: New source reference

### 8. Create Specific Artifacts
Based on learning type:

#### 8a. Code Templates
- **Condition**: Technical learnings with code
- **Action**: Create code snippet in Knowledge Base
- **Format**: Markdown with syntax highlighting

#### 8b. Process Templates
- **Condition**: Reusable process discovered
- **Action**: Create process template
- **Include**: Steps, checklist, common pitfalls

#### 8c. Estimation Guidelines
- **Condition**: Significant estimation variance
- **Action**: Create estimation guide
- **Include**: Factors affecting time, multipliers

### 9. Update Project Intelligence
- **Node**: Function
- **Purpose**: Aggregate learnings at project level
```javascript
const projectId = $node['Get Item Details'].json.properties.Project.relation[0].id;
const learnings = $node['Parse and Categorize Learnings'].json;

// Get existing project intelligence
const projectKB = await getProjectKnowledgeBase(projectId);

// Update patterns
projectKB.patterns = {
  ...projectKB.patterns,
  estimation_accuracy: updateEstimationAccuracy(projectKB, learnings),
  common_blockers: updateBlockers(projectKB, learnings),
  success_patterns: updateSuccessPatterns(projectKB, learnings)
};

return projectKB;
```

### 10. Generate Retrospective Report
- **Node**: Function
- **Output**: Markdown report
```javascript
const report = `
# Retrospective: ${item.title}

## Overview
- **Duration**: ${metrics.duration} days
- **Status Changes**: ${metrics.statusChanges}
- **Blockers**: ${metrics.blockers.length}

## Key Learnings

### What Worked Well
${learnings.categories.success.map(l => `- ${l.insight}`).join('\n')}

### Challenges & Solutions
${learnings.categories.challenges.map(l => `- **Challenge**: ${l.challenge}\n  **Solution**: ${l.solution}`).join('\n')}

### Reusable Knowledge
${learnings.categories.templates.map(l => `- [${l.title}](${l.link})`).join('\n')}

## Recommendations
${learnings.recommendations.join('\n')}

---
*Generated on ${new Date().toISOString()}*
`;

return { report };
```

### 11. Distribution & Notification
#### 11a. Add Report to Completed Item
- **Node**: Notion - Add Comment
- **Content**: Retrospective report

#### 11b. Notify Team (Optional)
- **Node**: Slack/Email
- **Recipients**: Team members, project lead
- **Content**: Summary of key learnings

#### 11c. Update Team Dashboard
- **Node**: HTTP Request
- **Endpoint**: Team metrics dashboard
- **Data**: Completion metrics, learnings count

## Advanced Features

### Pattern Recognition
```javascript
const findPatterns = (learnings, historicalData) => {
  const patterns = {
    recurring_blockers: [],
    estimation_patterns: [],
    success_factors: [],
    failure_modes: []
  };
  
  // Analyze across multiple completed items
  const similarItems = historicalData.filter(h => 
    h.tags.some(t => learnings.tags.includes(t))
  );
  
  // Extract common patterns
  // ... pattern matching logic
  
  return patterns;
};
```

### Learning Effectiveness Tracking
- Track which knowledge entries are most accessed
- Monitor reuse of templates and patterns
- Measure impact on future item completion times
- Identify high-value learnings

### Automated Insight Generation
Use AI to identify non-obvious insights:
- Cross-project patterns
- Seasonal variations in completion times
- Team performance patterns
- Technology-specific learnings

## Example Scenarios

### Scenario 1: Technical Task Completion
**Completed**: "Implement Redis caching for API"
**Extracted Learnings**:
- Redis setup configuration template
- Performance improvement metrics (40% faster)
- Common pitfalls with connection pooling
- Monitoring setup checklist

**Knowledge Created**:
- "Redis Implementation Guide" with code templates
- "API Performance Optimization Patterns"
- Updated project estimation guidelines

### Scenario 2: Complex Story Completion
**Completed**: "User Authentication System"
**Extracted Learnings**:
- Security best practices checklist
- Integration testing approach
- Third-party service evaluation criteria
- Timeline was 2x original estimate due to security reviews

**Knowledge Created**:
- "Authentication System Template"
- "Security Review Process"
- Updated estimation factors for security-related stories

### Scenario 3: Failed Approach Learning
**Completed**: "Data Migration Script" (after 3 attempts)
**Extracted Learnings**:
- Why first two approaches failed
- Data validation requirements missed initially
- Rollback strategy that worked
- Testing approach for large data sets

**Knowledge Created**:
- "Data Migration Checklist"
- "Common Migration Pitfalls"
- "Large Dataset Testing Strategies"

## Performance Considerations

### Batch Processing
- Process multiple completions together
- Aggregate learnings before KB updates
- Optimize AI calls with batched context

### Selective Processing
- Skip simple tasks with minimal learnings
- Focus on complex items and failures
- Prioritize items with high time variance

## Quality Assurance

### Learning Validation
- Human review for high-impact learnings
- Peer validation for technical insights
- Periodic review of auto-captured knowledge

### Continuous Improvement
- Track learning quality scores
- Refine AI prompts based on feedback
- Update categorization rules

## Monitoring & Metrics

### Key Metrics:
- Knowledge entries created per week
- Learning reuse frequency
- Average insights per completed item
- Knowledge base growth rate
- Search hit rate on KB entries

### Quality Indicators:
- Human validation rate
- Learning applicability score
- Cross-project relevance
- Time saved through reuse

## Integration Points

### Triggered By:
- Task/Story completion
- Manual retrospective request
- Sprint/cycle end

### Triggers:
- Knowledge Base indexing
- Team notification workflows
- Project intelligence updates
- Estimation model updates

## Future Enhancements

1. **Video Learning Capture**: Extract insights from recorded sessions
2. **Collaborative Retrospectives**: Multi-person learning sessions
3. **Learning Paths**: Suggest related knowledge based on current work
4. **Predictive Insights**: Warn about likely issues based on patterns
5. **Cross-Organization Learning**: Share sanitized learnings across teams
6. **AI Learning Assistant**: Proactive learning suggestions during work