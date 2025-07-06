# API Design Standards for n8n Workflows

## Overview
This document defines consistent API request/response formats for all webhook communications in the AI-Augmented Notion PMS. Following these standards ensures reliable integration between workflows and simplifies debugging.

---

## 🎯 Core Principles

1. **Consistency** - Same patterns across all endpoints
2. **Versioning** - Support for API evolution
3. **Error Handling** - Predictable error responses
4. **Metadata** - Rich context in every exchange
5. **Security** - Built-in authentication patterns

---

## 📋 Standard Request Format

### Base Request Structure
```typescript
interface BaseRequest {
  // Request metadata
  metadata: {
    requestId: string;        // UUID for tracking
    timestamp: string;        // ISO 8601 format
    version: string;          // API version (e.g., "2.0")
    source: {
      workflow: string;       // Calling workflow name
      executionId: string;    // n8n execution ID
      userId: string;         // User identifier
      sessionId?: string;     // Optional session tracking
    };
  };
  
  // Authentication
  auth: {
    method: "header" | "token" | "signature";
    credentials: string;      // Based on method
  };
  
  // Request data
  data: any;                  // Specific to endpoint
  
  // Request options
  options?: {
    timeout?: number;         // Request timeout in ms
    priority?: "low" | "normal" | "high";
    returnFormat?: "full" | "summary" | "minimal";
  };
}
```

### Example Requests

#### Context Request
```json
{
  "metadata": {
    "requestId": "550e8400-e29b-41d4-a716-446655440000",
    "timestamp": "2024-01-01T10:00:00.000Z",
    "version": "2.0",
    "source": {
      "workflow": "intelligent_inbox_processing",
      "executionId": "12345",
      "userId": "user_123",
      "sessionId": "session_456"
    }
  },
  "auth": {
    "method": "signature",
    "credentials": "sha256:a1b2c3d4e5..."
  },
  "data": {
    "contextType": "inbox_processing",
    "currentInput": {
      "text": "Create API documentation for new endpoints",
      "metadata": {
        "source": "inbox",
        "capturedAt": "2024-01-01T09:55:00.000Z"
      }
    },
    "activeWork": {
      "projects": ["proj_123", "proj_456"],
      "epics": ["epic_789"],
      "recentTasks": ["task_abc", "task_def"]
    }
  },
  "options": {
    "timeout": 5000,
    "priority": "normal",
    "returnFormat": "full"
  }
}
```

#### Learning Capture Request
```json
{
  "metadata": {
    "requestId": "660e8400-e29b-41d4-a716-446655440001",
    "timestamp": "2024-01-01T10:05:00.000Z",
    "version": "2.0",
    "source": {
      "workflow": "intelligent_inbox_processing",
      "executionId": "12346",
      "userId": "user_123"
    }
  },
  "auth": {
    "method": "header",
    "credentials": "Bearer token123..."
  },
  "data": {
    "interaction": {
      "type": "classification",
      "startTime": "2024-01-01T10:00:00.000Z",
      "endTime": "2024-01-01T10:04:50.000Z"
    },
    "input": {
      "raw": "Create API documentation",
      "processed": {
        "tokens": 3,
        "entities": ["API", "documentation"]
      }
    },
    "aiSuggestion": {
      "classification": "task",
      "confidence": 0.92,
      "reasoning": "Action verb 'Create' with technical object",
      "properties": {
        "title": "Create API documentation",
        "priority": "Medium",
        "estimation": 4
      }
    },
    "userAction": {
      "decision": "modified",
      "changes": {
        "title": "Write comprehensive API docs",
        "priority": "High"
      },
      "timeToDecision": 3500
    },
    "outcome": {
      "success": true,
      "entityCreated": {
        "type": "task",
        "id": "task_new_123"
      }
    }
  }
}
```

---

## 📤 Standard Response Format

### Base Response Structure
```typescript
interface BaseResponse {
  // Response metadata
  metadata: {
    requestId: string;        // Echo from request
    responseId: string;       // Unique response ID
    timestamp: string;        // Response generation time
    version: string;          // API version
    processingTime: number;   // Time taken in ms
  };
  
  // Response status
  status: {
    code: number;            // HTTP-style status code
    success: boolean;        // Quick success check
    message: string;         // Human-readable status
  };
  
  // Response data
  data?: any;               // Successful response data
  
  // Error information
  error?: {
    code: string;           // Machine-readable error code
    message: string;        // User-friendly message
    details?: any;          // Additional error context
    suggestion?: string;    // How to fix the error
  };
  
  // Pagination (if applicable)
  pagination?: {
    total: number;
    limit: number;
    offset: number;
    hasMore: boolean;
  };
  
  // Debug information (development only)
  debug?: {
    workflow: string;
    node: string;
    logs: string[];
  };
}
```

### Example Responses

#### Successful Context Response
```json
{
  "metadata": {
    "requestId": "550e8400-e29b-41d4-a716-446655440000",
    "responseId": "770e8400-e29b-41d4-a716-446655440002",
    "timestamp": "2024-01-01T10:00:00.500Z",
    "version": "2.0",
    "processingTime": 450
  },
  "status": {
    "code": 200,
    "success": true,
    "message": "Context retrieved successfully"
  },
  "data": {
    "context": {
      "user": {
        "preferences": {
          "writingStyle": {
            "tone": "professional",
            "verbosity": "concise",
            "technicality": "high"
          },
          "workPatterns": {
            "peakHours": [9, 10, 11, 14, 15],
            "preferredTaskSize": "medium",
            "collaborationStyle": "async"
          }
        },
        "recentPatterns": {
          "taskEstimation": {
            "tendency": "conservative",
            "accuracy": 0.85
          },
          "prioritization": {
            "factors": ["deadline", "impact"],
            "bias": "urgent-important"
          }
        }
      },
      "workspace": {
        "activeProjects": [
          {
            "id": "proj_123",
            "name": "API Development",
            "phase": "implementation",
            "priority": "high"
          }
        ],
        "recentActivity": {
          "last24h": {
            "tasksCreated": 5,
            "tasksCompleted": 3,
            "focusAreas": ["backend", "documentation"]
          }
        }
      },
      "suggestions": {
        "prompts": {
          "classification": "You prefer technical tasks...",
          "prioritization": "Based on your Eisenhower matrix usage..."
        },
        "examples": [
          {
            "input": "Fix authentication bug",
            "output": "task",
            "confidence": 0.95
          }
        ]
      }
    },
    "metadata": {
      "cacheHit": false,
      "contextVersion": "2.1",
      "lastUpdated": "2024-01-01T09:30:00.000Z"
    }
  }
}
```

#### Error Response
```json
{
  "metadata": {
    "requestId": "550e8400-e29b-41d4-a716-446655440000",
    "responseId": "880e8400-e29b-41d4-a716-446655440003",
    "timestamp": "2024-01-01T10:00:05.000Z",
    "version": "2.0",
    "processingTime": 5000
  },
  "status": {
    "code": 503,
    "success": false,
    "message": "Context service temporarily unavailable"
  },
  "error": {
    "code": "CONTEXT_SERVICE_UNAVAILABLE",
    "message": "Unable to retrieve user context due to database timeout",
    "details": {
      "service": "supabase",
      "operation": "getUserContext",
      "timeout": 5000
    },
    "suggestion": "Please retry in a few moments. If the problem persists, check database connection."
  }
}
```

---

## 🔐 Authentication Standards

### Signature-Based Authentication
```javascript
// Generate request signature
function generateSignature(request, secret) {
  const payload = JSON.stringify({
    requestId: request.metadata.requestId,
    timestamp: request.metadata.timestamp,
    data: request.data
  });
  
  return crypto
    .createHmac('sha256', secret)
    .update(payload)
    .digest('hex');
}

// Verify request signature
function verifySignature(request, signature, secret) {
  const expected = generateSignature(request, secret);
  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expected)
  );
}
```

### Header Configuration
```javascript
// Standard headers for all requests
const headers = {
  'Content-Type': 'application/json',
  'X-API-Version': '2.0',
  'X-Request-ID': requestId,
  'X-Webhook-Signature': signature,
  'X-Timestamp': timestamp,
  'User-Agent': 'n8n-workflow/2.0'
};
```

---

## 📊 Endpoint Specifications

### Context Management Endpoints

#### GET Context
```yaml
Endpoint: /api/v2/context
Method: POST  # POST for complex queries
Request:
  - userId: string (required)
  - contextType: string (required)
  - options: object (optional)
Response:
  - context: object
  - metadata: object
```

#### Update Context
```yaml
Endpoint: /api/v2/context/update
Method: POST
Request:
  - userId: string (required)
  - updates: object (required)
  - merge: boolean (default: true)
Response:
  - updated: boolean
  - context: object (new context)
```

### Learning Endpoints

#### Capture Interaction
```yaml
Endpoint: /api/v2/learning/capture
Method: POST
Request:
  - interaction: object (required)
  - priority: string (optional)
Response:
  - captured: boolean
  - queuePosition: number
```

#### Get Learning Analytics
```yaml
Endpoint: /api/v2/learning/analytics
Method: POST
Request:
  - userId: string (required)
  - timeRange: string (required)
  - metrics: array (optional)
Response:
  - analytics: object
  - recommendations: array
```

---

## 🛠️ Implementation Helpers

### Request Builder
```javascript
class APIRequestBuilder {
  constructor(config) {
    this.version = config.version || '2.0';
    this.workflow = config.workflow;
    this.userId = config.userId;
    this.secret = config.secret;
  }
  
  buildRequest(endpoint, data, options = {}) {
    const request = {
      metadata: {
        requestId: crypto.randomUUID(),
        timestamp: new Date().toISOString(),
        version: this.version,
        source: {
          workflow: this.workflow,
          executionId: $executionId,
          userId: this.userId,
          sessionId: options.sessionId
        }
      },
      auth: {
        method: 'signature',
        credentials: ''
      },
      data: data,
      options: {
        timeout: options.timeout || 5000,
        priority: options.priority || 'normal',
        returnFormat: options.format || 'full'
      }
    };
    
    // Generate signature
    request.auth.credentials = this.generateSignature(request);
    
    return request;
  }
  
  generateSignature(request) {
    const payload = JSON.stringify({
      requestId: request.metadata.requestId,
      timestamp: request.metadata.timestamp,
      data: request.data
    });
    
    return 'sha256:' + crypto
      .createHmac('sha256', this.secret)
      .update(payload)
      .digest('hex');
  }
}

// Usage in n8n
const builder = new APIRequestBuilder({
  version: '2.0',
  workflow: $workflow.name,
  userId: $json.userId,
  secret: $env.WEBHOOK_SECRET
});

const request = builder.buildRequest('/context', {
  contextType: 'inbox_processing',
  currentInput: $json.inboxItem
});
```

### Response Parser
```javascript
class APIResponseParser {
  parse(response) {
    // Check if response is valid
    if (!response.metadata || !response.status) {
      throw new Error('Invalid API response format');
    }
    
    // Check for errors
    if (!response.status.success) {
      this.handleError(response.error);
    }
    
    // Extract data with defaults
    return {
      data: response.data || {},
      metadata: response.metadata,
      processingTime: response.metadata.processingTime,
      cached: response.data?.metadata?.cacheHit || false
    };
  }
  
  handleError(error) {
    const err = new Error(error.message);
    err.code = error.code;
    err.details = error.details;
    err.suggestion = error.suggestion;
    throw err;
  }
  
  isRetryable(error) {
    const retryableCodes = [
      'RATE_LIMIT_EXCEEDED',
      'SERVICE_UNAVAILABLE',
      'TIMEOUT',
      'INTERNAL_ERROR'
    ];
    
    return retryableCodes.includes(error.code);
  }
}

// Usage
const parser = new APIResponseParser();

try {
  const result = parser.parse($json);
  return result.data;
} catch (error) {
  if (parser.isRetryable(error)) {
    // Retry logic
    throw new Error(`Retryable error: ${error.message}`);
  } else {
    // Permanent failure
    throw error;
  }
}
```

---

## 📐 Validation Schemas

### Request Validation
```javascript
// JSON Schema for request validation
const requestSchema = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["metadata", "auth", "data"],
  "properties": {
    "metadata": {
      "type": "object",
      "required": ["requestId", "timestamp", "version", "source"],
      "properties": {
        "requestId": {
          "type": "string",
          "format": "uuid"
        },
        "timestamp": {
          "type": "string",
          "format": "date-time"
        },
        "version": {
          "type": "string",
          "pattern": "^\\d+\\.\\d+$"
        },
        "source": {
          "type": "object",
          "required": ["workflow", "executionId", "userId"],
          "properties": {
            "workflow": { "type": "string" },
            "executionId": { "type": "string" },
            "userId": { "type": "string" },
            "sessionId": { "type": "string" }
          }
        }
      }
    },
    "auth": {
      "type": "object",
      "required": ["method", "credentials"],
      "properties": {
        "method": {
          "type": "string",
          "enum": ["header", "token", "signature"]
        },
        "credentials": { "type": "string" }
      }
    },
    "data": {
      "type": "object"
    },
    "options": {
      "type": "object",
      "properties": {
        "timeout": { "type": "number" },
        "priority": {
          "type": "string",
          "enum": ["low", "normal", "high"]
        },
        "returnFormat": {
          "type": "string",
          "enum": ["full", "summary", "minimal"]
        }
      }
    }
  }
};

// Validate request
function validateRequest(request) {
  const ajv = new Ajv();
  const validate = ajv.compile(requestSchema);
  
  if (!validate(request)) {
    throw new Error(`Invalid request: ${JSON.stringify(validate.errors)}`);
  }
  
  return true;
}
```

---

## 🧪 Testing Utilities

### Mock Response Generator
```javascript
class MockAPIResponses {
  static success(data, options = {}) {
    return {
      metadata: {
        requestId: options.requestId || crypto.randomUUID(),
        responseId: crypto.randomUUID(),
        timestamp: new Date().toISOString(),
        version: "2.0",
        processingTime: options.processingTime || 100
      },
      status: {
        code: 200,
        success: true,
        message: options.message || "Success"
      },
      data: data
    };
  }
  
  static error(code, message, details = {}) {
    return {
      metadata: {
        requestId: details.requestId || crypto.randomUUID(),
        responseId: crypto.randomUUID(),
        timestamp: new Date().toISOString(),
        version: "2.0",
        processingTime: 0
      },
      status: {
        code: code,
        success: false,
        message: message
      },
      error: {
        code: details.errorCode || 'UNKNOWN_ERROR',
        message: message,
        details: details,
        suggestion: details.suggestion
      }
    };
  }
}

// Usage in tests
const mockContext = MockAPIResponses.success({
  context: { user: { preferences: {} } }
});

const mockError = MockAPIResponses.error(503, "Service unavailable", {
  errorCode: "SERVICE_UNAVAILABLE",
  service: "context",
  suggestion: "Retry in 5 seconds"
});
```

---

## 📚 Best Practices

### 1. Always Include Metadata
Every request and response must include complete metadata for tracking and debugging.

### 2. Use Consistent Error Codes
Maintain a registry of error codes that are meaningful and actionable.

### 3. Version Your APIs
Include version in all requests to support backward compatibility.

### 4. Implement Retries
Use exponential backoff for retryable errors.

### 5. Monitor Response Times
Track processingTime to identify performance issues.

### 6. Validate Everything
Validate both incoming requests and outgoing responses.

### 7. Document Changes
Maintain a changelog for API modifications.

---

This API design standard ensures consistent, reliable, and maintainable communication between all n8n workflows in the system.