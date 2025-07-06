# State Management Solution for n8n Context Storage - Enhanced with Knowledge Graph

**Version: 2.0** | **Last Updated: 2024-01-03**

## Overview
This document provides a comprehensive state management solution for storing and managing personalization context, Knowledge Base integration, and Knowledge Graph in the AI-Augmented Notion PMS. It includes enhanced schemas that support the bidirectional flow between Context Management, Learning Engine, and Knowledge Base.

---

## 🗄️ Storage Architecture Options

### Option 1: n8n Static Data (Quick Start)
Best for: Development, testing, and small-scale deployments

### Option 2: Supabase (Recommended Production)
Best for: Production deployments with multiple users

### Option 3: Redis + PostgreSQL (Enterprise)
Best for: High-performance, large-scale deployments

---

## 📦 Option 1: n8n Static Data Implementation

### Enhanced Schema Design with Knowledge Base
```javascript
// Enhanced global state structure with KB integration
const enhancedGlobalState = {
  // User contexts indexed by user ID
  userContexts: {
    "user_123": {
      // Core personalization data
      preferences: {
        writingStyle: {
          tone: "professional",
          formality: "medium",
          sentenceLength: "medium",
          vocabulary: ["implement", "analyze", "optimize"]
        },
        formatting: {
          listStyle: "numbered",
          headerStyle: "title-case",
          detailLevel: "comprehensive"
        }
      },
      
      // Learned patterns
      patterns: {
        taskBreakdown: {
          averageSubtasks: 5,
          namingConvention: "verb-noun",
          detailLevel: "high"
        },
        prioritization: {
          method: "eisenhower",
          defaultPriority: "medium",
          factors: ["deadline", "impact", "effort"]
        },
        estimation: {
          unit: "hours",
          bufferPercentage: 20,
          accuracy: 0.85
        }
      },
      
      // Enhanced interaction history with KB tracking
      history: [
        {
          timestamp: "2024-01-01T10:00:00Z",
          workflow: "inbox_processing",
          input: "Create API documentation",
          aiSuggestion: "task",
          userAction: "accepted",
          modifications: null,
          confidence: 0.92,
          kbUsage: {
            provided: ["kb_123", "kb_456"],
            used: ["kb_123"],
            effectiveness: { "kb_123": 0.9 }
          }
        }
      ],
      
      // Enhanced knowledge graph with KB links
      knowledge: {
        concepts: {
          "api_development": {
            frequency: 15,
            relatedConcepts: ["rest", "graphql", "documentation"],
            lastSeen: "2024-01-01T10:00:00Z",
            kbEntries: ["kb_123", "kb_789"], // KB entries for this concept
            embeddings: [0.23, -0.45, ...] // For similarity search
          }
        },
        relationships: {
          "api_development->documentation": {
            strength: 0.8,
            type: "requires",
            kbSupport: ["kb_456"], // KB entries supporting this relationship
            learnedFrom: ["interaction_234"]
          }
        },
        kbEffectiveness: {
          "kb_123": {
            timesProvided: 45,
            timesUsed: 38,
            averageEffectiveness: 0.85,
            lastUsed: "2024-01-01T10:00:00Z"
          }
        }
      },
      
      // Metadata
      metadata: {
        created: "2023-12-01T00:00:00Z",
        lastUpdated: "2024-01-01T10:00:00Z",
        version: "2.0",
        interactionCount: 150,
        kbEntriesCreated: 12,
        patternsLearned: 34
      }
    }
  },
  
  // Knowledge Base entries (cached locally)
  knowledgeBase: {
    "kb_123": {
      id: "kb_123",
      title: "API Documentation Best Practices",
      type: "pattern",
      content: {
        description: "Standard approach for documenting REST APIs",
        implementation: "1. Use OpenAPI spec\n2. Include examples\n3. Document errors",
        tags: ["api", "documentation", "rest"]
      },
      metadata: {
        createdFrom: "learning_loop",
        sourceInteraction: "interaction_123",
        successRate: 0.92,
        usageCount: 38,
        lastUpdated: "2024-01-01T10:00:00Z"
      },
      embeddings: [0.12, -0.34, ...], // For similarity search
      triggers: {
        keywords: ["api", "documentation", "rest"],
        patterns: ["create.*api.*doc", "document.*endpoint"],
        contexts: ["development", "api_work"]
      }
    }
  },
  
  // Bidirectional learning queue
  learningQueue: [
    {
      type: "pattern_extraction",
      data: { /* interaction data */ },
      priority: "high"
    },
    {
      type: "kb_effectiveness_update",
      data: { /* kb usage data */ },
      priority: "medium"
    }
  ],
  
  // Enhanced system statistics
  systemStats: {
    totalInteractions: 1500,
    averageResponseTime: 450,
    successRate: 0.92,
    kbHitRate: 0.78,
    patternAccuracy: 0.89,
    learningVelocity: 1.2
  }
};
```

### Enhanced Implementation with KB Integration
```javascript
// Enhanced Context Storage Manager with Knowledge Base
class UnifiedContextStorageManager {
  constructor() {
    this.storageKey = 'global';
    this.kbSimilarityThreshold = 0.8;
  }
  
  // Initialize storage
  async initialize() {
    const data = $getWorkflowStaticData(this.storageKey);
    
    if (!data.initialized) {
      data.userContexts = {};
      data.learningQueue = [];
      data.systemStats = {
        totalInteractions: 0,
        averageResponseTime: 0,
        successRate: 0
      };
      data.initialized = true;
      data.version = '1.0';
    }
    
    return data;
  }
  
  // Get user context
  async getUserContext(userId) {
    const data = $getWorkflowStaticData(this.storageKey);
    
    if (!data.userContexts[userId]) {
      data.userContexts[userId] = this.createDefaultUserContext(userId);
    }
    
    return data.userContexts[userId];
  }
  
  // Update user context
  async updateUserContext(userId, updates) {
    const data = $getWorkflowStaticData(this.storageKey);
    const context = data.userContexts[userId];
    
    // Merge updates
    Object.keys(updates).forEach(key => {
      if (typeof updates[key] === 'object' && !Array.isArray(updates[key])) {
        context[key] = { ...context[key], ...updates[key] };
      } else {
        context[key] = updates[key];
      }
    });
    
    // Update metadata
    context.metadata.lastUpdated = new Date().toISOString();
    
    return context;
  }
  
  // Add interaction to history
  async addInteraction(userId, interaction) {
    const data = $getWorkflowStaticData(this.storageKey);
    const context = data.userContexts[userId];
    
    // Add to history
    context.history.unshift(interaction);
    
    // Keep only last 100 interactions
    if (context.history.length > 100) {
      context.history = context.history.slice(0, 100);
    }
    
    // Update stats
    context.metadata.interactionCount++;
    context.metadata.lastUpdated = new Date().toISOString();
    
    return context;
  }
  
  // Create default user context
  createDefaultUserContext(userId) {
    return {
      preferences: {
        writingStyle: {
          tone: "professional",
          formality: "medium",
          sentenceLength: "medium",
          vocabulary: []
        },
        formatting: {
          listStyle: "bullet",
          headerStyle: "sentence-case",
          detailLevel: "moderate"
        }
      },
      patterns: {
        taskBreakdown: {},
        prioritization: {},
        estimation: {}
      },
      history: [],
      knowledge: {
        concepts: {},
        relationships: {},
        kbEffectiveness: {} // Track KB entry effectiveness
      },
      metadata: {
        created: new Date().toISOString(),
        lastUpdated: new Date().toISOString(),
        version: "2.0",
        interactionCount: 0,
        kbEntriesCreated: 0,
        patternsLearned: 0
      }
    };
  }
  
  // NEW: Knowledge Base methods
  async searchKnowledgeBase(query, userId) {
    const data = $getWorkflowStaticData(this.storageKey);
    const kb = data.knowledgeBase || {};
    const userContext = data.userContexts[userId];
    
    // Text search
    const textMatches = Object.values(kb).filter(entry => {
      const searchText = `${entry.title} ${entry.content.description}`.toLowerCase();
      return query.keywords.some(keyword => searchText.includes(keyword.toLowerCase()));
    });
    
    // Pattern search
    const patternMatches = Object.values(kb).filter(entry => {
      return entry.triggers.patterns.some(pattern => 
        new RegExp(pattern, 'i').test(query.text)
      );
    });
    
    // Context-based filtering
    const contextRelevant = [...new Set([...textMatches, ...patternMatches])].filter(entry => {
      return entry.triggers.contexts.some(context => 
        query.contexts.includes(context)
      );
    });
    
    // Rank by effectiveness for this user
    const ranked = contextRelevant.sort((a, b) => {
      const aEffectiveness = userContext.knowledge.kbEffectiveness[a.id]?.averageEffectiveness || 0.5;
      const bEffectiveness = userContext.knowledge.kbEffectiveness[b.id]?.averageEffectiveness || 0.5;
      return bEffectiveness - aEffectiveness;
    });
    
    return ranked.slice(0, 10); // Return top 10
  }
  
  // Create new KB entry from interaction
  async createKBEntry(userId, entry) {
    const data = $getWorkflowStaticData(this.storageKey);
    
    if (!data.knowledgeBase) {
      data.knowledgeBase = {};
    }
    
    const kbId = `kb_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    data.knowledgeBase[kbId] = {
      id: kbId,
      ...entry,
      metadata: {
        ...entry.metadata,
        createdAt: new Date().toISOString(),
        createdBy: userId
      }
    };
    
    // Update user metadata
    data.userContexts[userId].metadata.kbEntriesCreated++;
    
    return kbId;
  }
  
  // Update KB effectiveness based on usage
  async updateKBEffectiveness(userId, kbId, usage) {
    const data = $getWorkflowStaticData(this.storageKey);
    const userContext = data.userContexts[userId];
    
    if (!userContext.knowledge.kbEffectiveness[kbId]) {
      userContext.knowledge.kbEffectiveness[kbId] = {
        timesProvided: 0,
        timesUsed: 0,
        totalEffectiveness: 0,
        averageEffectiveness: 0,
        lastUsed: null
      };
    }
    
    const stats = userContext.knowledge.kbEffectiveness[kbId];
    stats.timesProvided++;
    
    if (usage.used) {
      stats.timesUsed++;
      stats.totalEffectiveness += usage.effectiveness;
      stats.averageEffectiveness = stats.totalEffectiveness / stats.timesUsed;
      stats.lastUsed = new Date().toISOString();
    }
    
    // Update global KB stats
    if (data.knowledgeBase[kbId]) {
      data.knowledgeBase[kbId].metadata.usageCount = stats.timesUsed;
      data.knowledgeBase[kbId].metadata.successRate = stats.averageEffectiveness;
    }
  }
  
  // Get unified context with KB
  async getUnifiedContext(userId) {
    const data = $getWorkflowStaticData(this.storageKey);
    const userContext = await this.getUserContext(userId);
    
    // Get most effective KB entries for this user
    const effectiveKBEntries = Object.entries(userContext.knowledge.kbEffectiveness)
      .filter(([_, stats]) => stats.averageEffectiveness > 0.7)
      .sort((a, b) => b[1].averageEffectiveness - a[1].averageEffectiveness)
      .slice(0, 5)
      .map(([kbId, _]) => data.knowledgeBase[kbId])
      .filter(Boolean);
    
    return {
      ...userContext,
      topKBEntries: effectiveKBEntries,
      kbStats: {
        totalEntries: Object.keys(data.knowledgeBase || {}).length,
        userSpecificEffectiveness: this.calculateUserKBStats(userContext)
      }
    };
  }
  
  // Calculate user-specific KB statistics
  calculateUserKBStats(userContext) {
    const effectiveness = Object.values(userContext.knowledge.kbEffectiveness);
    
    if (effectiveness.length === 0) {
      return { hitRate: 0, averageEffectiveness: 0 };
    }
    
    const totalProvided = effectiveness.reduce((sum, e) => sum + e.timesProvided, 0);
    const totalUsed = effectiveness.reduce((sum, e) => sum + e.timesUsed, 0);
    
    return {
      hitRate: totalUsed / totalProvided,
      averageEffectiveness: effectiveness.reduce((sum, e) => 
        sum + (e.averageEffectiveness * e.timesUsed), 0) / totalUsed
    };
  }
}

// Enhanced usage in n8n with KB integration
const storage = new UnifiedContextStorageManager();

// Get unified context with KB
const context = await storage.getUnifiedContext($json.user_id);

// Search KB for relevant entries
const kbResults = await storage.searchKnowledgeBase({
  keywords: ['api', 'documentation'],
  text: $json.input_text,
  contexts: ['development']
}, $json.user_id);

// Track KB usage after interaction
if ($json.kb_usage) {
  for (const [kbId, usage] of Object.entries($json.kb_usage)) {
    await storage.updateKBEffectiveness($json.user_id, kbId, usage);
  }
}

return { 
  context,
  kbSuggestions: kbResults
};
```

---

## 🚀 Option 2: Supabase Implementation (Production)

### Enhanced Database Schema with Knowledge Base
```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  external_id TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User preferences
CREATE TABLE user_preferences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  preference_type TEXT NOT NULL,
  preferences JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, preference_type)
);

-- User patterns
CREATE TABLE user_patterns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  pattern_type TEXT NOT NULL,
  pattern_data JSONB NOT NULL,
  confidence FLOAT DEFAULT 0.5,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enhanced interaction history with KB tracking
CREATE TABLE interaction_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  workflow TEXT NOT NULL,
  input_data JSONB NOT NULL,
  ai_response JSONB NOT NULL,
  user_action JSONB NOT NULL,
  outcome JSONB NOT NULL,
  kb_usage JSONB, -- Track which KB entries were provided/used
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Knowledge Base entries
CREATE TABLE knowledge_base (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  type TEXT NOT NULL, -- pattern, solution, lesson, reference
  content JSONB NOT NULL,
  metadata JSONB NOT NULL,
  embeddings VECTOR(1536), -- For similarity search (using pgvector)
  triggers JSONB, -- Keywords, patterns, contexts
  created_by UUID REFERENCES users(id),
  created_from TEXT, -- learning_loop, manual, import
  source_interaction UUID REFERENCES interaction_history(id),
  success_rate FLOAT DEFAULT 0.5,
  usage_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User-specific KB effectiveness tracking
CREATE TABLE kb_effectiveness (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  kb_entry_id UUID REFERENCES knowledge_base(id) ON DELETE CASCADE,
  times_provided INTEGER DEFAULT 0,
  times_used INTEGER DEFAULT 0,
  total_effectiveness FLOAT DEFAULT 0,
  average_effectiveness FLOAT DEFAULT 0,
  last_used TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, kb_entry_id)
);

-- Enhanced knowledge graph with KB links
CREATE TABLE knowledge_concepts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  concept TEXT NOT NULL,
  frequency INTEGER DEFAULT 1,
  metadata JSONB,
  kb_entries UUID[], -- Array of related KB entry IDs
  embeddings VECTOR(1536), -- Concept embeddings
  last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, concept)
);

-- Knowledge relationships with KB support
CREATE TABLE knowledge_relationships (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  source_concept_id UUID REFERENCES knowledge_concepts(id) ON DELETE CASCADE,
  target_concept_id UUID REFERENCES knowledge_concepts(id) ON DELETE CASCADE,
  relationship_type TEXT NOT NULL,
  strength FLOAT DEFAULT 0.5,
  kb_support UUID[], -- KB entries supporting this relationship
  learned_from UUID[], -- Interaction IDs where this was learned
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(source_concept_id, target_concept_id, relationship_type)
);

-- Enhanced learning queue
CREATE TABLE learning_queue (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  learning_type TEXT NOT NULL, -- pattern_extraction, kb_update, effectiveness_update
  learning_data JSONB NOT NULL,
  priority TEXT DEFAULT 'medium',
  processed BOOLEAN DEFAULT FALSE,
  processed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_interaction_history_user_workflow ON interaction_history(user_id, workflow, created_at DESC);
CREATE INDEX idx_knowledge_concepts_user ON knowledge_concepts(user_id, concept);
CREATE INDEX idx_learning_queue_unprocessed ON learning_queue(processed, created_at) WHERE processed = FALSE;

-- New indexes for KB integration
CREATE INDEX idx_kb_embeddings ON knowledge_base USING ivfflat (embeddings vector_cosine_ops);
CREATE INDEX idx_kb_type_success ON knowledge_base(type, success_rate DESC);
CREATE INDEX idx_kb_effectiveness_user ON kb_effectiveness(user_id, average_effectiveness DESC);
CREATE INDEX idx_concepts_embeddings ON knowledge_concepts USING ivfflat (embeddings vector_cosine_ops);

-- RLS Policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE interaction_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_concepts ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_queue ENABLE ROW LEVEL SECURITY;
```

### Supabase Integration in n8n
```javascript
// Supabase Context Storage Implementation
class SupabaseContextStorage {
  constructor(supabaseUrl, supabaseKey) {
    this.supabaseUrl = supabaseUrl;
    this.headers = {
      'apikey': supabaseKey,
      'Authorization': `Bearer ${supabaseKey}`,
      'Content-Type': 'application/json'
    };
  }
  
  // Get or create user
  async ensureUser(externalId) {
    // Check if user exists
    const checkUrl = `${this.supabaseUrl}/rest/v1/users?external_id=eq.${externalId}`;
    const checkResponse = await $http.request({
      method: 'GET',
      url: checkUrl,
      headers: this.headers
    });
    
    if (checkResponse.length > 0) {
      return checkResponse[0];
    }
    
    // Create new user
    const createUrl = `${this.supabaseUrl}/rest/v1/users`;
    const createResponse = await $http.request({
      method: 'POST',
      url: createUrl,
      headers: this.headers,
      body: JSON.stringify({ external_id: externalId })
    });
    
    return createResponse[0];
  }
  
  // Get complete user context
  async getUserContext(externalId) {
    const user = await this.ensureUser(externalId);
    
    // Fetch all related data in parallel
    const [preferences, patterns, recentHistory, concepts] = await Promise.all([
      this.getUserPreferences(user.id),
      this.getUserPatterns(user.id),
      this.getRecentHistory(user.id, 50),
      this.getKnowledgeConcepts(user.id)
    ]);
    
    return {
      userId: user.id,
      externalId: externalId,
      preferences: this.structurePreferences(preferences),
      patterns: this.structurePatterns(patterns),
      history: recentHistory,
      knowledge: {
        concepts: this.structureConcepts(concepts)
      },
      metadata: {
        created: user.created_at,
        lastUpdated: user.updated_at
      }
    };
  }
  
  // Get user preferences
  async getUserPreferences(userId) {
    const url = `${this.supabaseUrl}/rest/v1/user_preferences?user_id=eq.${userId}`;
    return await $http.request({
      method: 'GET',
      url: url,
      headers: this.headers
    });
  }
  
  // Get user patterns
  async getUserPatterns(userId) {
    const url = `${this.supabaseUrl}/rest/v1/user_patterns?user_id=eq.${userId}&order=confidence.desc`;
    return await $http.request({
      method: 'GET',
      url: url,
      headers: this.headers
    });
  }
  
  // Get recent interaction history
  async getRecentHistory(userId, limit = 50) {
    const url = `${this.supabaseUrl}/rest/v1/interaction_history?user_id=eq.${userId}&order=created_at.desc&limit=${limit}`;
    return await $http.request({
      method: 'GET',
      url: url,
      headers: this.headers
    });
  }
  
  // Get knowledge concepts
  async getKnowledgeConcepts(userId) {
    const url = `${this.supabaseUrl}/rest/v1/knowledge_concepts?user_id=eq.${userId}&order=frequency.desc`;
    return await $http.request({
      method: 'GET',
      url: url,
      headers: this.headers
    });
  }
  
  // Add interaction
  async addInteraction(externalId, interaction) {
    const user = await this.ensureUser(externalId);
    
    const url = `${this.supabaseUrl}/rest/v1/interaction_history`;
    const response = await $http.request({
      method: 'POST',
      url: url,
      headers: this.headers,
      body: JSON.stringify({
        user_id: user.id,
        workflow: interaction.workflow,
        input_data: interaction.input,
        ai_response: interaction.ai_response,
        user_action: interaction.user_action,
        outcome: interaction.outcome
      })
    });
    
    // Queue for learning
    await this.queueForLearning(user.id, interaction);
    
    return response[0];
  }
  
  // Queue interaction for learning
  async queueForLearning(userId, interaction) {
    const url = `${this.supabaseUrl}/rest/v1/learning_queue`;
    return await $http.request({
      method: 'POST',
      url: url,
      headers: this.headers,
      body: JSON.stringify({
        user_id: userId,
        learning_data: interaction
      })
    });
  }
  
  // Structure preferences for use
  structurePreferences(prefs) {
    const structured = {};
    prefs.forEach(pref => {
      structured[pref.preference_type] = pref.preferences;
    });
    return structured;
  }
  
  // Structure patterns for use
  structurePatterns(patterns) {
    const structured = {};
    patterns.forEach(pattern => {
      if (!structured[pattern.pattern_type]) {
        structured[pattern.pattern_type] = [];
      }
      structured[pattern.pattern_type].push({
        data: pattern.pattern_data,
        confidence: pattern.confidence
      });
    });
    return structured;
  }
  
  // Structure concepts for use
  structureConcepts(concepts) {
    const structured = {};
    concepts.forEach(concept => {
      structured[concept.concept] = {
        frequency: concept.frequency,
        metadata: concept.metadata,
        lastSeen: concept.last_seen
      };
    });
    return structured;
  }
}

// Usage in n8n
const storage = new SupabaseContextStorage(
  $env.SUPABASE_URL,
  $env.SUPABASE_ANON_KEY
);

const context = await storage.getUserContext($json.user_id);
return { context };
```

---

## ⚡ Option 3: Redis + PostgreSQL (Enterprise)

### Redis Schema Design
```javascript
// Redis key patterns
const redisSchema = {
  // User context cache (TTL: 5 minutes)
  userContext: "context:{userId}",
  
  // Active sessions (TTL: 30 minutes)
  userSession: "session:{userId}:{sessionId}",
  
  // Workflow state (TTL: 1 hour)
  workflowState: "workflow:{workflowId}:state",
  
  // Learning queue (List)
  learningQueue: "queue:learning",
  
  // Real-time analytics (Sorted Set)
  analytics: {
    responseTime: "analytics:response_time",
    successRate: "analytics:success_rate",
    activeUsers: "analytics:active_users"
  },
  
  // Pattern cache (TTL: 1 hour)
  patternCache: "patterns:{userId}:{patternType}",
  
  // Knowledge graph cache
  knowledgeCache: "knowledge:{userId}:concepts"
};
```

### Redis Implementation
```javascript
// Redis Context Manager
class RedisContextManager {
  constructor(redisClient, pgClient) {
    this.redis = redisClient;
    this.pg = pgClient;
    this.ttl = {
      context: 300,      // 5 minutes
      session: 1800,     // 30 minutes
      pattern: 3600,     // 1 hour
      knowledge: 3600    // 1 hour
    };
  }
  
  // Get user context with caching
  async getUserContext(userId) {
    const cacheKey = `context:${userId}`;
    
    // Try cache first
    const cached = await this.redis.get(cacheKey);
    if (cached) {
      return JSON.parse(cached);
    }
    
    // Load from PostgreSQL
    const context = await this.loadContextFromDB(userId);
    
    // Cache it
    await this.redis.setex(
      cacheKey,
      this.ttl.context,
      JSON.stringify(context)
    );
    
    return context;
  }
  
  // Load context from PostgreSQL
  async loadContextFromDB(userId) {
    const queries = {
      preferences: `
        SELECT preference_type, preferences
        FROM user_preferences
        WHERE user_id = $1
      `,
      patterns: `
        SELECT pattern_type, pattern_data, confidence
        FROM user_patterns
        WHERE user_id = $1
        ORDER BY confidence DESC
      `,
      recentHistory: `
        SELECT workflow, input_data, ai_response, user_action, outcome, created_at
        FROM interaction_history
        WHERE user_id = $1
        ORDER BY created_at DESC
        LIMIT 50
      `,
      concepts: `
        SELECT concept, frequency, metadata, last_seen
        FROM knowledge_concepts
        WHERE user_id = $1
        ORDER BY frequency DESC
        LIMIT 100
      `
    };
    
    const [preferences, patterns, history, concepts] = await Promise.all([
      this.pg.query(queries.preferences, [userId]),
      this.pg.query(queries.patterns, [userId]),
      this.pg.query(queries.recentHistory, [userId]),
      this.pg.query(queries.concepts, [userId])
    ]);
    
    return {
      userId,
      preferences: this.structurePreferences(preferences.rows),
      patterns: this.structurePatterns(patterns.rows),
      history: history.rows,
      knowledge: {
        concepts: this.structureConcepts(concepts.rows)
      }
    };
  }
  
  // Invalidate cache
  async invalidateCache(userId) {
    const keys = [
      `context:${userId}`,
      `patterns:${userId}:*`,
      `knowledge:${userId}:*`
    ];
    
    for (const pattern of keys) {
      if (pattern.includes('*')) {
        // Get all matching keys
        const matchingKeys = await this.redis.keys(pattern);
        if (matchingKeys.length > 0) {
          await this.redis.del(...matchingKeys);
        }
      } else {
        await this.redis.del(pattern);
      }
    }
  }
  
  // Track real-time metrics
  async trackMetric(metric, value) {
    const timestamp = Date.now();
    const key = `analytics:${metric}`;
    
    // Add to sorted set with timestamp as score
    await this.redis.zadd(key, timestamp, JSON.stringify({
      value,
      timestamp
    }));
    
    // Remove old entries (keep last hour)
    const oneHourAgo = timestamp - 3600000;
    await this.redis.zremrangebyscore(key, '-inf', oneHourAgo);
  }
  
  // Get analytics
  async getAnalytics(metric, timeRange = 3600000) {
    const key = `analytics:${metric}`;
    const now = Date.now();
    const start = now - timeRange;
    
    const data = await this.redis.zrangebyscore(key, start, now);
    return data.map(item => JSON.parse(item));
  }
  
  // Session management
  async createSession(userId, sessionData) {
    const sessionId = crypto.randomUUID();
    const key = `session:${userId}:${sessionId}`;
    
    await this.redis.setex(
      key,
      this.ttl.session,
      JSON.stringify({
        ...sessionData,
        created: new Date().toISOString()
      })
    );
    
    return sessionId;
  }
  
  // Learning queue management
  async queueLearning(userId, learningData) {
    const item = {
      userId,
      data: learningData,
      timestamp: new Date().toISOString()
    };
    
    await this.redis.lpush(
      'queue:learning',
      JSON.stringify(item)
    );
  }
  
  // Process learning queue
  async processLearningQueue(batchSize = 10) {
    const items = [];
    
    for (let i = 0; i < batchSize; i++) {
      const item = await this.redis.rpop('queue:learning');
      if (!item) break;
      items.push(JSON.parse(item));
    }
    
    return items;
  }
}

// Usage in n8n with Redis
const redis = new Redis({
  host: $env.REDIS_HOST,
  port: $env.REDIS_PORT,
  password: $env.REDIS_PASSWORD
});

const pg = new Pool({
  host: $env.PG_HOST,
  database: $env.PG_DATABASE,
  user: $env.PG_USER,
  password: $env.PG_PASSWORD
});

const contextManager = new RedisContextManager(redis, pg);
const context = await contextManager.getUserContext($json.user_id);

// Track metrics
await contextManager.trackMetric('response_time', Date.now() - startTime);

return { context };
```

---

## 🔄 Migration Paths

### From Static Data to Supabase
```javascript
// Migration script
async function migrateToSupabase() {
  const staticData = $getWorkflowStaticData('global');
  const supabase = new SupabaseContextStorage($env.SUPABASE_URL, $env.SUPABASE_KEY);
  
  for (const [externalId, context] of Object.entries(staticData.userContexts)) {
    // Ensure user exists
    const user = await supabase.ensureUser(externalId);
    
    // Migrate preferences
    for (const [type, prefs] of Object.entries(context.preferences)) {
      await supabase.upsertPreference(user.id, type, prefs);
    }
    
    // Migrate patterns
    for (const [type, patterns] of Object.entries(context.patterns)) {
      await supabase.upsertPattern(user.id, type, patterns);
    }
    
    // Migrate history
    for (const interaction of context.history) {
      await supabase.addInteraction(externalId, interaction);
    }
    
    console.log(`Migrated user: ${externalId}`);
  }
}
```

### From Supabase to Redis+PostgreSQL
```javascript
// High-performance migration
async function migrateToRedis() {
  const supabase = new SupabaseContextStorage($env.SUPABASE_URL, $env.SUPABASE_KEY);
  const redis = new RedisContextManager(redisClient, pgClient);
  
  // Get all users
  const users = await supabase.getAllUsers();
  
  for (const user of users) {
    const context = await supabase.getUserContext(user.external_id);
    
    // Warm Redis cache
    await redis.setUserContext(user.external_id, context);
    
    // Set up real-time sync
    await redis.enableRealtimeSync(user.external_id);
  }
}
```

---

## 📊 Performance Comparison

| Feature | Static Data | Supabase | Redis+PostgreSQL |
|---------|------------|----------|------------------|
| Setup Complexity | Low | Medium | High |
| Scalability | Limited | Good | Excellent |
| Query Performance | Good | Good | Excellent |
| Real-time Updates | Limited | Good | Excellent |
| Cost | Free | Low-Medium | Medium-High |
| Maintenance | Low | Medium | High |
| Data Persistence | File-based | Cloud DB | Hybrid |
| Backup/Recovery | Manual | Automatic | Configurable |

---

## 🎯 Choosing the Right Solution

### Use Static Data When:
- Starting development
- Single user or small team
- Simple deployment requirements
- Cost is primary concern

### Use Supabase When:
- Multiple users
- Need persistent storage
- Want managed database
- Require auth and RLS

### Use Redis+PostgreSQL When:
- High performance critical
- Large scale deployment
- Complex caching needs
- Enterprise requirements

---

This comprehensive state management solution provides clear paths from development to production, ensuring your AI-Augmented Notion PMS can scale with your needs.