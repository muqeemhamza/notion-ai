# Webhook Implementation Guide for n8n

## Overview
This guide provides detailed webhook implementations for the LLM Context Management system, following n8n's webhook patterns and best practices.

---

## 🔗 Core Webhook Architecture

### Webhook Types in n8n
1. **Webhook Trigger Nodes** - Start workflows on HTTP requests
2. **HTTP Request Nodes** - Call webhooks from workflows
3. **Webhook Response Nodes** - Send responses back to callers

### Base Configuration
```javascript
// Environment variables
N8N_WEBHOOK_BASE_URL=https://your-domain.com
N8N_WEBHOOK_TUNNEL_URL=https://your-domain.com/
N8N_PROTOCOL=https
N8N_HOST=your-domain.com
WEBHOOK_SECRET=your-secure-random-string
```

---

## 📡 Context Management Webhook

### 1. Context Request Webhook (Receiver)

```json
{
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "context-request",
        "responseMode": "onReceived",
        "responseData": "allEntries",
        "options": {
          "responseCode": 200,
          "responseHeaders": {
            "entries": [
              {
                "name": "Content-Type",
                "value": "application/json"
              },
              {
                "name": "X-Response-Time",
                "value": "={{Date.now() - $json.requestTime}}"
              }
            ]
          }
        }
      },
      "name": "Context Request Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [250, 300],
      "id": "webhook_context_request"
    },
    {
      "parameters": {
        "jsCode": "// Validate incoming request\nconst requiredFields = ['workflow', 'user_id'];\nconst errors = [];\n\nfor (const field of requiredFields) {\n  if (!$input.first().json.body[field]) {\n    errors.push(`Missing required field: ${field}`);\n  }\n}\n\n// Validate webhook signature\nconst signature = $input.first().json.headers['x-webhook-signature'];\nif (signature) {\n  const crypto = require('crypto');\n  const payload = JSON.stringify($input.first().json.body);\n  const expectedSignature = crypto\n    .createHmac('sha256', $env.WEBHOOK_SECRET)\n    .update(payload)\n    .digest('hex');\n  \n  if (signature !== expectedSignature) {\n    errors.push('Invalid webhook signature');\n  }\n}\n\nif (errors.length > 0) {\n  throw new Error(errors.join(', '));\n}\n\n// Add metadata\nreturn {\n  ...($input.first().json.body),\n  requestTime: Date.now(),\n  requestId: crypto.randomUUID(),\n  validated: true\n};"
      },
      "name": "Validate Request",
      "type": "n8n-nodes-base.code",
      "typeVersion": 1,
      "position": [450, 300]
    },
    {
      "parameters": {
        "jsCode": "// Load user context from storage\nconst staticData = $getWorkflowStaticData('global');\nconst userId = $json.user_id;\nconst workflow = $json.workflow;\n\n// Initialize if needed\nif (!staticData.userContexts) {\n  staticData.userContexts = {};\n}\n\nif (!staticData.userContexts[userId]) {\n  staticData.userContexts[userId] = {\n    preferences: {\n      writingStyle: {},\n      vocabularyPreferences: {},\n      formattingPatterns: {}\n    },\n    patterns: {\n      taskBreakdown: {},\n      prioritization: {},\n      naming: {}\n    },\n    history: [],\n    knowledge: {},\n    lastUpdated: new Date().toISOString()\n  };\n}\n\nconst userContext = staticData.userContexts[userId];\n\n// Get recent interactions\nconst recentInteractions = userContext.history\n  .filter(h => h.workflow === workflow)\n  .slice(-10);\n\n// Get active work items\nconst activeWork = {\n  projects: $json.activeProjects || [],\n  epics: $json.activeEpics || [],\n  stories: $json.activeStories || [],\n  tasks: $json.activeTasks || []\n};\n\nreturn {\n  userId,\n  workflow,\n  context: userContext,\n  recentInteractions,\n  activeWork,\n  requestId: $json.requestId\n};"
      },
      "name": "Load User Context",
      "type": "n8n-nodes-base.code",
      "typeVersion": 1,
      "position": [650, 300]
    },
    {
      "parameters": {
        "jsCode": "// Build personalized context response\nconst context = $json.context;\nconst activeWork = $json.activeWork;\nconst recentInteractions = $json.recentInteractions;\n\n// Analyze patterns\nconst patterns = {\n  // Writing style analysis\n  writingStyle: {\n    averageSentenceLength: calculateAvgSentenceLength(context.history),\n    preferredVocabulary: extractVocabulary(context.history),\n    tone: detectTone(context.history),\n    formality: detectFormality(context.history)\n  },\n  \n  // Decision patterns\n  decisionPatterns: {\n    taskEstimation: analyzeEstimationPatterns(context.history),\n    prioritization: analyzePrioritizationPatterns(context.history),\n    categorization: analyzeCategorizationPatterns(context.history)\n  },\n  \n  // Work patterns\n  workPatterns: {\n    activeProjectTypes: categorizeProjects(activeWork.projects),\n    taskComplexity: analyzeTaskComplexity(activeWork.tasks),\n    collaborationStyle: analyzeCollaboration(context.history)\n  }\n};\n\n// Build examples from history\nconst relevantExamples = recentInteractions\n  .filter(i => i.success && i.confidence > 0.8)\n  .map(i => ({\n    input: i.input,\n    output: i.output,\n    type: i.type\n  }))\n  .slice(0, 5);\n\n// Create personalized prompts\nconst personalizedPrompts = {\n  classification: buildClassificationPrompt(patterns, relevantExamples),\n  generation: buildGenerationPrompt(patterns, context.preferences),\n  prioritization: buildPrioritizationPrompt(patterns.decisionPatterns)\n};\n\n// Helper functions (simplified for example)\nfunction calculateAvgSentenceLength(history) {\n  return 15; // Placeholder\n}\n\nfunction extractVocabulary(history) {\n  return ['implement', 'analyze', 'optimize']; // Placeholder\n}\n\nfunction detectTone(history) {\n  return 'professional'; // Placeholder\n}\n\nfunction detectFormality(history) {\n  return 'medium'; // Placeholder\n}\n\nfunction analyzeEstimationPatterns(history) {\n  return { tendency: 'conservative', accuracy: 0.85 };\n}\n\nfunction analyzePrioritizationPatterns(history) {\n  return { method: 'urgency-importance', bias: 'technical' };\n}\n\nfunction analyzeCategorizationPatterns(history) {\n  return { granularity: 'detailed', consistency: 0.9 };\n}\n\nfunction categorizeProjects(projects) {\n  return ['technical', 'strategic'];\n}\n\nfunction analyzeTaskComplexity(tasks) {\n  return { average: 'medium', distribution: [0.2, 0.6, 0.2] };\n}\n\nfunction analyzeCollaboration(history) {\n  return 'distributed';\n}\n\nfunction buildClassificationPrompt(patterns, examples) {\n  return `Classify using user's patterns...`;\n}\n\nfunction buildGenerationPrompt(patterns, preferences) {\n  return `Generate in user's style...`;\n}\n\nfunction buildPrioritizationPrompt(patterns) {\n  return `Prioritize using user's method...`;\n}\n\nreturn {\n  requestId: $json.requestId,\n  userId: $json.userId,\n  workflow: $json.workflow,\n  context: {\n    patterns,\n    examples: relevantExamples,\n    prompts: personalizedPrompts,\n    activeWork,\n    preferences: context.preferences\n  },\n  metadata: {\n    contextVersion: '2.0',\n    generatedAt: new Date().toISOString(),\n    ttl: 300 // 5 minutes\n  }\n};"
      },
      "name": "Build Personalized Context",
      "type": "n8n-nodes-base.code",
      "typeVersion": 1,
      "position": [850, 300]
    }
  ],
  "connections": {
    "Context Request Webhook": {
      "main": [[{"node": "Validate Request", "type": "main", "index": 0}]]
    },
    "Validate Request": {
      "main": [[{"node": "Load User Context", "type": "main", "index": 0}]]
    },
    "Load User Context": {
      "main": [[{"node": "Build Personalized Context", "type": "main", "index": 0}]]
    }
  }
}
```

### 2. Context Request Caller (From Other Workflows)

```json
{
  "parameters": {
    "authentication": "genericCredentialType",
    "genericAuthType": "httpHeaderAuth",
    "url": "={{$env.N8N_WEBHOOK_BASE_URL}}/webhook/context-request",
    "sendHeaders": true,
    "headerParameters": {
      "parameters": [
        {
          "name": "X-Webhook-Signature",
          "value": "={{$evaluateExpression($env.WEBHOOK_SECRET, $json)}}"
        },
        {
          "name": "X-Request-ID",
          "value": "={{$guid}}"
        }
      ]
    },
    "sendBody": true,
    "bodyParameters": {
      "parameters": [
        {
          "name": "workflow",
          "value": "intelligent_inbox_processing"
        },
        {
          "name": "user_id",
          "value": "={{$env.USER_ID}}"
        },
        {
          "name": "activeProjects",
          "value": "={{$json.projects}}"
        },
        {
          "name": "activeEpics",
          "value": "={{$json.epics}}"
        },
        {
          "name": "timestamp",
          "value": "={{new Date().toISOString()}}"
        }
      ]
    },
    "options": {
      "timeout": 10000,
      "response": {
        "response": {
          "fullResponse": true
        }
      }
    }
  },
  "name": "Request Context",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 3,
  "position": [450, 500]
}
```

---

## 📚 Learning Capture Webhook

### 1. Learning Capture Receiver

```json
{
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "learning-capture",
        "responseMode": "onReceived",
        "responseData": "firstEntryJson",
        "options": {
          "responseCode": 202,
          "responseHeaders": {
            "entries": [
              {
                "name": "X-Learning-Status",
                "value": "accepted"
              }
            ]
          }
        }
      },
      "name": "Learning Capture Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [250, 300]
    },
    {
      "parameters": {
        "jsCode": "// Process learning data asynchronously\nconst learningData = $input.first().json.body;\n\n// Validate structure\nconst required = ['interaction', 'input', 'ai_response', 'user_action', 'outcome'];\nfor (const field of required) {\n  if (!learningData[field]) {\n    throw new Error(`Missing required field: ${field}`);\n  }\n}\n\n// Queue for processing\nconst staticData = $getWorkflowStaticData('global');\nif (!staticData.learningQueue) {\n  staticData.learningQueue = [];\n}\n\nstaticData.learningQueue.push({\n  ...learningData,\n  queuedAt: new Date().toISOString(),\n  processed: false\n});\n\n// Return acknowledgment\nreturn {\n  status: 'accepted',\n  queuePosition: staticData.learningQueue.length,\n  processingTime: 'async'\n};"
      },
      "name": "Queue Learning Data",
      "type": "n8n-nodes-base.code",
      "typeVersion": 1,
      "position": [450, 300]
    }
  ]
}
```

### 2. Learning Processor (Scheduled)

```json
{
  "nodes": [
    {
      "parameters": {
        "rule": {
          "interval": [
            {
              "field": "minutes",
              "minutesInterval": 5
            }
          ]
        }
      },
      "name": "Schedule Trigger",
      "type": "n8n-nodes-base.scheduleTrigger",
      "typeVersion": 1,
      "position": [250, 300]
    },
    {
      "parameters": {
        "jsCode": "// Process queued learning data\nconst staticData = $getWorkflowStaticData('global');\nconst queue = staticData.learningQueue || [];\n\n// Get unprocessed items\nconst unprocessed = queue.filter(item => !item.processed);\n\nif (unprocessed.length === 0) {\n  return { processed: 0, message: 'No items to process' };\n}\n\n// Process in batches\nconst BATCH_SIZE = 10;\nconst batch = unprocessed.slice(0, BATCH_SIZE);\n\nconst results = [];\nfor (const item of batch) {\n  try {\n    // Extract patterns\n    const patterns = extractPatterns(item);\n    \n    // Update user context\n    updateUserContext(item.interaction.user_id, patterns);\n    \n    // Mark as processed\n    item.processed = true;\n    item.processedAt = new Date().toISOString();\n    \n    results.push({\n      success: true,\n      itemId: item.interaction.timestamp,\n      patterns: patterns.length\n    });\n  } catch (error) {\n    results.push({\n      success: false,\n      itemId: item.interaction.timestamp,\n      error: error.message\n    });\n  }\n}\n\nfunction extractPatterns(item) {\n  const patterns = [];\n  \n  // Writing style patterns\n  if (item.user_action.modifications) {\n    patterns.push({\n      type: 'writing_style',\n      original: item.ai_response.text,\n      modified: item.user_action.final_text,\n      confidence: 0.8\n    });\n  }\n  \n  // Decision patterns\n  if (item.user_action.accepted === false) {\n    patterns.push({\n      type: 'decision_correction',\n      ai_choice: item.ai_response.classification,\n      user_choice: item.user_action.final_choice,\n      context: item.input.context\n    });\n  }\n  \n  return patterns;\n}\n\nfunction updateUserContext(userId, patterns) {\n  if (!staticData.userContexts) {\n    staticData.userContexts = {};\n  }\n  \n  if (!staticData.userContexts[userId]) {\n    staticData.userContexts[userId] = {\n      patterns: [],\n      lastUpdated: new Date().toISOString()\n    };\n  }\n  \n  // Add new patterns\n  staticData.userContexts[userId].patterns.push(...patterns);\n  staticData.userContexts[userId].lastUpdated = new Date().toISOString();\n  \n  // Keep only recent patterns (last 100)\n  if (staticData.userContexts[userId].patterns.length > 100) {\n    staticData.userContexts[userId].patterns = \n      staticData.userContexts[userId].patterns.slice(-100);\n  }\n}\n\nreturn results;"
      },
      "name": "Process Learning Queue",
      "type": "n8n-nodes-base.code",
      "typeVersion": 1,
      "position": [450, 300]
    }
  ]
}
```

---

## 🔄 Workflow Integration Webhooks

### Epic Creation Cascade Webhook

```json
{
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "epic-cascade",
        "authentication": "headerAuth",
        "options": {}
      },
      "name": "Epic Cascade Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [250, 300],
      "credentials": {
        "httpHeaderAuth": {
          "id": "1",
          "name": "Webhook Auth"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "// Trigger story and task generation\nconst epic = $json.body;\n\n// Validate epic data\nif (!epic.epic_id || !epic.epic_title) {\n  throw new Error('Invalid epic data');\n}\n\n// Request context for story generation\nconst contextRequest = {\n  workflow: 'epic_cascade',\n  user_id: epic.created_by || $env.USER_ID,\n  epic_context: {\n    id: epic.epic_id,\n    title: epic.epic_title,\n    description: epic.epic_description,\n    project_id: epic.project_id\n  }\n};\n\nreturn contextRequest;"
      },
      "name": "Prepare Context Request",
      "type": "n8n-nodes-base.code",
      "typeVersion": 1,
      "position": [450, 300]
    }
  ]
}
```

---

## 🛡️ Security Configuration

### Webhook Authentication Setup

```javascript
// n8n Credentials Configuration
{
  "httpHeaderAuth": {
    "name": "Webhook Auth",
    "type": "httpHeaderAuth",
    "data": {
      "name": "X-Webhook-Secret",
      "value": "={{$env.WEBHOOK_SECRET}}"
    }
  }
}
```

### Signature Generation Helper

```json
{
  "parameters": {
    "functionCode": "const crypto = require('crypto');\n\n// Generate webhook signature\nconst generateSignature = (payload, secret) => {\n  return crypto\n    .createHmac('sha256', secret)\n    .update(JSON.stringify(payload))\n    .digest('hex');\n};\n\n// Verify webhook signature\nconst verifySignature = (payload, signature, secret) => {\n  const expected = generateSignature(payload, secret);\n  return crypto.timingSafeEqual(\n    Buffer.from(signature),\n    Buffer.from(expected)\n  );\n};\n\n// Generate secure webhook token\nconst generateToken = () => {\n  return crypto.randomBytes(32).toString('hex');\n};\n\nreturn {\n  generateSignature,\n  verifySignature,\n  generateToken\n};"
  },
  "name": "Security Helpers",
  "type": "n8n-nodes-base.function",
  "typeVersion": 1,
  "position": [650, 500]
}
```

---

## 🧪 Testing Webhooks

### Webhook Test Workflow

```json
{
  "nodes": [
    {
      "parameters": {
        "jsCode": "// Test all webhooks\nconst webhooks = [\n  {\n    name: 'Context Request',\n    url: `${$env.N8N_WEBHOOK_BASE_URL}/webhook/context-request`,\n    payload: {\n      workflow: 'test',\n      user_id: 'test_user',\n      timestamp: new Date().toISOString()\n    }\n  },\n  {\n    name: 'Learning Capture',\n    url: `${$env.N8N_WEBHOOK_BASE_URL}/webhook/learning-capture`,\n    payload: {\n      interaction: {\n        workflow: 'test',\n        timestamp: new Date().toISOString(),\n        user_id: 'test_user'\n      },\n      input: { raw_text: 'Test input' },\n      ai_response: { classification: 'task' },\n      user_action: { accepted: true },\n      outcome: { success: true }\n    }\n  }\n];\n\nreturn webhooks;"
      },
      "name": "Prepare Test Payloads",
      "type": "n8n-nodes-base.code",
      "typeVersion": 1,
      "position": [250, 300]
    },
    {
      "parameters": {
        "url": "={{$json.url}}",
        "authentication": "genericCredentialType",
        "genericAuthType": "httpHeaderAuth",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "X-Webhook-Signature",
              "value": "={{$evaluateExpression($env.WEBHOOK_SECRET, $json.payload)}}"
            }
          ]
        },
        "sendBody": true,
        "bodyContentType": "json",
        "jsonBody": "={{JSON.stringify($json.payload)}}",
        "options": {
          "timeout": 5000
        }
      },
      "name": "Test Webhook",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 3,
      "position": [450, 300]
    },
    {
      "parameters": {
        "jsCode": "// Analyze test results\nconst results = $items().map(item => ({\n  webhook: item.json.name,\n  status: item.json.statusCode === 200 ? 'Success' : 'Failed',\n  responseTime: item.json.responseTime || 'N/A',\n  error: item.json.error || null\n}));\n\nreturn results;"
      },
      "name": "Analyze Results",
      "type": "n8n-nodes-base.code",
      "typeVersion": 1,
      "position": [650, 300]
    }
  ]
}
```

---

## 📊 Monitoring Dashboard

### Webhook Health Monitor

```json
{
  "nodes": [
    {
      "parameters": {
        "rule": {
          "interval": [
            {
              "field": "hours",
              "hoursInterval": 1
            }
          ]
        }
      },
      "name": "Hourly Check",
      "type": "n8n-nodes-base.scheduleTrigger",
      "typeVersion": 1,
      "position": [250, 300]
    },
    {
      "parameters": {
        "jsCode": "// Check webhook health\nconst webhookStats = $getWorkflowStaticData('global').webhookStats || {};\n\nconst healthReport = {\n  timestamp: new Date().toISOString(),\n  webhooks: {}\n};\n\n// Analyze each webhook\nfor (const [webhook, stats] of Object.entries(webhookStats)) {\n  const recentCalls = stats.calls?.filter(c => \n    new Date(c.timestamp) > new Date(Date.now() - 3600000)\n  ) || [];\n  \n  healthReport.webhooks[webhook] = {\n    totalCalls: recentCalls.length,\n    successRate: calculateSuccessRate(recentCalls),\n    avgResponseTime: calculateAvgResponseTime(recentCalls),\n    errors: recentCalls.filter(c => !c.success).length,\n    status: determineStatus(recentCalls)\n  };\n}\n\nfunction calculateSuccessRate(calls) {\n  if (calls.length === 0) return 0;\n  const successful = calls.filter(c => c.success).length;\n  return (successful / calls.length) * 100;\n}\n\nfunction calculateAvgResponseTime(calls) {\n  if (calls.length === 0) return 0;\n  const total = calls.reduce((sum, c) => sum + (c.responseTime || 0), 0);\n  return Math.round(total / calls.length);\n}\n\nfunction determineStatus(calls) {\n  if (calls.length === 0) return 'inactive';\n  const successRate = calculateSuccessRate(calls);\n  if (successRate >= 95) return 'healthy';\n  if (successRate >= 80) return 'degraded';\n  return 'unhealthy';\n}\n\nreturn healthReport;"
      },
      "name": "Generate Health Report",
      "type": "n8n-nodes-base.code",
      "typeVersion": 1,
      "position": [450, 300]
    }
  ]
}
```

---

This implementation guide provides production-ready webhook configurations that align with n8n's architecture while enabling the deep personalization capabilities of our LLM Context Management system.