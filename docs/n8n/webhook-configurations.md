# n8n Webhook Configuration Examples

## Overview
This document provides webhook configuration examples for connecting workflows and enabling real-time triggers in your AI-Augmented Notion PMS.

---

## 🔗 Core Webhook Configurations

### 1. Context Request Webhook (Foundation)
Used by all workflows to request personalized context.

```json
{
  "id": "context-request-webhook",
  "name": "LLM Context Request",
  "path": "context-request",
  "method": "POST",
  "authentication": "none",
  "responseMode": "onReceived",
  "responseData": "allEntries",
  "options": {
    "responsePropertyName": "context",
    "responseHeaders": {
      "Content-Type": "application/json"
    }
  }
}
```

**Usage Example:**
```javascript
// Call from any workflow
const contextResponse = await $http.request({
  method: 'POST',
  url: 'http://localhost:5678/webhook/context-request',
  body: {
    user_id: 'current_user',
    workflow_type: 'intelligent_inbox_processing',
    current_input: inboxNote,
    request_time: new Date().toISOString()
  },
  headers: {
    'Content-Type': 'application/json'
  }
});

const personalizedContext = contextResponse.context;
```

### 2. Epic Cascade Trigger
Triggered when a new epic is created to generate stories and tasks.

```json
{
  "id": "epic-cascade-webhook",
  "name": "Epic Creation Cascade Trigger",
  "path": "epic-cascade",
  "method": "POST",
  "authentication": "headerAuth",
  "responseMode": "lastNode",
  "options": {
    "responseData": "allEntries",
    "rawBody": false,
    "responseHeaders": {
      "X-Workflow-Status": "processing"
    }
  },
  "headerAuth": {
    "name": "X-Webhook-Secret",
    "value": "your-secret-key"
  }
}
```

**Trigger Configuration:**
```javascript
// From Intelligent Inbox Processing workflow
if (entityType === 'epic' && epicCreated) {
  await $http.request({
    method: 'POST',
    url: 'http://localhost:5678/webhook/epic-cascade',
    headers: {
      'X-Webhook-Secret': 'your-secret-key'
    },
    body: {
      epic_id: newEpic.id,
      epic_title: newEpic.properties.Name.title[0].plain_text,
      epic_description: newEpic.properties.Description.rich_text[0].plain_text,
      project_id: newEpic.properties.Project.relation[0].id,
      created_by: 'intelligent_inbox_processing',
      timestamp: new Date().toISOString()
    }
  });
}
```

### 3. Learning Data Webhook
Captures all interactions for personalization learning.

```json
{
  "id": "learning-capture-webhook",
  "name": "Capture Learning Data",
  "path": "learning-capture",
  "method": "POST",
  "authentication": "none",
  "responseMode": "onReceived",
  "options": {
    "responseData": "firstEntryJson",
    "responseCode": 202,
    "responseHeaders": {
      "X-Learning-Status": "captured"
    }
  }
}
```

**Data Structure:**
```javascript
// Send learning data
const learningData = {
  interaction: {
    workflow: 'intelligent_inbox_processing',
    timestamp: new Date().toISOString(),
    user_id: currentUser
  },
  input: {
    raw_text: inboxNote,
    context: currentContext
  },
  ai_response: {
    classification: aiClassification,
    confidence: aiConfidence,
    reasoning: aiReasoning
  },
  user_action: {
    accepted: userAcceptedSuggestion,
    modifications: userEdits,
    final_choice: finalAction
  },
  outcome: {
    success: true,
    entity_created: entityType,
    time_saved: estimatedTimeSaved
  }
};

await sendToLearningWebhook(learningData);
```

### 4. Dependency Update Webhook
Triggered when item status changes to update dependencies.

```json
{
  "id": "dependency-update-webhook",
  "name": "Dependency Status Update",
  "path": "dependency-update",
  "method": "POST",
  "authentication": "none",
  "responseMode": "lastNode",
  "options": {
    "binaryPropertyName": "data",
    "responseData": "allEntries",
    "executionMode": "queue"
  }
}
```

**Trigger Logic:**
```javascript
// Monitor status changes
const statusChangeHandler = {
  conditions: [
    {
      field: 'Status',
      from: ['In Progress', 'Blocked'],
      to: 'Completed'
    }
  ],
  action: async (item) => {
    await triggerDependencyUpdate({
      item_id: item.id,
      item_type: item.type,
      new_status: item.properties.Status.status.name,
      dependencies: item.properties.Dependencies.relation,
      timestamp: new Date().toISOString()
    });
  }
};
```

### 5. Knowledge Extraction Webhook
Triggered when items are completed to extract learnings.

```json
{
  "id": "knowledge-extraction-webhook",
  "name": "Extract Knowledge from Completed Items",
  "path": "extract-knowledge",
  "method": "POST",
  "authentication": "none",
  "responseMode": "responseNode",
  "responseNodeName": "Knowledge Created",
  "options": {
    "priority": "high",
    "timeout": 30000
  }
}
```

---

## 🔧 Webhook Utilities

### Error Handling Configuration
```javascript
// Webhook with retry logic
const webhookWithRetry = {
  maxRetries: 3,
  retryDelay: 1000,
  errorHandler: async (error, attempt) => {
    console.error(`Webhook failed (attempt ${attempt}):`, error);
    
    if (attempt < maxRetries) {
      await new Promise(resolve => setTimeout(resolve, retryDelay * attempt));
      return true; // retry
    }
    
    // Log to error tracking
    await logWebhookError({
      webhook: 'context-request',
      error: error.message,
      timestamp: new Date(),
      payload: error.payload
    });
    
    return false; // don't retry
  }
};
```

### Webhook Security
```javascript
// Secure webhook implementation
const secureWebhook = {
  validateRequest: (req) => {
    // Check signature
    const signature = req.headers['x-webhook-signature'];
    const payload = JSON.stringify(req.body);
    const expectedSignature = crypto
      .createHmac('sha256', process.env.WEBHOOK_SECRET)
      .update(payload)
      .digest('hex');
    
    if (signature !== expectedSignature) {
      throw new Error('Invalid webhook signature');
    }
    
    // Check timestamp (prevent replay attacks)
    const timestamp = req.body.timestamp;
    const fiveMinutesAgo = Date.now() - (5 * 60 * 1000);
    
    if (new Date(timestamp).getTime() < fiveMinutesAgo) {
      throw new Error('Webhook timestamp too old');
    }
    
    return true;
  }
};
```

---

## 🌐 External Service Webhooks

### Notion Webhook (Incoming)
For real-time Notion updates:

```javascript
// Register with Notion (hypothetical - Notion doesn't have webhooks yet)
const notionWebhook = {
  url: 'http://your-domain.com/webhook/notion-updates',
  events: ['page.created', 'page.updated', 'database.updated'],
  filters: {
    databases: [
      '21e0d2195e1c80228d8cf8ffd2a27275', // Inbox
      '21e0d2195e1c809bae77f183b66a78b2', // Epics
      '21e0d2195e1c806a947ff1806bffa2fb', // Stories
      '21e0d2195e1c80a28c67dc2a8ed20e1b'  // Tasks
    ]
  }
};
```

### Slack Integration Webhook
For notifications:

```json
{
  "id": "slack-notification-webhook",
  "name": "Send Slack Notifications",
  "path": "slack-notify",
  "method": "POST",
  "options": {
    "rawBody": true,
    "responseMode": "onReceived"
  }
}
```

**Usage:**
```javascript
// Send notification
const notifySlack = async (message) => {
  await $http.request({
    method: 'POST',
    url: process.env.SLACK_WEBHOOK_URL,
    body: {
      text: message.title,
      blocks: [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: message.content
          }
        },
        {
          type: "actions",
          elements: [
            {
              type: "button",
              text: { type: "plain_text", text: "View in Notion" },
              url: message.notionUrl
            }
          ]
        }
      ]
    }
  });
};
```

---

## 🔄 Webhook Chaining

### Sequential Processing Chain
```javascript
// Chain webhooks for complex workflows
const webhookChain = {
  processInboxItem: async (item) => {
    // Step 1: Get context
    const context = await callWebhook('context-request', {
      user_id: currentUser,
      workflow: 'inbox_processing',
      input: item
    });
    
    // Step 2: Process with AI
    const aiResult = await processWithAI(item, context);
    
    // Step 3: Execute action
    if (aiResult.action === 'create_epic') {
      // Trigger epic cascade
      await callWebhook('epic-cascade', {
        epic_id: aiResult.created_id,
        context: context
      });
    }
    
    // Step 4: Capture learning
    await callWebhook('learning-capture', {
      input: item,
      context: context,
      result: aiResult
    });
    
    return aiResult;
  }
};
```

### Parallel Processing
```javascript
// Call multiple webhooks in parallel
const parallelWebhooks = async (data) => {
  const [contextResult, validationResult, enrichmentResult] = await Promise.all([
    callWebhook('context-request', data),
    callWebhook('validate-data', data),
    callWebhook('enrich-data', data)
  ]);
  
  return {
    context: contextResult,
    validation: validationResult,
    enrichment: enrichmentResult
  };
};
```

---

## 📊 Webhook Monitoring

### Health Check Endpoints
```javascript
// Add health check to each webhook
const webhookHealth = {
  path: 'health',
  method: 'GET',
  handler: async () => {
    return {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      webhooks: {
        'context-request': await checkWebhook('context-request'),
        'epic-cascade': await checkWebhook('epic-cascade'),
        'learning-capture': await checkWebhook('learning-capture')
      }
    };
  }
};
```

### Webhook Analytics
```javascript
// Track webhook usage
const webhookAnalytics = {
  track: async (webhookId, data) => {
    await db.webhook_analytics.insertOne({
      webhook_id: webhookId,
      timestamp: new Date(),
      execution_time: data.executionTime,
      success: data.success,
      error: data.error || null,
      payload_size: JSON.stringify(data.payload).length
    });
  },
  
  getStats: async (webhookId, timeframe) => {
    const stats = await db.webhook_analytics.aggregate([
      {
        $match: {
          webhook_id: webhookId,
          timestamp: { $gte: timeframe.start, $lte: timeframe.end }
        }
      },
      {
        $group: {
          _id: null,
          total_calls: { $sum: 1 },
          success_rate: { $avg: { $cond: ['$success', 1, 0] } },
          avg_execution_time: { $avg: '$execution_time' },
          errors: { $sum: { $cond: ['$error', 1, 0] } }
        }
      }
    ]);
    
    return stats[0];
  }
};
```

---

## 🚀 Production Webhook Setup

### Environment Configuration
```bash
# .env file
N8N_WEBHOOK_BASE_URL=https://your-domain.com
N8N_WEBHOOK_TUNNEL_URL=https://your-domain.com/
WEBHOOK_SECRET=your-strong-secret-key
WEBHOOK_TIMEOUT=30000
WEBHOOK_MAX_PAYLOAD_SIZE=10mb
```

### Nginx Configuration
```nginx
# Webhook routing
location /webhook/ {
    proxy_pass http://localhost:5678/webhook/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # Timeout settings
    proxy_connect_timeout 30s;
    proxy_send_timeout 30s;
    proxy_read_timeout 30s;
}
```

### Docker Compose Configuration
```yaml
version: '3.8'
services:
  n8n:
    image: n8nio/n8n
    environment:
      - N8N_WEBHOOK_BASE_URL=https://your-domain.com
      - N8N_PROTOCOL=https
      - N8N_HOST=your-domain.com
      - N8N_PORT=5678
      - WEBHOOK_URL=https://your-domain.com
    ports:
      - "5678:5678"
    volumes:
      - n8n_data:/home/node/.n8n
    networks:
      - n8n_network

volumes:
  n8n_data:

networks:
  n8n_network:
```

---

## 🔍 Testing Webhooks

### Test Script
```javascript
// Test all webhooks
const testWebhooks = async () => {
  const webhooks = [
    'context-request',
    'epic-cascade',
    'learning-capture',
    'dependency-update',
    'knowledge-extraction'
  ];
  
  const results = {};
  
  for (const webhook of webhooks) {
    try {
      const testPayload = generateTestPayload(webhook);
      const response = await callWebhook(webhook, testPayload);
      
      results[webhook] = {
        status: 'success',
        responseTime: response.time,
        statusCode: response.status
      };
    } catch (error) {
      results[webhook] = {
        status: 'failed',
        error: error.message
      };
    }
  }
  
  console.log('Webhook Test Results:', results);
  return results;
};

// Generate appropriate test payload for each webhook
const generateTestPayload = (webhookType) => {
  const payloads = {
    'context-request': {
      user_id: 'test_user',
      workflow_type: 'test',
      current_input: 'Test input'
    },
    'epic-cascade': {
      epic_id: 'test_epic_123',
      epic_title: 'Test Epic',
      epic_description: 'Test description'
    }
    // ... other test payloads
  };
  
  return payloads[webhookType];
};
```

---

This configuration guide provides everything needed to set up robust webhook communication between your n8n workflows, enabling real-time, personalized automation throughout your Notion PMS.