# Intelligent Duplicate Detection Workflow

## Overview
This workflow uses semantic analysis and pattern matching to detect potential duplicate entries when new items are created, preventing redundancy and maintaining data integrity across the project management system.

## Workflow Components

### 1. Trigger: Notion - On Database Item Created
- **Databases**: Tasks, Stories, Epics, Knowledge Base
- **Event**: Item Created
- **Delay**: 5 seconds (allow for complete item creation)

### 2. Get New Item Details
- **Node**: Notion - Get
- **Purpose**: Fetch complete details of newly created item
- **Fields**: All properties, especially Title, Description, Tags

### 3. Prepare Search Context
- **Node**: Function
- **Code**:
```javascript
const newItem = $node['Get New Item Details'].json;
const itemType = detectItemType(newItem.parent.database_id);

// Extract searchable content
const searchableContent = {
  title: newItem.properties.Name?.title[0]?.plain_text || '',
  description: newItem.properties.Description?.rich_text[0]?.plain_text || '',
  tags: newItem.properties.Tags?.multi_select.map(t => t.name) || [],
  project: newItem.properties.Project?.relation[0]?.id || null,
  epic: newItem.properties.Epic?.relation[0]?.id || null,
  type: itemType
};

// Generate search keywords
const keywords = extractKeywords(searchableContent.title + ' ' + searchableContent.description);

// Create embedding for semantic search
const contentForEmbedding = `${searchableContent.title} ${searchableContent.description}`;

return {
  searchableContent,
  keywords,
  contentForEmbedding,
  itemType,
  itemId: newItem.id
};
```

### 4. Generate Content Embedding
- **Node**: OpenAI - Create Embedding
- **Model**: text-embedding-ada-002
- **Input**: `{{$node['Prepare Search Context'].json.contentForEmbedding}}`
- **Purpose**: Create vector for semantic similarity

### 5. Search for Potential Duplicates
#### 5a. Title-Based Search
- **Node**: Notion - Get Many
- **Database**: Same as trigger database
- **Filter**: Title contains keywords OR fuzzy match
- **Exclude**: Current item ID
- **Limit**: 20

#### 5b. Tag-Based Search
- **Node**: Notion - Get Many
- **Filter**: Tags overlap with new item tags
- **Additional Filter**: Same project/epic if applicable
- **Limit**: 20

#### 5c. Recent Items Search
- **Node**: Notion - Get Many
- **Filter**: Created in last 7 days
- **Sort**: Created time DESC
- **Limit**: 50
- **Purpose**: Catch very recent duplicates

### 6. Calculate Similarity Scores
- **Node**: Function
- **Code**:
```javascript
const newItemEmbedding = $node['Generate Content Embedding'].json.data[0].embedding;
const potentialDuplicates = [
  ...$node['Title-Based Search'].json,
  ...$node['Tag-Based Search'].json,
  ...$node['Recent Items Search'].json
];

// Remove duplicates from combined results
const uniqueItems = Array.from(new Map(potentialDuplicates.map(item => [item.id, item])).values());

// Calculate similarity for each potential duplicate
const similarities = await Promise.all(uniqueItems.map(async (item) => {
  // Title similarity (Levenshtein distance)
  const titleSimilarity = calculateTitleSimilarity(
    newItem.title,
    item.properties.Name.title[0].plain_text
  );
  
  // Semantic similarity (if description exists)
  let semanticSimilarity = 0;
  if (item.properties.Description?.rich_text[0]?.plain_text) {
    const itemEmbedding = await getEmbedding(item.properties.Description.rich_text[0].plain_text);
    semanticSimilarity = cosineSimilarity(newItemEmbedding, itemEmbedding);
  }
  
  // Tag overlap
  const tagOverlap = calculateTagOverlap(newItem.tags, item.properties.Tags?.multi_select || []);
  
  // Context similarity (same project/epic)
  const contextMatch = (item.properties.Project?.relation[0]?.id === newItem.project) ? 0.2 : 0;
  
  // Weighted combined score
  const combinedScore = (
    titleSimilarity * 0.3 +
    semanticSimilarity * 0.4 +
    tagOverlap * 0.2 +
    contextMatch * 0.1
  );
  
  return {
    item: item,
    scores: {
      title: titleSimilarity,
      semantic: semanticSimilarity,
      tags: tagOverlap,
      context: contextMatch,
      combined: combinedScore
    }
  };
}));

// Filter and sort by similarity
const duplicateCandidates = similarities
  .filter(s => s.scores.combined > 0.7) // 70% similarity threshold
  .sort((a, b) => b.scores.combined - a.scores.combined);

return {
  candidates: duplicateCandidates,
  hasHighConfidenceDuplicate: duplicateCandidates.some(c => c.scores.combined > 0.85)
};
```

### 7. AI Duplicate Analysis (OpenAI Chat)
```json
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "system",
      "content": "Analyze if these items are duplicates. Consider:\n1. Semantic meaning (not just keywords)\n2. Intent and purpose\n3. Scope overlap\n4. Complementary vs duplicate\n5. Parent-child relationship potential\n\nProvide confidence score and reasoning."
    },
    {
      "role": "user",
      "content": "New Item: {{JSON.stringify($node['Get New Item Details'].json)}}\n\nPotential Duplicates: {{JSON.stringify($node['Calculate Similarity Scores'].json.candidates)}}\n\nProject Context: {{$node['Prepare Search Context'].json}}"
    }
  ],
  "temperature": 0.3,
  "max_tokens": 1500
}
```

### 8. Process Duplicate Analysis
- **Node**: Function
- **Code**:
```javascript
const analysis = JSON.parse($node['AI Duplicate Analysis'].json.choices[0].message.content);
const hasHighConfidence = $node['Calculate Similarity Scores'].json.hasHighConfidenceDuplicate;

// Determine action based on analysis
let action = 'none';
let confidence = analysis.overall_confidence;

if (confidence > 0.9 && hasHighConfidence) {
  action = 'block_and_notify';
} else if (confidence > 0.7) {
  action = 'warn_and_suggest';
} else if (confidence > 0.5) {
  action = 'flag_for_review';
}

return {
  action: action,
  confidence: confidence,
  duplicates: analysis.duplicates,
  reasoning: analysis.reasoning,
  suggestions: analysis.suggestions
};
```

### 9. Execute Duplicate Action
- **Node**: Switch
- **Based on**: Action type

#### Branch A: Block and Notify
1. **Add Warning Comment**
   - Add comment to new item with duplicate details
   - Include links to existing items
   
2. **Update Item Status**
   - Set status to "Duplicate Review"
   - Add "Potential Duplicate" tag
   
3. **Send Notification**
   - Notify creator via Slack/Email
   - Include comparison and merge suggestion

#### Branch B: Warn and Suggest
1. **Add Suggestion Comment**
   - Add comment with potential duplicates
   - Suggest reviewing or merging
   
2. **Create Review Task**
   - Create task for duplicate review
   - Assign to creator or PM

#### Branch C: Flag for Review
1. **Add Duplicate Flag**
   - Add subtle indicator (tag or property)
   - Log for periodic review

### 10. Handle Special Cases
#### 10a. Template Detection
- **Check**: Is this from a template?
- **Action**: Reduce sensitivity for template-based items

#### 10b. Recurring Items
- **Check**: Is this a recurring task/story?
- **Action**: Check pattern rather than exact match

#### 10c. Multi-language Detection
- **Check**: Different language versions
- **Action**: Use translation before comparison

### 11. Update Knowledge Base
- **Node**: Notion - Create/Update
- **Purpose**: Track duplicate patterns
- **Content**:
  - Common duplicate patterns
  - False positive patterns
  - Naming conventions that cause issues

### 12. Learn from Feedback
- **Node**: Function
- **Purpose**: Improve detection accuracy
```javascript
// Store feedback when users mark false positives
const feedback = {
  item_pair: [newItemId, suggestedDuplicateId],
  similarity_scores: scores,
  user_decision: 'not_duplicate', // or 'is_duplicate'
  timestamp: new Date()
};

// Update similarity thresholds based on feedback
await updateDetectionModel(feedback);
```

## Advanced Features

### Fuzzy Title Matching
```javascript
const fuzzyMatch = (str1, str2, threshold = 0.8) => {
  // Remove common words
  const stopWords = ['the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at'];
  const clean = (str) => str.toLowerCase()
    .split(' ')
    .filter(word => !stopWords.includes(word))
    .join(' ');
  
  const cleaned1 = clean(str1);
  const cleaned2 = clean(str2);
  
  // Calculate similarity
  return stringSimilarity(cleaned1, cleaned2) > threshold;
};
```

### Contextual Deduplication
- Consider item hierarchy (epic → story → task)
- Check if "duplicate" is actually a valid sub-item
- Detect split items (one item split into multiple)

### Batch Duplicate Detection
- Run weekly scan for duplicates
- Clean up accumulated duplicates
- Generate duplicate report

## Example Scenarios

### Scenario 1: Exact Duplicate
**New Task**: "Implement user authentication"
**Existing Task**: "Implement user authentication"
**Result**:
- 95% similarity score
- Blocked with high confidence
- Suggests merging or deleting new item

### Scenario 2: Semantic Duplicate
**New Story**: "Add login functionality"
**Existing Story**: "User authentication system"
**Result**:
- 78% similarity score
- Warning with suggestion to review
- May be subset or overlap

### Scenario 3: False Positive
**New Task**: "Update user documentation"
**Existing Task**: "Update API documentation"
**Result**:
- 65% similarity score
- Flagged for review
- Similar structure but different scope

### Scenario 4: Template-Based Items
**New Task**: "Weekly team standup"
**Existing Tasks**: Multiple "Weekly team standup"
**Result**:
- Detected as recurring pattern
- Allowed with date differentiation
- No duplicate warning

## Performance Optimization

### Embedding Cache
- Cache embeddings for frequently accessed items
- Update cache on item modifications
- Expire cache entries after 30 days

### Search Optimization
- Use database indexes on title and tags
- Limit search scope by date range
- Prioritize same-project comparisons

### Batch Processing
- Process multiple new items together
- Share embedding generation calls
- Optimize API usage

## Monitoring & Metrics

### Key Metrics:
- True positive rate (actual duplicates caught)
- False positive rate (incorrect duplicate flags)
- Processing time per item
- User override frequency
- Duplicate creation rate over time

### Quality Indicators:
- Confidence score accuracy
- User feedback on suggestions
- Time saved by preventing duplicates
- Merge action frequency

## Configuration Options

### Sensitivity Settings
```javascript
const config = {
  thresholds: {
    high_confidence: 0.85,
    medium_confidence: 0.70,
    low_confidence: 0.50
  },
  weights: {
    title: 0.3,
    content: 0.4,
    tags: 0.2,
    context: 0.1
  },
  exclusions: {
    templates: ['weekly_standup', 'sprint_retro'],
    tags: ['recurring', 'template']
  }
};
```

### Per-Database Settings
- Tasks: Higher sensitivity (more duplicates)
- Epics: Lower sensitivity (less likely)
- Knowledge Base: Medium sensitivity
- Custom thresholds per project

## Integration Points

### Triggered By:
- Any item creation in monitored databases
- Bulk import processes
- Manual duplicate scan request

### Triggers:
- Merge workflow (if duplicate confirmed)
- Notification workflows
- Knowledge base updates
- Analytics dashboard updates

## Future Enhancements

1. **Visual Duplicate Detection**: For design/mockup attachments
2. **Cross-Database Detection**: Find duplicates across different databases
3. **Proactive Prevention**: Warn during creation before saving
4. **Smart Merging**: AI-assisted merge of duplicate content
5. **Duplicate Patterns**: Learn team-specific duplicate patterns
6. **Integration Deduplication**: Detect duplicates from external sources