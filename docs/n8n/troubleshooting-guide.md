# n8n Troubleshooting Guide

## Common Issues and Solutions

This guide addresses the most common issues you might encounter while implementing your AI-Augmented Notion PMS with n8n.

---

## 🔴 Critical Issues

### 1. Notion API Connection Failures

#### Symptoms:
- "Invalid API Token" error
- "Unauthorized" responses
- Cannot retrieve database items

#### Solutions:
```javascript
// Verify token format
const CORRECT_FORMAT = "ntn_f35248778523jpOe6IQngDnseZlexMBsf2YC7jt6WEb9NF";

// In n8n:
1. Go to Credentials → Notion API
2. Ensure token starts with "ntn_"
3. No extra spaces before/after token
4. Test connection with simple query
```

#### Advanced Fix:
```javascript
// Test connection manually
const testNotionConnection = async () => {
  const response = await fetch('https://api.notion.com/v1/users/me', {
    headers: {
      'Authorization': 'Bearer YOUR_TOKEN',
      'Notion-Version': '2022-06-28'
    }
  });
  console.log(await response.json());
};
```

### 2. OpenAI Rate Limits

#### Symptoms:
- 429 "Rate limit exceeded" errors
- Workflows failing after multiple executions
- "Insufficient quota" messages

#### Solutions:

**Immediate Fix:**
```javascript
// Add delay node between OpenAI calls
{
  "name": "Rate Limit Delay",
  "type": "n8n-nodes-base.wait",
  "parameters": {
    "amount": 2,
    "unit": "seconds"
  }
}
```

**Long-term Fix:**
```javascript
// Implement exponential backoff
const exponentialBackoff = async (fn, maxRetries = 5) => {
  let retries = 0;
  while (retries < maxRetries) {
    try {
      return await fn();
    } catch (error) {
      if (error.status === 429) {
        const delay = Math.pow(2, retries) * 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
        retries++;
      } else {
        throw error;
      }
    }
  }
};
```

### 3. Workflow Execution Timeouts

#### Symptoms:
- Workflows stuck in "Running" state
- Timeout errors after 5 minutes
- Large data processing failures

#### Solutions:

**Quick Fix:**
```javascript
// In workflow settings
{
  "settings": {
    "executionTimeout": 900, // 15 minutes
    "maxExecutionTime": 900
  }
}
```

**Optimization:**
```javascript
// Process in batches
const BATCH_SIZE = 10;
for (let i = 0; i < items.length; i += BATCH_SIZE) {
  const batch = items.slice(i, i + BATCH_SIZE);
  await processBatch(batch);
}
```

---

## 🟡 Performance Issues

### 4. Slow Context Loading

#### Symptoms:
- Context management takes >10 seconds
- Personalization not working properly
- MongoDB queries timing out

#### Solutions:

**Index Optimization:**
```javascript
// Add indexes to MongoDB
db.user_context.createIndex({ user_id: 1, timestamp: -1 });
db.interaction_history.createIndex({ workflow: 1, timestamp: -1 });
db.knowledge_graph.createIndex({ embedding: "2dsphere" });
```

**Query Optimization:**
```javascript
// Limit context window
const recentContext = await db.interaction_history
  .find({ user_id, timestamp: { $gte: thirtyDaysAgo } })
  .sort({ timestamp: -1 })
  .limit(100);
```

### 5. Memory Issues with Large Datasets

#### Symptoms:
- n8n crashes with large Notion queries
- "JavaScript heap out of memory" errors
- Browser tab freezing

#### Solutions:

**Pagination Implementation:**
```javascript
// Paginate Notion queries
async function getAllItems(databaseId) {
  let allItems = [];
  let hasMore = true;
  let startCursor = undefined;
  
  while (hasMore) {
    const response = await notion.databases.query({
      database_id: databaseId,
      page_size: 100,
      start_cursor: startCursor
    });
    
    allItems = allItems.concat(response.results);
    hasMore = response.has_more;
    startCursor = response.next_cursor;
  }
  
  return allItems;
}
```

---

## 🟢 Configuration Issues

### 6. Webhook URLs Not Working

#### Symptoms:
- Workflows not triggering
- "Webhook not found" errors
- Cannot receive external triggers

#### Solutions:

**Local Development:**
```bash
# Use ngrok for local webhooks
ngrok http 5678

# Your webhook URL becomes:
https://abc123.ngrok.io/webhook/YOUR_WEBHOOK_ID
```

**Production Setup:**
```javascript
// Configure base URL in n8n
N8N_WEBHOOK_BASE_URL=https://your-domain.com
N8N_PROTOCOL=https
N8N_HOST=your-domain.com
```

### 7. Database ID Mismatches

#### Symptoms:
- "Database not found" errors
- Wrong items being updated
- Relations not working

#### Solutions:

**Verification Script:**
```javascript
// Verify all database IDs
const databases = {
  projects: '2200d219-5e1c-81e4-9522-fba13a081601',
  epics: '21e0d2195e1c809bae77f183b66a78b2',
  stories: '21e0d2195e1c806a947ff1806bffa2fb',
  tasks: '21e0d2195e1c80a28c67dc2a8ed20e1b',
  inbox: '21e0d2195e1c80228d8cf8ffd2a27275',
  knowledge_base: '21e0d2195e1c802ca067e05dd1e4e908'
};

// Test each database
for (const [name, id] of Object.entries(databases)) {
  try {
    await notion.databases.retrieve({ database_id: id });
    console.log(`✅ ${name}: ${id} - Valid`);
  } catch (error) {
    console.log(`❌ ${name}: ${id} - Invalid`);
  }
}
```

---

## 🔧 Workflow-Specific Issues

### 8. Intelligent Inbox Processing Not Categorizing

#### Symptoms:
- All items marked as "Archive"
- Incorrect entity type detection
- Low confidence scores

#### Solutions:

**Prompt Debugging:**
```javascript
// Add debug node after AI Analysis
{
  "name": "Debug AI Response",
  "type": "n8n-nodes-base.code",
  "parameters": {
    "jsCode": `
console.log("AI Raw Response:", $input.first().json);
console.log("Parsed Classification:", JSON.parse($input.first().json.choices[0].message.content));
return $input.first();
    `
  }
}
```

**Context Enhancement:**
```javascript
// Ensure sufficient context
const minContextRequired = {
  activeEpics: 3,
  activeStories: 5,
  activeTasks: 10,
  recentKnowledge: 5
};

// Add fallback for empty context
if (activeEpics.length === 0) {
  context.noActiveWork = true;
  context.suggestNewProject = true;
}
```

### 9. Epic Cascade Not Creating Stories

#### Symptoms:
- Epic created but no stories generated
- Webhook not triggering cascade
- Stories created without tasks

#### Solutions:

**Webhook Configuration:**
```javascript
// Ensure webhook is active
{
  "name": "Trigger Epic Cascade",
  "type": "n8n-nodes-base.webhook",
  "webhookId": "epic-cascade-webhook",
  "parameters": {
    "httpMethod": "POST",
    "path": "epic-cascade",
    "responseMode": "onReceived",
    "options": {
      "activeWorkflows": true
    }
  }
}
```

**Error Handling:**
```javascript
// Add error handling to cascade
try {
  const stories = await generateStories(epic);
  if (stories.length === 0) {
    throw new Error("No stories generated");
  }
  return stories;
} catch (error) {
  // Create fallback story
  return [{
    title: "Define Epic Requirements",
    description: "Epic needs further refinement",
    status: "To Do"
  }];
}
```

### 10. Learning Not Improving

#### Symptoms:
- Same mistakes repeated
- No personalization visible
- Context not updating

#### Solutions:

**Verify Learning Pipeline:**
```javascript
// Check learning data flow
const verifyLearning = async () => {
  // 1. Check if interactions are being stored
  const recentInteractions = await db.interaction_history
    .find({})
    .sort({ timestamp: -1 })
    .limit(10);
  
  console.log("Recent interactions:", recentInteractions.length);
  
  // 2. Check if patterns are being extracted
  const patterns = await db.user_context
    .findOne({ user_id });
  
  console.log("Stored patterns:", patterns);
  
  // 3. Check if context is being used
  const contextRequests = await db.context_requests
    .find({})
    .sort({ timestamp: -1 })
    .limit(10);
  
  console.log("Context requests:", contextRequests.length);
};
```

---

## 📊 Monitoring & Diagnostics

### Health Check Script

```javascript
// Comprehensive health check
const healthCheck = async () => {
  const checks = {
    notion: false,
    openai: false,
    mongodb: false,
    webhooks: false,
    workflows: {}
  };
  
  // Check Notion
  try {
    await notion.users.me();
    checks.notion = true;
  } catch (e) {
    console.error("Notion check failed:", e);
  }
  
  // Check OpenAI
  try {
    await openai.models.list();
    checks.openai = true;
  } catch (e) {
    console.error("OpenAI check failed:", e);
  }
  
  // Check MongoDB
  try {
    await db.admin().ping();
    checks.mongodb = true;
  } catch (e) {
    console.error("MongoDB check failed:", e);
  }
  
  // Check critical workflows
  const criticalWorkflows = [
    'intelligent-inbox-processing',
    'llm-context-management'
  ];
  
  for (const workflow of criticalWorkflows) {
    checks.workflows[workflow] = await checkWorkflowActive(workflow);
  }
  
  return checks;
};
```

### Performance Monitoring

```javascript
// Add performance tracking
const performanceMonitor = {
  trackExecution: (workflowName, startTime) => {
    const duration = Date.now() - startTime;
    console.log(`${workflowName} execution time: ${duration}ms`);
    
    if (duration > 10000) {
      console.warn(`⚠️ ${workflowName} is running slow!`);
    }
  },
  
  trackAPIUsage: (service, tokens) => {
    const usage = {
      service,
      tokens,
      timestamp: new Date(),
      cost: calculateCost(service, tokens)
    };
    
    db.api_usage.insertOne(usage);
  }
};
```

---

## 🚨 Emergency Procedures

### Complete System Reset

If nothing else works:

```bash
# 1. Export your data
mongodump --db notion_pms_context --out backup/

# 2. Clear all workflows
# In n8n UI: Settings → Delete all workflows

# 3. Reset MongoDB
mongo notion_pms_context --eval "db.dropDatabase()"

# 4. Reimport workflows
# Start with core workflows only

# 5. Test with single inbox item
# Verify basic functionality before full deployment
```

### Rollback Procedure

```javascript
// Keep workflow versions
const workflowBackup = {
  beforeChanges: async (workflowId) => {
    const current = await getWorkflow(workflowId);
    await saveBackup(workflowId, current);
  },
  
  rollback: async (workflowId, version) => {
    const backup = await getBackup(workflowId, version);
    await restoreWorkflow(workflowId, backup);
  }
};
```

---

## 📞 Getting Help

### Debug Information to Collect

When seeking help, collect:

```javascript
const debugInfo = {
  n8n_version: await getN8nVersion(),
  node_version: process.version,
  workflow_error: {
    workflow_name: errorWorkflow,
    error_message: error.message,
    error_node: errorNode,
    execution_id: executionId
  },
  api_versions: {
    notion: "2022-06-28",
    openai: "v1"
  },
  recent_changes: getRecentChanges()
};

console.log(JSON.stringify(debugInfo, null, 2));
```

### Community Resources

1. **n8n Community Forum**: https://community.n8n.io
2. **GitHub Issues**: Report bugs with workflow JSON
3. **Discord**: Real-time help from community

### Professional Support

For critical implementations:
- n8n Cloud support (if using cloud version)
- Notion API support for integration issues
- OpenAI support for API problems

---

Remember: Most issues are configuration-related. Double-check credentials, IDs, and webhook URLs before assuming there's a bug.