# Intelligent Inbox Processing Workflow - Unified Intelligence Edition

## Overview
This advanced workflow processes new inbox notes using the **Unified Intelligence Layer** that combines:
- **Context Management**: User patterns and preferences
- **Learning Engine**: Continuous improvement from past interactions
- **Knowledge Base**: Active retrieval and contribution of proven solutions

The system learns from every interaction, making future processing more accurate and personalized.

## Workflow Components

### 1. Trigger: Notion - On Database Item Created
- **Database**: Inbox (`21e0d2195e1c80228d8cf8ffd2a27275`)
- **Event**: Item Created
- **Authentication**: Notion API

### 2. Request Unified Intelligence Context
- **Node**: HTTP Request
- **URL**: `{{$env.N8N_WEBHOOK_URL}}/unified/context`
- **Method**: POST
- **Body**:
```json
{
  "workflow": "inbox_processing",
  "userId": "{{$env.USER_ID}}",
  "input": "{{$node['Trigger'].json.properties.Name.title[0].plain_text}}",
  "keywords": "{{extractKeywords($node['Trigger'].json)}}",
  "includeKB": true,
  "depth": "comprehensive"
}
```

#### What Unified Context Provides:
1. **User Patterns**: How this user typically classifies and structures items
2. **Relevant KB Solutions**: Proven approaches for similar inbox items
3. **Active Work Context**: Current epics, stories, tasks
4. **Success Patterns**: What has worked well in the past
5. **Personalization Data**: User's writing style and preferences

### 3. AI Analysis (OpenAI Chat)
```json
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "system",
      "content": "You are an AI assistant with access to unified intelligence. Analyze the inbox note using:\n\nUSER PATTERNS:\n{{$node['Unified Context'].json.patterns}}\n\nRELEVANT KB SOLUTIONS:\n{{$node['Unified Context'].json.knowledge.solutions}}\n\nCURRENT WORK CONTEXT:\n{{$node['Unified Context'].json.state}}\n\nDetermine:\n1. Classification (To Convert/Sticky/Archive)\n2. Action type (update_existing/create_new/knowledge_only)\n3. Entity type if creating (epic/story/task)\n4. Related existing items if updating\n5. Which KB solutions apply (by ID)\n6. Is this a novel solution worth capturing?\n7. Tags and context\n\nFollow the user's patterns exactly. Indicate which KB entries influenced your decision.\nRespond in JSON format."
    },
    {
      "role": "user",
      "content": "Inbox Note: {{$node['Trigger'].json.properties.Name.title[0].plain_text}}\n\nTop KB suggestions for this context:\n{{$node['Unified Context'].json.knowledge.top3}}\n\nSimilar past actions:\n{{$node['Unified Context'].json.patterns.similarActions}}"
    }
  ]
}
```

### 4. Parse Enhanced AI Response
- **Node**: Function
- **Code**:
```javascript
const aiResponse = JSON.parse($node['AI Analysis'].json.choices[0].message.content);
const unifiedContext = $node['Unified Context'].json;

return {
  // Standard classification
  classification: aiResponse.classification,
  action_type: aiResponse.action_type,
  entity_type: aiResponse.entity_type || null,
  related_items: aiResponse.related_items || [],
  tags: aiResponse.tags || [],
  
  // Enhanced with unified intelligence
  usedKBEntries: aiResponse.usedKBEntries || [],
  kbEffectiveness: aiResponse.kbApplicationScore || 0,
  isNovelSolution: aiResponse.isNovelSolution || false,
  novelSolutionDetails: aiResponse.novelSolutionDetails || null,
  
  // Personalized content
  title: aiResponse.suggested_title || $node['Trigger'].json.properties.Name.title[0].plain_text,
  description: aiResponse.enhanced_description || null,
  
  // Context tracking
  contextUsed: {
    patterns: unifiedContext.patterns,
    kbProvided: unifiedContext.knowledge.ids,
    confidence: aiResponse.confidence || 0.8
  }
};
```

### 5. Route Based on Action Type
- **Node**: Switch
- **Mode**: Expression
- **Output**: Route to appropriate action branch

#### Branch A: Update Existing Items
For each related item:
1. **Get Current Item** (Notion - Get)
2. **Merge Updates** (Function node)
3. **Update Item** (Notion - Update)
4. **Add Comment** with update details

#### Branch B: Create New Entity
Based on entity_type:

##### Create Epic:
1. **Create Epic** (Notion - Create)
   - Use Epic template
   - Set properties from AI analysis
2. **Trigger Epic Cascade** (HTTP Request to Epic Creation Cascade workflow)

##### Create Story:
1. **Determine Parent Epic** (AI or user selection)
2. **Create Story** (Notion - Create)
   - Link to parent Epic
3. **Trigger Story → Task workflow**

##### Create Task:
1. **Determine Parent Story** (AI or user selection)
2. **Create Task** (Notion - Create)
   - Link to parent Story

### 6. Knowledge Base Bidirectional Update
#### 6a. Create Novel Solution KB Entry
- **Condition**: If isNovelSolution === true
- **Action**: Create new Knowledge Base entry
  - Title: Generated from interaction
  - Type: 'solution' or 'pattern'
  - Content: Novel solution details
  - Embeddings: Generate for similarity search
  - Triggers: Extract keywords and patterns
  - Link to source inbox note and created items

#### 6b. Update KB Effectiveness
- **Condition**: If usedKBEntries.length > 0
- **Action**: Update effectiveness metrics
  - Track which KB entries were provided
  - Record which were actually used
  - Calculate effectiveness score
  - Update user-specific KB metrics

### 7. Update Inbox Note
- **Node**: Notion - Update
- **Updates**:
  - Set Category (classification)
  - Set Processed: true
  - Add processing summary
  - Link to created/updated items

### 8. Bidirectional Learning Update
- **Node**: HTTP Request
- **URL**: `{{$env.N8N_WEBHOOK_URL}}/unified/learn`
- **Method**: POST
- **Body**:
```json
{
  "interaction": {
    "workflow": "inbox_processing",
    "input": "{{$node['Trigger'].json}}",
    "aiResponse": "{{$node['Parse Enhanced AI Response'].json}}",
    "outcome": "{{$node['Execute Action'].json}}"
  },
  "kbUsage": {
    "provided": "{{$node['Unified Context'].json.knowledge.ids}}",
    "used": "{{$node['Parse Enhanced AI Response'].json.usedKBEntries}}",
    "effectiveness": "{{$node['Parse Enhanced AI Response'].json.kbEffectiveness}}"
  },
  "novelSolution": "{{$node['Parse Enhanced AI Response'].json.isNovelSolution}}"
}
```

### 9. Error Handling with Learning
- **Node**: Error Trigger
- **Actions**:
  - Log error details
  - Update inbox note with error status
  - Send error pattern to learning engine
  - Track failure patterns for improvement
  - Send notification (optional)

## Configuration Requirements

### Environment Variables
- `NOTION_API_KEY`: Your Notion integration token
- `OPENAI_API_KEY`: Your OpenAI API key
- `INBOX_DB_ID`: 21e0d2195e1c80228d8cf8ffd2a27275
- `EPICS_DB_ID`: 21e0d2195e1c809bae77f183b66a78b2
- `STORIES_DB_ID`: 21e0d2195e1c806a947ff1806bffa2fb
- `TASKS_DB_ID`: 21e0d2195e1c80a28c67dc2a8ed20e1b
- `KNOWLEDGE_DB_ID`: 21e0d2195e1c802ca067e05dd1e4e908

### AI Model Settings
- **Model**: gpt-4 (recommended) or gpt-3.5-turbo
- **Temperature**: 0.3 (for consistent classification)
- **Max Tokens**: 1500

## Advanced Features

### Context Window Management
- Limit context items to most relevant (top 10 per category)
- Use embedding similarity for better matching
- Cache frequently accessed items

### Batch Processing
- Process multiple inbox notes in sequence
- Aggregate related updates
- Optimize API calls

### Unified Learning Loop Features
- **Pattern Recognition**: Automatically learns user's classification patterns
- **KB Contribution**: Novel solutions automatically become KB entries
- **Effectiveness Tracking**: Monitors which KB solutions actually help
- **Personalization**: Adapts to user's writing style and preferences
- **Continuous Improvement**: Every interaction makes the system smarter
- **Cross-Workflow Learning**: Patterns learned here improve other workflows

## Example Scenarios with Unified Intelligence

### Scenario 1: Update Request with KB Enhancement
**Input**: "Also remember to add the # of businesses in the ongoing financial report"
**Unified Intelligence Process**:
1. System retrieves user patterns: "User typically adds metrics to financial reports"
2. KB provides similar solution: "Financial Report Metrics Checklist" (95% success rate)
3. AI identifies this as an update request with high confidence
4. Finds matching task using user's naming patterns
5. Updates task with KB-suggested format
6. Tracks that KB entry was helpful
7. Adds comment with update details and KB reference

### Scenario 2: Epic Creation with Historical Patterns
**Input**: "New epic: Implement customer feedback system with NPS surveys, in-app feedback widgets, and monthly analysis reports"
**Unified Intelligence Process**:
1. System retrieves successful epic breakdown patterns
2. KB provides template: "Customer Feedback System Implementation" (used 5 times, 90% success)
3. AI applies user's epic structuring patterns
4. Creates epic using personalized format and vocabulary
5. Triggers cascade with KB-suggested story breakdown
6. Each story uses proven task templates from KB
7. System learns this as successful pattern for future

### Scenario 3: Knowledge Capture with Auto-Enhancement
**Input**: "TIL: Using Redis for session management reduced our API response time by 40%"
**Unified Intelligence Process**:
1. AI identifies this as knowledge capture (user pattern: "TIL" = knowledge)
2. System checks if similar knowledge exists
3. Finds related KB: "Caching Strategies" - enhances instead of duplicating
4. Creates enhanced KB entry with:
   - Performance metrics
   - Implementation details from context
   - Links to related performance improvements
5. Generates embeddings for future similarity search
6. Tags with learned taxonomy
7. Notifies relevant team members based on interests

## Monitoring & Optimization

### Key Metrics
- Processing time per note
- Classification accuracy
- Entity creation vs update ratio
- Knowledge capture rate

### Performance Tips
- Use webhook response mode for real-time processing
- Implement caching for frequently accessed items
- Batch API calls where possible
- Monitor OpenAI token usage

## Extensions with Unified Intelligence

### Already Enabled by Architecture
1. **Automatic Pattern Learning**: System learns classification patterns without configuration
2. **KB-Powered Suggestions**: Every decision informed by successful past solutions
3. **Personalized Processing**: Adapts to each user's unique style
4. **Cross-Workflow Intelligence**: Learning transfers between all workflows

### Additional Enhancements
1. **Multi-language Support**: Process notes with language-specific KB entries
2. **Voice Note Processing**: Transcribe and apply voice-specific patterns
3. **Image Analysis**: Extract and learn from visual patterns
4. **Team Intelligence Sharing**: Share successful patterns across team
5. **Predictive Classification**: Pre-classify based on writing patterns
6. **Smart Priority Detection**: Learn urgency indicators from user behavior

### Integration Points
- Connect to Epic Creation Cascade workflow
- Link to Knowledge Reuse Suggestion workflow
- Trigger Task Prioritization after creation
- Update team calendars for time-sensitive items