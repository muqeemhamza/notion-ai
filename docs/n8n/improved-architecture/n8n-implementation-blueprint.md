# n8n Implementation Blueprint - AI-Augmented Notion PMS

## Overview
This blueprint provides a production-ready implementation of the AI-Augmented Notion PMS using n8n's actual architecture and capabilities, now enhanced with the **Unified Intelligence Layer** that creates bidirectional integration between:
- **Context Management** (user patterns, preferences, state)
- **Learning Engine** (continuous improvement from interactions)
- **Knowledge Base** (active retrieval and contribution of solutions)

This design creates a living, learning system where every interaction makes all future interactions smarter through compound learning across all three systems.

---

## 🏗️ Architecture Overview

### Core Components - Unified Intelligence Architecture
1. **Unified Intelligence Hub** - Central orchestrator for Context Management + Learning Engine + Knowledge Base
2. **Intelligent Processing Engine** - Main workflow enhanced with KB-aware processing
3. **Bidirectional Learning Loop** - Captures interactions and updates both patterns AND Knowledge Base
4. **Knowledge Graph Storage** - Persistent storage with embeddings for semantic search
5. **Unified Intelligence API** - Single interface providing integrated context from all three systems
6. **KB Effectiveness Tracker** - Monitors which knowledge entries actually help users

### Enhanced Data Flow with Bidirectional Updates
```
Inbox Note → Unified Intelligence Request → [Context + KB + Learning] → AI Analysis → Action Execution
     ↓                                                                                          ↓
     ↓                                    Bidirectional Updates                                ↓
     ↓                          ┌─────────────────────────────────────────┐                  ↓
     └──────────────────────────→ Learning Engine ←→ Knowledge Base ←→ Context ←──────────────┘
                                └─────────────────────────────────────────┘
                                         ↑                    ↑
                                         └────────────────────┘
                                        Continuous Improvement
```

---

## 📊 State Management Solution

### Option 1: n8n Static Data with Unified Intelligence
```javascript
// Enhanced storage with bidirectional KB integration
const unifiedIntelligenceStorage = {
  // User context with KB tracking
  userContext: {
    writingStyle: {},
    decisionPatterns: {},
    projectPreferences: {},
    vocabularyMap: {},
    kbEffectiveness: {}, // Track which KB entries work for this user
    lastUpdated: new Date()
  },
  
  // Enhanced interaction history
  interactions: {
    history: [],
    kbUsage: {}, // Track KB entry usage per interaction
    novelSolutions: [] // Candidates for new KB entries
  },
  
  // Knowledge Base cache
  knowledgeBase: {
    entries: {}, // KB entries with embeddings
    effectiveness: {}, // Global effectiveness metrics
    triggers: {} // When to suggest each entry
  },
  
  // Unified knowledge graph
  knowledgeGraph: {
    concepts: {},
    relationships: {},
    embeddings: {},
    kbLinks: {} // Links between concepts and KB entries
  },
  
  // Learning queue for async processing
  learningQueue: []
};

// Access unified intelligence in any workflow
const unified = $getWorkflowStaticData('unified_intelligence');
```

### Option 2: Supabase Integration with KB Tables
```javascript
// Enhanced Supabase schema for unified intelligence
const unifiedSchema = {
  // User context with KB tracking
  user_context: {
    id: 'uuid',
    user_id: 'text',
    preferences: 'jsonb',
    patterns: 'jsonb',
    kb_effectiveness: 'jsonb', // User-specific KB effectiveness
    updated_at: 'timestamp'
  },
  
  // Enhanced interaction history
  interaction_history: {
    id: 'uuid',
    workflow: 'text',
    input: 'jsonb',
    output: 'jsonb',
    user_feedback: 'jsonb',
    kb_usage: 'jsonb', // Which KB entries were provided/used
    novel_solution: 'boolean', // Is this a new approach?
    timestamp: 'timestamp'
  },
  
  // Knowledge Base entries
  knowledge_base: {
    id: 'uuid',
    title: 'text',
    type: 'text', // pattern, solution, lesson, reference
    content: 'jsonb',
    metadata: 'jsonb',
    embeddings: 'vector(1536)',
    triggers: 'jsonb', // Keywords, patterns, contexts
    success_rate: 'float',
    usage_count: 'integer',
    created_from: 'text', // learning_loop, manual, import
    created_at: 'timestamp'
  },
  
  // KB effectiveness tracking
  kb_effectiveness: {
    id: 'uuid',
    user_id: 'uuid',
    kb_entry_id: 'uuid',
    times_provided: 'integer',
    times_used: 'integer',
    average_effectiveness: 'float',
    last_used: 'timestamp'
  },
  
  // Enhanced knowledge graph
  knowledge_graph: {
    id: 'uuid',
    user_id: 'text',
    concept: 'text',
    embeddings: 'vector(1536)',
    kb_entries: 'uuid[]', // Array of related KB IDs
    relationships: 'jsonb',
    frequency: 'integer',
    updated_at: 'timestamp'
  }
};
```

---

## 🔄 Workflow Implementations

### 1. Unified Intelligence Hub (Foundation)

```yaml
Workflow: unified-intelligence-hub
Trigger: Webhook (unified-context-request)
Nodes:
  1. Webhook Trigger
     - Path: /unified/context
     - Method: POST
     - Response: onReceived
     
  2. Validate Request
     - Type: Code
     - Validate required fields
     - Check authentication
     - Extract intent and keywords
     
  3. Parallel Data Gathering
     - Type: Split In Batches
     - Branches:
       a) Learning Engine Query
          - Get user patterns
          - Get corrections history
          - Get success patterns
       b) Knowledge Base Search
          - Text search for keywords
          - Embedding similarity search
          - Pattern-based retrieval
       c) Active State Load
          - Current projects/epics
          - Recent activities
          - Open items
     
  4. Build Knowledge Graph
     - Type: Code
     - Merge all data sources
     - Create concept relationships
     - Link to KB entries
     - Calculate relevance scores
     
  5. Synthesize Unified Context
     - Type: Code
     - Integrate patterns + KB + state
     - Rank by user effectiveness
     - Include top KB solutions
     - Add personalization layer
     
  6. Track Context Usage
     - Type: Code
     - Record which KB entries provided
     - Log context request metadata
     - Queue for learning
     
  7. Cache and Return
     - Type: Code + Webhook Response
     - Cache unified context
     - Return enriched response
     - Include KB suggestions
```

### 2. Intelligent Inbox Processing with KB Integration

```yaml
Workflow: intelligent-inbox-processing-unified
Trigger: Manual/Scheduled
Nodes:
  1. Fetch Inbox Items
     - Type: Notion
     - Database: Inbox
     - Filter: Unprocessed
     
  2. Request Unified Context
     - Type: HTTP Request
     - URL: {{$env.N8N_WEBHOOK_URL}}/unified/context
     - Method: POST
     - Body: {
         "workflow": "inbox_processing",
         "user_id": "{{$env.USER_ID}}",
         "current_items": "{{$json}}",
         "keywords": extractKeywords($json),
         "includeKB": true
       }
     
  3. Prepare Enhanced AI Prompt
     - Type: Code
     - Include user patterns from Learning Engine
     - Add relevant KB solutions
     - Include similar past cases
     - Apply personalization requirements
     
  4. AI Analysis with KB Context
     - Type: OpenAI
     - Model: gpt-4
     - System prompt includes:
       - User writing style
       - KB best practices
       - Success patterns
     - Track which KB entries influenced decision
     
  5. Parse Enhanced Response
     - Type: Code
     - Extract classification
     - Identify used KB entries
     - Check if novel solution
     - Calculate confidence
     
  6. Route by Entity Type
     - Type: Switch
     - Rules:
       - Epic → Create Epic Branch
       - Story → Create Story Branch
       - Task → Create Task Branch
       - Knowledge → Create KB Entry Branch
       - Novel Solution → KB Candidate Branch
       - Archive → Archive Branch
     
  7. Execute Action with Tracking
     - Type: Merge
     - Wait for all branches
     - Collect results
     - Track KB usage effectiveness
     
  8. Bidirectional Learning Update
     - Type: HTTP Request
     - URL: {{$env.N8N_WEBHOOK_URL}}/unified/learn
     - Body: {
         "interaction": completeData,
         "kbUsage": {
           "provided": context.kbEntries,
           "used": response.usedKB,
           "effective": outcome.success
         },
         "novelSolution": response.isNovel
       }
     
  9. Update Inbox Item
     - Type: Notion
     - Mark as processed
     - Add KB entries used
     - Record effectiveness
```

### 3. Bidirectional Learning and KB Update Loop

```yaml
Workflow: bidirectional-learning-loop
Trigger: Webhook (unified-learn)
Nodes:
  1. Webhook Trigger
     - Path: /unified/learn
     - Async processing
     - Accept KB usage data
     
  2. Validate Learning Data
     - Type: Code
     - Check interaction structure
     - Validate KB usage tracking
     - Verify novel solution flag
     
  3. Parallel Learning Updates
     - Type: Split In Batches
     - Branches:
       a) Update Learning Engine
          - Extract user patterns
          - Identify corrections
          - Update preferences
       b) Update KB Effectiveness
          - Track which KB entries used
          - Calculate effectiveness scores
          - Update user-specific metrics
       c) Process Novel Solutions
          - Analyze if KB-worthy
          - Extract solution pattern
          - Prepare KB entry
     
  4. Create/Update KB Entry
     - Type: Conditional
     - If novel solution:
       - Generate title and description
       - Create embeddings
       - Define triggers
       - Store in KB
     - If existing update:
       - Increment usage count
       - Update success rate
       - Add example
     
  5. Update Knowledge Graph
     - Type: Code
     - Add concept relationships
     - Link to KB entries
     - Update embeddings
     - Calculate new weights
     
  6. Propagate Learning
     - Type: Code
     - Update all three systems
     - Ensure consistency
     - Broadcast changes
     
  7. Trigger Intelligence Refresh
     - Type: HTTP Request
     - Invalidate caches
     - Update active contexts
     - Notify workflows
```

---

## 🔐 Security Implementation

### Webhook Authentication
```javascript
// Webhook security configuration
const webhookSecurity = {
  // Generate secure webhook URLs
  generateWebhookUrl: (path) => {
    const token = crypto.randomBytes(32).toString('hex');
    return `${process.env.N8N_WEBHOOK_URL}/${path}?token=${token}`;
  },
  
  // Validate incoming requests
  validateRequest: (req) => {
    const token = req.query.token;
    const signature = req.headers['x-webhook-signature'];
    
    // Token validation
    if (!token || !isValidToken(token)) {
      throw new Error('Invalid token');
    }
    
    // Signature validation
    const payload = JSON.stringify(req.body);
    const expected = crypto
      .createHmac('sha256', process.env.WEBHOOK_SECRET)
      .update(payload)
      .digest('hex');
    
    if (signature !== expected) {
      throw new Error('Invalid signature');
    }
    
    return true;
  }
};
```

### API Key Management
```javascript
// Store API keys securely
const credentials = {
  notion: {
    type: 'notionApi',
    data: {
      apiKey: '{{$credentials.notionApi.apiKey}}'
    }
  },
  openai: {
    type: 'openAiApi',
    data: {
      apiKey: '{{$credentials.openAiApi.apiKey}}'
    }
  },
  supabase: {
    type: 'httpBasicAuth',
    data: {
      user: '{{$credentials.supabase.user}}',
      password: '{{$credentials.supabase.password}}'
    }
  }
};
```

---

## 🚀 Performance Optimization with KB Caching

### Enhanced Caching Strategy
```javascript
// Multi-level caching with KB awareness
const unifiedCacheStrategy = {
  // Memory cache layers
  memory: {
    context: new Map(),    // User contexts
    kb: new Map(),        // KB entries
    embeddings: new Map(), // Vector embeddings
    ttl: {
      context: 300,      // 5 minutes
      kb: 3600,         // 1 hour
      embeddings: 7200  // 2 hours
    },
    maxSize: {
      context: 100,
      kb: 500,
      embeddings: 1000
    }
  },
  
  // Redis cache (shared)
  redis: {
    client: null,
    prefix: {
      context: 'n8n:unified:context:',
      kb: 'n8n:unified:kb:',
      effectiveness: 'n8n:unified:effect:'
    }
  },
  
  // KB-aware cache operations
  getUnifiedContext: async (userId, workflow) => {
    const key = `${workflow}:${userId}`;
    
    // Check memory cache
    const cached = memory.context.get(key);
    if (cached && cached.expires > Date.now()) {
      return cached.data;
    }
    
    // Build unified context
    const [patterns, kbEntries, activeState] = await Promise.all([
      getFromCache('patterns', userId),
      getRelevantKBEntries(userId, workflow),
      getActiveState(userId)
    ]);
    
    const unified = {
      patterns,
      knowledge: kbEntries,
      state: activeState,
      effectiveness: await getKBEffectiveness(userId, kbEntries)
    };
    
    // Cache the unified context
    memory.context.set(key, {
      data: unified,
      expires: Date.now() + memory.ttl.context * 1000
    });
    
    return unified;
  },
  
  // KB similarity search with caching
  searchKBWithCache: async (embedding, threshold = 0.8) => {
    const cacheKey = embedding.slice(0, 10).join(',');
    
    // Check embedding cache
    if (memory.embeddings.has(cacheKey)) {
      return memory.embeddings.get(cacheKey);
    }
    
    // Perform similarity search
    const results = await performVectorSearch(embedding, threshold);
    
    // Cache results
    memory.embeddings.set(cacheKey, results);
    
    return results;
  },
  
  // Invalidate on learning
  invalidateUserCaches: async (userId) => {
    // Clear memory caches
    for (const [key, value] of memory.context) {
      if (key.includes(userId)) {
        memory.context.delete(key);
      }
    }
    
    // Clear Redis caches
    if (redis.client) {
      const keys = await redis.client.keys(`*:${userId}:*`);
      if (keys.length > 0) {
        await redis.client.del(...keys);
      }
    }
  }
};
```

### Batch Processing
```javascript
// Process items in optimal batches
const batchProcessor = {
  // Configuration
  config: {
    batchSize: 10,
    maxConcurrent: 3,
    timeout: 30000
  },
  
  // Process inbox items in batches
  processInboxBatch: async (items) => {
    const batches = [];
    
    // Split into batches
    for (let i = 0; i < items.length; i += config.batchSize) {
      batches.push(items.slice(i, i + config.batchSize));
    }
    
    // Process batches with concurrency limit
    const results = [];
    for (let i = 0; i < batches.length; i += config.maxConcurrent) {
      const batchPromises = batches
        .slice(i, i + config.maxConcurrent)
        .map(batch => processSingleBatch(batch));
      
      const batchResults = await Promise.all(batchPromises);
      results.push(...batchResults);
    }
    
    return results.flat();
  }
};
```

---

## 🛠️ Error Handling System

### Comprehensive Error Recovery
```javascript
// Error handling patterns
const errorHandler = {
  // Retry with exponential backoff
  retryWithBackoff: async (fn, options = {}) => {
    const {
      maxRetries = 3,
      initialDelay = 1000,
      maxDelay = 30000,
      factor = 2
    } = options;
    
    let lastError;
    
    for (let i = 0; i < maxRetries; i++) {
      try {
        return await fn();
      } catch (error) {
        lastError = error;
        
        // Check if retryable
        if (!isRetryableError(error)) {
          throw error;
        }
        
        // Calculate delay
        const delay = Math.min(
          initialDelay * Math.pow(factor, i),
          maxDelay
        );
        
        // Log retry attempt
        console.log(`Retry ${i + 1}/${maxRetries} after ${delay}ms`);
        
        // Wait before retry
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
    
    throw lastError;
  },
  
  // Error classification
  isRetryableError: (error) => {
    const retryableCodes = [429, 500, 502, 503, 504];
    return retryableCodes.includes(error.statusCode) ||
           error.code === 'ECONNRESET' ||
           error.code === 'ETIMEDOUT';
  },
  
  // Fallback strategies
  fallbackStrategies: {
    notion: async (operation, error) => {
      // Use cached data if available
      const cached = await getCachedData(operation);
      if (cached) return cached;
      
      // Return safe default
      return getDefaultResponse(operation);
    },
    
    openai: async (prompt, error) => {
      // Try simpler model
      if (error.statusCode === 429) {
        return await callGPT35(prompt);
      }
      
      // Use rule-based fallback
      return getRuleBasedResponse(prompt);
    }
  }
};
```

### Monitoring and Alerts
```javascript
// System monitoring
const monitoring = {
  // Track workflow health
  healthChecks: {
    checkWorkflowHealth: async () => {
      const checks = {
        apis: await checkAPIConnections(),
        workflows: await checkActiveWorkflows(),
        storage: await checkStorageHealth(),
        performance: await checkPerformanceMetrics()
      };
      
      return {
        healthy: Object.values(checks).every(c => c.healthy),
        checks,
        timestamp: new Date()
      };
    }
  },
  
  // Alert on issues
  alerts: {
    sendAlert: async (issue) => {
      // Log to console
      console.error('System Alert:', issue);
      
      // Send to monitoring service
      if (process.env.MONITORING_WEBHOOK) {
        await fetch(process.env.MONITORING_WEBHOOK, {
          method: 'POST',
          body: JSON.stringify(issue)
        });
      }
      
      // Create Notion task for critical issues
      if (issue.severity === 'critical') {
        await createNotionTask({
          title: `System Alert: ${issue.title}`,
          description: issue.description,
          priority: 'High'
        });
      }
    }
  }
};
```

---

## 📋 Implementation Checklist - Unified Intelligence

### Phase 1: Unified Foundation (Day 1-2)
- [ ] Set up n8n instance with proper environment variables
- [ ] Configure Notion, OpenAI, and Supabase credentials
- [ ] Implement Unified Intelligence Hub workflow
- [ ] Set up enhanced state storage with KB support
- [ ] Create unified API endpoints
- [ ] Test bidirectional data flow

### Phase 2: Core Intelligence Integration (Day 3-5)
- [ ] Implement KB-aware Inbox Processing
- [ ] Create KB entry management workflow
- [ ] Set up Bidirectional Learning Loop
- [ ] Implement KB effectiveness tracking
- [ ] Add embedding generation for similarity search
- [ ] Test with sample KB entries

### Phase 3: Knowledge Base Features (Week 2)
- [ ] Implement vector similarity search
- [ ] Create KB suggestion engine
- [ ] Add novel solution detection
- [ ] Build KB effectiveness dashboard
- [ ] Set up automatic KB curation
- [ ] Performance tune search operations

### Phase 4: Advanced Intelligence (Week 3)
- [ ] Implement predictive context loading
- [ ] Add cross-workflow learning
- [ ] Create team knowledge sharing
- [ ] Set up KB quality metrics
- [ ] Implement feedback loops
- [ ] Document KB best practices

### Phase 5: Production Optimization (Week 4)
- [ ] Migrate to Supabase with pgvector
- [ ] Optimize embedding generation
- [ ] Implement intelligent caching
- [ ] Set up KB backup and versioning
- [ ] Create monitoring dashboards
- [ ] Document unified architecture

---

## 🎯 Success Metrics - Unified Intelligence

### Performance Targets
- Unified context request: < 700ms (includes KB search)
- KB similarity search: < 200ms
- Inbox processing with KB: < 6s per item
- Bidirectional learning update: < 3s
- System availability: > 99.9%

### Intelligence Goals
- Classification accuracy: > 92% (with KB)
- KB hit rate: > 75%
- KB effectiveness score: > 80%
- Novel solution detection: > 60%
- User correction rate: < 8%
- Personalization match: > 88%
- Knowledge relevance: > 85%
- Learning velocity: 1.5x improvement/month

### KB Health Metrics
- Active KB entries: > 100
- KB usage rate: > 70%
- KB contribution rate: > 5 entries/week
- KB deprecation rate: < 2%/month

---

## 🔌 Unified Intelligence API Examples

### Example 1: Inbox Processing with Full Intelligence
```javascript
// Workflow: Process inbox with unified intelligence
const processInboxWithUnified = async (inboxItem) => {
  // 1. Get unified context
  const context = await $http.post('/unified/context', {
    workflow: 'inbox_processing',
    userId: $env.USER_ID,
    input: inboxItem.content,
    keywords: extractKeywords(inboxItem.content),
    includeKB: true,
    depth: 'comprehensive'
  });
  
  // 2. Enhance prompt with all intelligence
  const enhancedPrompt = {
    system: `You are processing an inbox item with full context.
    
    USER PATTERNS: ${JSON.stringify(context.patterns)}
    RELEVANT KB SOLUTIONS: ${context.knowledge.solutions.map(s => 
      `[${s.title}]: ${s.summary} (Success: ${s.successRate}%)`
    ).join('\n')}
    CURRENT WORK CONTEXT: ${JSON.stringify(context.state)}
    
    Classify this item and suggest the best approach based on past successes.`,
    
    user: `Process this inbox item: "${inboxItem.content}"
    Consider the KB solutions provided and indicate which ones apply.`
  };
  
  // 3. Get AI response with KB tracking
  const aiResponse = await callOpenAI(enhancedPrompt);
  
  // 4. Execute and track
  const outcome = await executeAction(aiResponse);
  
  // 5. Update all systems
  await $http.post('/unified/learn', {
    interaction: {
      input: inboxItem,
      context: context,
      aiResponse: aiResponse,
      outcome: outcome
    },
    kbUsage: {
      provided: context.knowledge.ids,
      used: aiResponse.usedKBEntries,
      effectiveness: outcome.success ? 0.9 : 0.3
    },
    novelSolution: aiResponse.isNovelApproach
  });
  
  return outcome;
};
```

### Example 2: Epic Breakdown with Historical Knowledge
```javascript
// Workflow: Generate epic breakdown using KB patterns
const generateEpicBreakdown = async (epic) => {
  // 1. Get unified context for epic creation
  const context = await $http.post('/unified/context', {
    workflow: 'epic_creation',
    userId: $env.USER_ID,
    input: epic,
    searchSimilar: true,
    includeTemplates: true
  });
  
  // 2. Find successful epic patterns
  const successfulPatterns = context.knowledge.entries
    .filter(e => e.type === 'epic_breakdown' && e.successRate > 0.8)
    .sort((a, b) => b.successRate - a.successRate);
  
  // 3. Generate stories using patterns + KB
  const stories = await generateStoriesWithKB({
    epic: epic,
    patterns: context.patterns.epicBreakdown,
    templates: successfulPatterns,
    userStyle: context.patterns.writingStyle,
    currentContext: context.state.activeProjects
  });
  
  // 4. Track what worked
  await $http.post('/unified/learn', {
    interaction: {
      type: 'epic_breakdown',
      input: epic,
      output: stories,
      templatesUsed: successfulPatterns.map(p => p.id)
    }
  });
  
  return stories;
};
```

### Example 3: Knowledge Base Auto-Creation
```javascript
// Workflow: Detect and create KB entries from novel solutions
const processNovelSolution = async (interaction) => {
  // Analyze if this is KB-worthy
  const analysis = await analyzeForKnowledge(interaction);
  
  if (analysis.isNovel && analysis.confidence > 0.8) {
    // Create KB entry
    const kbEntry = {
      title: generateTitle(interaction),
      type: analysis.solutionType,
      content: {
        problem: interaction.input,
        solution: interaction.outcome.solution,
        steps: extractSteps(interaction),
        context: interaction.context
      },
      metadata: {
        workflow: interaction.workflow,
        successMetrics: interaction.outcome.metrics,
        createdFrom: 'learning_loop'
      },
      embeddings: await generateEmbeddings(interaction),
      triggers: {
        keywords: extractKeywords(interaction),
        patterns: extractPatterns(interaction),
        contexts: [interaction.workflow]
      }
    };
    
    // Store in KB
    const kbId = await $supabase
      .from('knowledge_base')
      .insert(kbEntry)
      .select('id')
      .single();
    
    // Link to user's effectiveness tracking
    await $supabase
      .from('kb_effectiveness')
      .insert({
        user_id: interaction.userId,
        kb_entry_id: kbId,
        initial_confidence: analysis.confidence
      });
    
    return kbId;
  }
};
```

---

## 🎨 Architecture Benefits

### Unified Intelligence Advantages
1. **Compound Learning**: Every interaction improves all future interactions
2. **Active Knowledge**: KB actively participates in decisions, not just storage
3. **Personalized Intelligence**: System adapts to each user's unique patterns
4. **Reduced Redundancy**: Learn once, apply everywhere
5. **Continuous Improvement**: Bidirectional updates ensure constant evolution

### Technical Benefits
1. **Single API**: One interface for all intelligence needs
2. **Optimized Performance**: Intelligent caching and parallel processing
3. **Scalable Architecture**: Can grow from single user to enterprise
4. **Maintainable Code**: Clear separation of concerns
5. **Observable System**: Built-in metrics and monitoring

---

This enhanced blueprint provides a production-ready implementation of the Unified Intelligence Layer, creating a truly intelligent system where Context Management, Learning Engine, and Knowledge Base work together seamlessly to provide ever-improving personalization and assistance.