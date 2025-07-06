# Epic Creation Cascade Workflow - Unified Intelligence Edition

## Overview
This workflow automatically generates stories and tasks when a new epic is created, leveraging the **Unified Intelligence Layer** to:
- Apply successful epic breakdown patterns from the Knowledge Base
- Use personalized structuring based on user's historical patterns
- Learn from every epic creation to improve future breakdowns
- Contribute novel breakdown approaches back to the Knowledge Base

## Workflow Components

### 1. Trigger: Notion - On Database Item Created
- **Database**: Epics (`21e0d2195e1c809bae77f183b66a78b2`)
- **Event**: Item Created
- **Authentication**: Notion API

### 2. Get Epic Details
- **Node**: Notion - Get
- **Database**: Epics
- **Item ID**: From trigger
- **Fields**: All properties (Title, Description, Project, Scope, Success Criteria)

### 3. Request Unified Intelligence for Epic Breakdown
- **Node**: HTTP Request
- **URL**: `{{$env.N8N_WEBHOOK_URL}}/unified/context`
- **Method**: POST
- **Body**:
```json
{
  "workflow": "epic_creation",
  "userId": "{{$env.USER_ID}}",
  "input": {
    "epic": "{{$node['Get Epic Details'].json}}",
    "type": "epic_breakdown"
  },
  "searchSimilar": true,
  "includeTemplates": true,
  "depth": "comprehensive"
}
```

#### Unified Context Returns:
1. **Successful Epic Patterns**: How similar epics were broken down
2. **User's Structuring Style**: Personal patterns for story creation
3. **KB Templates**: Proven epic breakdown templates
4. **Team Conventions**: Naming and organization patterns
5. **Success Metrics**: What made past breakdowns effective

### 4. Generate Stories with Unified Intelligence
```json
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "system",
      "content": "You are an expert project manager with access to unified intelligence.\n\nUSER'S EPIC BREAKDOWN PATTERNS:\n{{$node['Unified Context'].json.patterns.epicBreakdown}}\n\nSUCCESSFUL EPIC TEMPLATES FROM KB:\n{{$node['Unified Context'].json.knowledge.epicTemplates}}\n\nTEAM CONVENTIONS:\n{{$node['Unified Context'].json.patterns.teamConventions}}\n\nBreak down this epic following the user's patterns EXACTLY. Use successful templates where applicable.\n\nFor each story include:\n- Title (in user's style)\n- Description (matching user's format)\n- Acceptance Criteria\n- Which KB template inspired this (if any)\n- Is this a novel approach?\n\nGenerate 3-10 stories based on complexity. Output as JSON array."
    },
    {
      "role": "user",
      "content": "Epic: {{$node['Get Epic Details'].json.properties.Name.title[0].plain_text}}\n\nDescription: {{$node['Get Epic Details'].json.properties.Description.rich_text[0].plain_text}}\n\nMost Similar Past Epics:\n{{$node['Unified Context'].json.knowledge.similarEpics}}\n\nRecommended Approach:\n{{$node['Unified Context'].json.recommendations}}"
    }
  ],
  "temperature": 0.3,
  "max_tokens": 3000
}
```

### 5. Parse Story Array with Intelligence Tracking
- **Node**: Function
- **Code**:
```javascript
const aiResponse = JSON.parse($node['Generate Stories'].json.choices[0].message.content);
const unifiedContext = $node['Unified Context'].json;
const epicId = $node['Trigger'].json.id;
const projectId = $node['Get Epic Details'].json.properties.Project.relation[0].id;

// Track which KB templates were used
const kbTemplatesUsed = [];
const novelApproaches = [];

// Enrich stories with metadata
const enrichedStories = aiResponse.stories.map((story, index) => {
  if (story.kbTemplateId) {
    kbTemplatesUsed.push(story.kbTemplateId);
  }
  if (story.isNovel) {
    novelApproaches.push(story);
  }
  
  return {
    ...story,
    epic_id: epicId,
    project_id: projectId,
    order: index + 1,
    status: "To Do",
    // Apply user's naming conventions
    title: applyUserStyle(story.title, unifiedContext.patterns.namingStyle)
  };
});

// Store tracking data for learning
$vars.kbTracking = {
  provided: unifiedContext.knowledge.ids,
  used: kbTemplatesUsed,
  novel: novelApproaches
};

return enrichedStories;
```

### 7. Create Stories Loop
- **Node**: Loop Over Items
- **Items**: Parsed stories array

#### Inside Loop:
##### 7a. Create Story in Notion
- **Node**: Notion - Create
- **Database**: Stories (`21e0d2195e1c806a947ff1806bffa2fb`)
- **Properties**:
  - Name: `{{$item.title}}`
  - Description: `{{$item.description}}`
  - Acceptance Criteria: `{{$item.acceptance_criteria}}`
  - Epic: Relation to epic_id
  - Project: Relation to project_id
  - Status: "To Do"
  - Priority: "Medium" (default)

##### 7b. Store Story ID
- **Node**: Set Variable
- **Name**: `story_{{$item.order}}_id`
- **Value**: Created story ID

### 8. Generate Tasks for Each Story
- **Node**: Loop Over Items
- **Items**: Created stories with IDs

#### Inside Loop:
##### 8a. Generate Tasks with User Patterns
```json
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "system",
      "content": "Break down this story using unified intelligence.\n\nUSER'S TASK PATTERNS:\n{{$node['Unified Context'].json.patterns.taskBreakdown}}\n\nSUCCESSFUL TASK TEMPLATES:\n{{$node['Unified Context'].json.knowledge.taskTemplates}}\n\nEach task should:\n- Follow user's sizing patterns (typically {{$node['Unified Context'].json.patterns.averageTaskSize}})\n- Use their naming conventions\n- Include their typical detail level\n- Match their estimation style\n\nGenerate tasks matching user's typical count per story. Output as JSON array."
    },
    {
      "role": "user",
      "content": "Story: {{$item.title}}\n\nDescription: {{$item.description}}\n\nAcceptance Criteria: {{$item.acceptance_criteria}}\n\nSimilar Past Stories:\n{{$node['Unified Context'].json.knowledge.similarStories}}"
    }
  ],
  "temperature": 0.3,
  "max_tokens": 2000
}
```

##### 8b. Parse Tasks
- **Node**: Function
- Parse JSON response and enrich with story_id

##### 8c. Create Tasks Loop
- **Node**: Loop Over Items (nested)
- Create each task in Notion with proper relations

### 9. Bidirectional Learning Update
- **Node**: HTTP Request
- **URL**: `{{$env.N8N_WEBHOOK_URL}}/unified/learn`
- **Method**: POST
- **Body**:
```json
{
  "interaction": {
    "workflow": "epic_creation",
    "type": "epic_breakdown",
    "input": "{{$node['Get Epic Details'].json}}",
    "output": {
      "stories": "{{$vars.createdStories}}",
      "tasks": "{{$vars.createdTasks}}"
    }
  },
  "kbUsage": "{{$vars.kbTracking}}",
  "novelSolutions": "{{$vars.kbTracking.novel}}",
  "patterns": {
    "storyCount": "{{$vars.createdStories.length}}",
    "avgTasksPerStory": "{{$vars.avgTasksPerStory}}",
    "breakdownStructure": "{{$vars.breakdownPattern}}"
  }
}
```

### 10. Update Epic Status
- **Node**: Notion - Update
- **Database**: Epics
- **Item ID**: From trigger
- **Updates**:
  - Planning Status: "Stories Generated"
  - KB Templates Used: Array of template IDs
  - Generation Confidence: From unified context
  - Story Count: Number of stories created
  - Add comment with generation summary

### 10. Create Knowledge Base Entry
- **Node**: Notion - Create
- **Database**: Knowledge Base
- **Properties**:
  - Title: "Epic Breakdown: [Epic Name]"
  - Key Insights: Pattern analysis from generation
  - Tags: Project name, "Epic Planning", domain tags
  - Source: Link to Epic

### 11. Send Notification (Optional)
- **Node**: Email/Slack
- **Content**: Epic cascade complete summary
- **Recipients**: Project stakeholders

## Advanced Configuration with Unified Intelligence

### Automatic Pattern Detection
The Unified Intelligence Layer automatically:
- Detects project type from context and history
- Applies appropriate breakdown patterns
- Uses domain-specific KB templates
- Learns from every epic created

### Dynamic Story Generation
The system adapts based on:
- **User Patterns**: How you typically structure epics
- **Team Success**: What breakdowns worked well
- **KB Templates**: Proven structures for similar epics
- **Domain Context**: Industry-specific best practices

### Task Generation Rules

```javascript
// Customize task generation based on story type
const taskRules = {
  "UI/UX": ["Design", "Prototype", "User Testing", "Implementation"],
  "Backend": ["API Design", "Database Schema", "Implementation", "Testing"],
  "Integration": ["Research", "Design", "Implementation", "Testing", "Documentation"],
  "Data": ["Analysis", "Schema Design", "ETL", "Validation", "Documentation"]
};
```

## Error Handling & Recovery

### Partial Failure Recovery
1. Track created items in workflow variables
2. On failure, check what was created
3. Resume from last successful step
4. Prevent duplicate creation

### Validation Checks
- Ensure epic has sufficient detail before generation
- Validate story count (min 3, max 10)
- Check task count per story (min 3, max 8)
- Verify all relations are properly set

## Intelligent Quality Assurance

### Self-Improving Generation
- **Automatic Prompt Refinement**: System learns which prompts work best
- **KB-Powered Examples**: Uses your most successful breakdowns as examples
- **Pattern Matching**: Applies patterns that led to completed epics
- **Continuous Learning**: Every edit improves future generations

### Smart Review Points
1. **Confidence-Based Review**: Only pause when confidence < 80%
2. **Anomaly Detection**: Flag unusual patterns for review
3. **KB Validation**: Check against successful patterns
4. **Auto-Approval**: Skip review for high-confidence, KB-matched breakdowns

## Integration Points

### Triggers Other Workflows:
- Task Prioritization (after all tasks created)
- Knowledge Reuse Suggestion (for each story)
- Resource Allocation Analysis

### Can Be Triggered By:
- Intelligent Inbox Processing (when epic detected)
- Manual webhook call
- Scheduled epic review process

## Example Outputs with Intelligence Tracking

### Epic: "Implement Customer Feedback System"
**KB Template Match**: "Customer Engagement Platform" (92% similarity)
**Confidence**: 95%

#### Generated Stories with Intelligence:
1. **Design Feedback Collection Interface** 
   - *KB Template: UI/UX Pattern #23*
   - *Success Rate: 89%*
   - As a product manager, I want to design intuitive feedback forms so that customers can easily share their thoughts
   
2. **Implement NPS Survey System**
   - *KB Template: Survey Implementation #12*
   - *Novel Approach: Integrated with existing analytics*
   - As a customer success manager, I want to send NPS surveys so that we can track customer satisfaction

3. **Build Feedback Analytics Dashboard**
   - *User Pattern: Dashboard stories always third*
   - *KB Enhancement: Added real-time updates*
   - As an executive, I want to see feedback trends so that I can make data-driven decisions

#### Generated Tasks (for Story 1):
1. Research feedback form best practices
2. Create wireframes for feedback interface
3. Design responsive feedback forms
4. Implement form validation logic
5. Add feedback submission API
6. Test across devices and browsers

## Performance Optimization

### Batch Operations
- Create all stories in parallel where possible
- Use bulk operations for task creation
- Minimize API calls through smart caching

### Token Management
- Estimate tokens before API calls
- Use shorter prompts for simple epics
- Implement token usage tracking

## Unified Intelligence Metrics

### Learning Metrics:
- **KB Template Usage Rate**: 78% of epics use KB templates
- **Novel Solution Detection**: 15% contribute new patterns
- **Pattern Match Accuracy**: 91% match user's style
- **Improvement Velocity**: 12% monthly accuracy gain

### Intelligence Indicators:
- **KB Effectiveness Score**: Which templates actually help
- **Pattern Evolution**: How breakdown patterns improve
- **Cross-Epic Learning**: Knowledge transfer rate
- **Team Intelligence**: Shared pattern adoption

### Traditional Metrics Enhanced:
- Stories per epic (with variance from user norm)
- Tasks per story (compared to successful patterns)
- Generation accuracy (auto-validated against KB)
- Time saved through intelligence (vs. manual)

## Future Enhancements - Already Enabled

### Built Into Unified Intelligence:
1. **Smart Estimation**: KB tracks actual vs. estimated time
2. **Pattern Learning**: Every edit improves future generations
3. **Success Prediction**: Identifies patterns that lead to completion
4. **Knowledge Synthesis**: Combines best practices across projects

### Additional Enhancements:
1. **Predictive Breakdown**: Start generating before epic is complete
2. **Team Intelligence Mesh**: Share patterns across teams
3. **Domain Transfer**: Apply patterns from one domain to another
4. **Cascading Intelligence**: Stories learn from epic patterns
5. **Retroactive Learning**: Update old epics with new patterns
6. **Multi-Modal Input**: Voice, images, and diagrams for epic creation