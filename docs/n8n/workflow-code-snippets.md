# n8n Workflow Implementation Code Snippets

## Overview
This document contains ready-to-use code snippets for implementing the AI-powered Notion inbox workflow in n8n. Copy these snippets into your n8n workflow nodes.

---

## 1. Main Workflow: Inbox Item Analysis

### Workflow Structure
```
[Notion Trigger] → [Get Full Item] → [AI Analysis] → [Update Notion] → [Route by Status]
```

### Node 1: Notion Webhook Trigger
```json
{
  "name": "Notion Inbox Trigger",
  "type": "n8n-nodes-base.webhook",
  "webhookId": "inbox-new-item",
  "httpMethod": "POST",
  "responseMode": "lastNode",
  "path": "inbox-new-item"
}
```

### Node 2: Get Full Notion Item
```javascript
// Code Node: Extract and Validate Item
const notionPageId = $json.data?.id || $json.id;

if (!notionPageId) {
  throw new Error('No Notion page ID found in webhook data');
}

// Store for next node
return {
  json: {
    pageId: notionPageId,
    webhookData: $json
  }
};
```

### Node 3: Notion API - Get Page Details
```json
{
  "resource": "page",
  "operation": "get",
  "pageId": "={{ $json.pageId }}",
  "propertiesToGet": [
    "Note",
    "Priority",
    "Tags",
    "Processing Status",
    "User Feedback",
    "Processing Attempts"
  ]
}
```

### Node 4: AI Analysis (OpenAI/Claude)
```javascript
// System Prompt (Set in AI node)
const SYSTEM_PROMPT = `You are an AI assistant for a Notion-based Project Management System. Analyze inbox items and provide structured recommendations.

CONFIDENCE SCORING CRITERIA:
90-100%: All required information present, clear classification
70-89%: Most information present, minor assumptions needed
50-69%: Some key information missing, moderate assumptions
30-49%: Significant information gaps, major assumptions
0-29%: Insufficient information for reliable analysis

OUTPUT FORMAT:
You must return ONLY valid JSON matching this exact structure:
{
  "confidence": <number 0-100>,
  "confidence_reasoning": "<explanation>",
  "classification": "Task|Story|Epic|Knowledge|Note",
  "action": "CREATE_NEW|UPDATE_EXISTING|LINK_TO_EXISTING|CONVERT",
  "reasoning": "<detailed explanation>",
  "suggested_properties": {
    "title": "<refined title>",
    "description": "<enhanced description>",
    "project": "<project name if identified>",
    "epic": "<epic name if identified>",
    "priority": "Low|Medium|High|Critical",
    "estimated_hours": <number or null>,
    "tags": ["tag1", "tag2"]
  },
  "related_items": [
    {
      "type": "Project|Epic|Story|Task",
      "title": "<item title>",
      "relation": "parent|child|related",
      "confidence": <number 0-100>
    }
  ],
  "next_steps": [
    "<step 1>",
    "<step 2>"
  ],
  "questions_for_user": [
    "<clarification needed>"
  ]
}`;

// User Prompt
const userPrompt = `Analyze this inbox item:

Title: ${$json.properties.Note.title[0]?.plain_text || 'Untitled'}
Priority: ${$json.properties.Priority?.select?.name || 'Not set'}
Tags: ${$json.properties.Tags?.multi_select?.map(t => t.name).join(', ') || 'None'}

Previous User Feedback: ${$json.properties['User Feedback']?.rich_text[0]?.plain_text || 'None'}
Processing Attempts: ${$json.properties['Processing Attempts']?.number || 0}

Provide your analysis following the exact JSON structure specified.`;

// Return for AI node
return {
  json: {
    systemPrompt: SYSTEM_PROMPT,
    userPrompt: userPrompt,
    notionData: $json
  }
};
```

### Node 5: Parse AI Response & Calculate Display Values
```javascript
// Code Node: Process AI Response
try {
  const aiResponse = JSON.parse($json.message.content);
  
  // Validate required fields
  const requiredFields = ['confidence', 'classification', 'action', 'reasoning'];
  for (const field of requiredFields) {
    if (!(field in aiResponse)) {
      throw new Error(`Missing required field: ${field}`);
    }
  }
  
  // Format action plan for Notion
  const actionPlan = `## AI Analysis

**Classification**: ${aiResponse.classification}
**Action**: ${aiResponse.action.replace(/_/g, ' ')}
**Confidence**: ${aiResponse.confidence}%

### Reasoning
${aiResponse.reasoning}

### Suggested Properties
- **Title**: ${aiResponse.suggested_properties.title}
- **Priority**: ${aiResponse.suggested_properties.priority}
- **Project**: ${aiResponse.suggested_properties.project || 'Not identified'}
- **Epic**: ${aiResponse.suggested_properties.epic || 'Not identified'}
${aiResponse.suggested_properties.estimated_hours ? `- **Estimated Hours**: ${aiResponse.suggested_properties.estimated_hours}` : ''}

### Related Items
${aiResponse.related_items.map(item => 
  `- ${item.type}: ${item.title} (${item.relation}, ${item.confidence}% confident)`
).join('\\n') || 'None identified'}

### Next Steps
${aiResponse.next_steps.map((step, i) => `${i + 1}. ${step}`).join('\\n')}

${aiResponse.questions_for_user.length > 0 ? `### Questions for Clarification\\n${aiResponse.questions_for_user.map((q, i) => `${i + 1}. ${q}`).join('\\n')}` : ''}`;

  // Determine processing status based on confidence
  let processingStatus = 'Draft';
  if (aiResponse.confidence >= 70) {
    processingStatus = 'Pending Approval';
  }

  return {
    json: {
      pageId: $('Node 2').item.json.pageId,
      aiAnalysis: aiResponse,
      updateData: {
        'AI Confidence': aiResponse.confidence / 100, // Convert to decimal for Notion
        'Processing Status': processingStatus,
        'AI Action Plan': actionPlan,
        'Confidence Reasoning': aiResponse.confidence_reasoning
      }
    }
  };
  
} catch (error) {
  throw new Error(`Failed to parse AI response: ${error.message}`);
}
```

### Node 6: Update Notion Page
```json
{
  "resource": "page",
  "operation": "update",
  "pageId": "={{ $json.pageId }}",
  "properties": {
    "AI Confidence": {
      "number": "={{ $json.updateData['AI Confidence'] }}"
    },
    "Processing Status": {
      "select": {
        "name": "={{ $json.updateData['Processing Status'] }}"
      }
    },
    "AI Action Plan": {
      "rich_text": [{
        "text": {
          "content": "={{ $json.updateData['AI Action Plan'] }}"
        }
      }]
    },
    "Confidence Reasoning": {
      "rich_text": [{
        "text": {
          "content": "={{ $json.updateData['Confidence Reasoning'] }}"
        }
      }]
    }
  }
}
```

---

## 2. Approval Decision Workflow

### Workflow Structure
```
[Webhook] → [Get Page] → [Route by Decision] → [Process Approval/Update/Discard]
```

### Node 1: Approval Webhook
```json
{
  "name": "Approval Decision Trigger",
  "type": "n8n-nodes-base.webhook",
  "webhookId": "inbox-approval",
  "httpMethod": "POST",
  "path": "inbox-approval"
}
```

### Node 2: Get Current Page State
```javascript
// Extract page ID and get current state
const pageId = $json.data?.id || $json.id;
const approvalAction = $json.data?.properties?.['Approval Actions']?.select?.name;

if (!approvalAction) {
  // No action taken yet, ignore
  return { json: { skip: true } };
}

return {
  json: {
    pageId: pageId,
    action: approvalAction,
    continue: true
  }
};
```

### Node 3: Router by Action
```javascript
// Route to appropriate branch based on action
const action = $json.action;

if (action === 'Approve ✅') {
  return { json: { ....$json, route: 'approve' } };
} else if (action === 'Update Entry 📝') {
  return { json: { ....$json, route: 'update' } };
} else if (action === 'Discard ❌') {
  return { json: { ....$json, route: 'discard' } };
}

throw new Error(`Unknown action: ${action}`);
```

### Node 4A: Process Approval
```javascript
// For approved items, prepare for execution
return {
  json: {
    pageId: $json.pageId,
    updateData: {
      'Processing Status': 'Processing',
      'Approval Actions': null // Clear the action
    },
    executeAction: true
  }
};
```

### Node 4B: Handle Update Request
```javascript
// Reset for re-analysis
const currentAttempts = $json.properties?.['Processing Attempts']?.number || 0;

return {
  json: {
    pageId: $json.pageId,
    updateData: {
      'Processing Status': 'Draft',
      'Approval Actions': null,
      'Processing Attempts': currentAttempts + 1
    },
    triggerReanalysis: true
  }
};
```

### Node 4C: Handle Discard
```javascript
// Mark as rejected
return {
  json: {
    pageId: $json.pageId,
    updateData: {
      'Processing Status': 'Rejected',
      'Approval Actions': null
    }
  }
};
```

---

## 3. Task/Story/Epic Creation Workflow

### Node: Create Task from Inbox
```javascript
// Prepare task creation data
const aiAnalysis = $json.aiAnalysis;
const properties = aiAnalysis.suggested_properties;

// Build task properties
const taskData = {
  'Task Name': properties.title,
  'Description': {
    rich_text: [{
      text: {
        content: properties.description || `Created from inbox item: ${$json.originalTitle}`
      }
    }]
  },
  'Priority': {
    select: { name: properties.priority }
  },
  'Status': {
    select: { name: 'To Do' }
  },
  'Estimated Hours': properties.estimated_hours || null,
  'Tags': {
    multi_select: properties.tags.map(tag => ({ name: tag }))
  },
  'Source': {
    rich_text: [{
      text: {
        content: 'AI Inbox Conversion'
      }
    }]
  }
};

// Add relations if identified
if (properties.epic) {
  // You'll need to search for the epic first
  taskData['Epic'] = {
    relation: [{ id: '{{ epicId }}' }]
  };
}

return {
  json: {
    database_id: '21e0d2195e1c80a28c67dc2a8ed20e1b', // Tasks DB
    properties: taskData,
    inboxPageId: $json.pageId
  }
};
```

---

## 4. Error Handling & Monitoring

### Global Error Handler
```javascript
// Add this to catch node errors
const error = $json.error;
const context = $json;

// Log error details
console.error('Workflow Error:', {
  message: error.message,
  node: error.node,
  timestamp: new Date().toISOString(),
  context: context
});

// Update Notion page with error
return {
  json: {
    pageId: context.pageId,
    updateData: {
      'Processing Status': 'Error',
      'AI Action Plan': `Error occurred: ${error.message}\\n\\nPlease check the logs or contact support.`
    }
  }
};
```

### Monitoring Webhook
```javascript
// Send metrics to monitoring service
const metrics = {
  workflow: 'inbox-processing',
  timestamp: new Date().toISOString(),
  metrics: {
    confidence: $json.aiAnalysis.confidence,
    classification: $json.aiAnalysis.classification,
    action: $json.aiAnalysis.action,
    processingTime: Date.now() - $json.startTime,
    success: true
  }
};

// Send to monitoring endpoint (optional)
return {
  json: metrics
};
```

---

## 5. Feedback Loop Implementation

### Node: Process User Feedback
```javascript
// When user adds feedback and triggers re-analysis
const pageData = $json;
const userFeedback = pageData.properties['User Feedback']?.rich_text[0]?.plain_text;

if (!userFeedback || userFeedback.trim() === '') {
  throw new Error('No user feedback provided');
}

// Enhance the prompt with feedback
const enhancedPrompt = `${$json.originalPrompt}

IMPORTANT USER FEEDBACK:
${userFeedback}

Please incorporate this feedback into your analysis and adjust your recommendations accordingly.`;

return {
  json: {
    pageId: pageData.id,
    enhancedPrompt: enhancedPrompt,
    attemptNumber: pageData.properties['Processing Attempts']?.number || 1
  }
};
```

---

## 6. Scheduled Maintenance Workflow

### Daily Cleanup Job
```javascript
// Run daily to clean up old drafts
const sevenDaysAgo = new Date();
sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

// Query for old drafts
const filter = {
  and: [
    {
      property: 'Processing Status',
      select: { equals: 'Draft' }
    },
    {
      property: 'Last Edited Time',
      date: { before: sevenDaysAgo.toISOString() }
    }
  ]
};

return {
  json: {
    database_id: '21e0d2195e1c80228d8cf8ffd2a27275',
    filter: filter,
    action: 'archive'
  }
};
```

---

## 7. Testing Snippets

### Test Data Generator
```javascript
// Generate test inbox items
const testItems = [
  {
    title: "Implement user authentication for healthcare platform",
    priority: "High",
    tags: ["Development", "Security", "Healthcare"]
  },
  {
    title: "Research competitor pricing models",
    priority: "Medium",
    tags: ["Research", "Business"]
  },
  {
    title: "Fix bug in data export feature",
    priority: "Critical",
    tags: ["Bug", "Production"]
  }
];

return testItems.map(item => ({
  json: {
    properties: {
      'Note': { title: [{ plain_text: item.title }] },
      'Priority': { select: { name: item.priority } },
      'Tags': { multi_select: item.tags.map(t => ({ name: t })) },
      'Processing Status': { select: { name: 'Draft' } }
    }
  }
}));
```

---

## Implementation Notes

1. **API Keys**: Ensure your n8n instance has the Notion API key configured
2. **Database IDs**: Replace the database IDs with your actual Notion database IDs
3. **Webhook URLs**: Update webhook paths to match your n8n instance URL
4. **AI Model**: Configure your preferred AI model (OpenAI GPT-4, Claude, etc.)
5. **Error Handling**: Add try-catch blocks around critical operations
6. **Rate Limiting**: Implement delays between Notion API calls if needed
7. **Logging**: Add comprehensive logging for debugging

## Security Considerations

1. Never expose API keys in workflow exports
2. Use n8n credentials manager for sensitive data
3. Validate all webhook inputs
4. Implement proper authentication on webhooks
5. Regular audit of workflow permissions