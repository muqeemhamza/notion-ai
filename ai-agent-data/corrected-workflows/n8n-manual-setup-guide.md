# 📋 n8n Manual Workflow Setup Guide

Since the JSON import is having issues, let's build the workflow manually step by step.

## 🎯 Workflow Overview
This workflow will:
1. Trigger when a new item is added to Notion Inbox
2. Get context from existing Epics and Stories
3. Use AI to classify the item
4. Update the Inbox item with AI analysis

## 🔨 Step-by-Step Setup

### Step 1: Create New Workflow
1. In n8n, click "Add workflow"
2. Name it: "Intelligent Inbox Processing"

### Step 2: Add Notion Trigger
1. Click "+" to add a node
2. Search for "Notion Trigger" and add it
3. Configure:
   - **Credential**: Select your Notion API credential
   - **Resource**: Database Page
   - **Event**: Created
   - **Database**: Search and select your "Inbox" database
   - The Database ID should be: `21e0d2195e1c80228d8cf8ffd2a27275`

### Step 3: Add HTTP Request Node (Alternative Trigger)
If Notion Trigger doesn't work, use this alternative:
1. Add "Webhook" node
2. Set HTTP Method: POST
3. Set Path: inbox-trigger
4. This will give you a webhook URL to use with Notion automations

### Step 4: Get Active Epics
1. Add "Notion" node
2. Configure:
   - **Resource**: Database Page
   - **Operation**: Get All
   - **Database ID**: `21e0d2195e1c809bae77f183b66a78b2` (Epics)
   - **Return All**: OFF
   - **Limit**: 50

### Step 5: Get Active Stories
1. Add another "Notion" node
2. Configure:
   - **Resource**: Database Page
   - **Operation**: Get All
   - **Database ID**: `21e0d2195e1c806a947ff1806bffa2fb` (Stories)
   - **Return All**: OFF
   - **Limit**: 100

### Step 6: Add OpenAI Node
1. Add "OpenAI" node (or "ChatGPT" node)
2. Configure:
   - **Resource**: Message
   - **Model**: gpt-4 (or gpt-3.5-turbo)
   - **System Message**:
   ```
   You are an AI assistant for a Project Management System with 3 main projects:
   1. Techniq Company Building (Brand, website, hiring, operations)
   2. Trading & Financial Markets Platform (Trading infrastructure, data, strategies)
   3. Healthcare AI Product Development (Medical AI products, clinical applications)
   
   Analyze inbox notes and provide structured classification.
   ```
   - **User Message**:
   ```
   Inbox Note: {{ $node["Notion Trigger"].json.properties.Note.title[0].plain_text }}
   
   Context:
   Active Epics: {{ $node["Get Active Epics"].json.map(e => e.properties?.Name?.title[0]?.plain_text || 'Untitled').slice(0, 10).join(', ') }}
   
   Classify this note and respond with a JSON object containing:
   {
     "classification": "Task|Story|Epic|Knowledge|Archive",
     "project": "Project name",
     "priority": "Critical|High|Medium|Low",
     "confidence": 0.0-1.0,
     "ai_action_plan": "Formatted action plan",
     "reasoning": "Why this classification"
   }
   ```

### Step 7: Add Code Node to Parse Response
1. Add "Code" node
2. Set Language: JavaScript
3. Add this code:
```javascript
// Parse AI response
const aiResponseText = $input.first().json.message?.content || $input.first().json.choices?.[0]?.message?.content;
const aiResponse = JSON.parse(aiResponseText);
const inboxItem = $node["Notion Trigger"].json;

// Determine processing status
let processingStatus = 'Draft';
if (aiResponse.confidence >= 0.7) {
  processingStatus = 'Pending Approval';
}

// Format AI Action Plan if not provided
if (!aiResponse.ai_action_plan) {
  aiResponse.ai_action_plan = `**Classification**: ${aiResponse.classification}
**Project**: ${aiResponse.project}
**Priority**: ${aiResponse.priority}
**Confidence**: ${(aiResponse.confidence * 100).toFixed(0)}%

**Reasoning**: ${aiResponse.reasoning}`;
}

return {
  inbox_id: inboxItem.id,
  processing_status: processingStatus,
  ai_confidence: aiResponse.confidence,
  ai_action_plan: aiResponse.ai_action_plan,
  confidence_reasoning: aiResponse.reasoning,
  priority: aiResponse.priority
};
```

### Step 8: Update Notion Page
1. Add final "Notion" node
2. Configure:
   - **Resource**: Database Page
   - **Operation**: Update
   - **Page ID**: `{{ $json.inbox_id }}`
   - **Properties to Update**:

Click "Add Property" for each:

**Processing Status** (Select):
- Property Name: Processing Status
- Value: `{{ $json.processing_status }}`

**AI Confidence** (Number):
- Property Name: AI Confidence  
- Value: `{{ $json.ai_confidence }}`

**AI Action Plan** (Text):
- Property Name: AI Action Plan
- Value: `{{ $json.ai_action_plan }}`

**Confidence Reasoning** (Text):
- Property Name: Confidence Reasoning
- Value: `{{ $json.confidence_reasoning }}`

**Priority** (Select):
- Property Name: Priority
- Value: `{{ $json.priority }}`

### Step 9: Connect the Nodes
Connect them in this order:
1. Notion Trigger → Get Active Epics
2. Notion Trigger → Get Active Stories  
3. Get Active Epics → OpenAI
4. Get Active Stories → OpenAI
5. OpenAI → Code
6. Code → Update Notion Page

## 🧪 Testing the Workflow

### Test Method 1: Manual Execution
1. Click "Execute Workflow"
2. In the Notion Trigger node, click "Listen for Test Event"
3. Go to Notion and add a test item to your Inbox
4. The workflow should trigger

### Test Method 2: Use Test Data
1. In the Notion Trigger node, click on it
2. Click "Add test data"
3. Paste this test JSON:
```json
{
  "id": "test-123",
  "properties": {
    "Note": {
      "title": [{
        "plain_text": "Set up user authentication system for trading platform"
      }]
    }
  }
}
```

## 🔧 Troubleshooting

**"Could not find property option" Error**:
- This usually means the property names don't match exactly
- Check your Notion database for exact property names
- Property names are case-sensitive

**OpenAI Error**:
- Make sure you've added OpenAI credentials
- Check that the API key is valid
- Verify you have GPT-4 access (or change to gpt-3.5-turbo)

**Notion Update Fails**:
- Verify property names match exactly
- Check that select options exist (Priority, Processing Status)
- Ensure the page ID is being passed correctly

## 🎯 Next Steps

Once this basic workflow is running:
1. Add error handling
2. Add conditional logic for auto-processing high-confidence items
3. Create separate branches for Task/Story/Epic creation
4. Add knowledge base integration

Start with this simple version first, then we can add complexity!