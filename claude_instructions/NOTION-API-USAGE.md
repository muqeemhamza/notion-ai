# Notion API Usage Guide

## Authentication
```javascript
// Integration Token (DO NOT EXPOSE)
const NOTION_API_KEY = "ntn_[your_token_here]";
```

## Common Operations

### 1. Search Databases
```javascript
// Search for existing items before creating
const searchParams = {
  query: "search term",
  filter: {
    property: "Status",
    select: {
      does_not_equal: "Cancelled"
    }
  },
  sorts: [{
    property: "Created Date",
    direction: "descending"
  }]
};
```

### 2. Create Page
```javascript
// Create with template structure
const newPage = {
  parent: {
    database_id: "database_id_here"
  },
  properties: {
    "Title": {
      title: [{
        text: {
          content: "Page title"
        }
      }]
    },
    "Status": {
      select: {
        name: "Not Started"
      }
    },
    "Priority": {
      select: {
        name: "Medium"
      }
    },
    "Related Parent": {
      relation: [{
        id: "parent_page_id"
      }]
    }
  },
  children: [
    // Page content blocks
  ]
};
```

### 3. Update Page
```javascript
// Update specific properties
const updates = {
  properties: {
    "Status": {
      select: {
        name: "In Progress"
      }
    },
    "AI Confidence": {
      number: 0.85
    }
  }
};
```

### 4. Query Database
```javascript
// Get filtered results
const query = {
  database_id: "database_id",
  filter: {
    and: [
      {
        property: "Status",
        select: {
          equals: "In Progress"
        }
      },
      {
        property: "Priority",
        select: {
          equals: "High"
        }
      }
    ]
  },
  sorts: [{
    property: "Priority",
    direction: "descending"
  }]
};
```

## Property Types

### Text/Title
```javascript
"Property Name": {
  title: [{  // or rich_text for non-title text
    text: {
      content: "Text content"
    }
  }]
}
```

### Select
```javascript
"Property Name": {
  select: {
    name: "Option Name"
  }
}
```

### Multi-Select
```javascript
"Property Name": {
  multi_select: [
    { name: "Tag1" },
    { name: "Tag2" }
  ]
}
```

### Number
```javascript
"Property Name": {
  number: 42
}
```

### Relation
```javascript
"Property Name": {
  relation: [
    { id: "related_page_id_1" },
    { id: "related_page_id_2" }
  ]
}
```

### Date
```javascript
"Property Name": {
  date: {
    start: "2024-01-01",
    end: "2024-01-31"  // optional
  }
}
```

### Checkbox
```javascript
"Property Name": {
  checkbox: true
}
```

## Best Practices

### 1. Batch Operations
- Use Promise.all() for multiple operations
- Respect rate limits (3 requests/second)

### 2. Error Handling
```javascript
try {
  // Notion API call
} catch (error) {
  if (error.code === 'object_not_found') {
    // Handle missing item
  } else if (error.code === 'rate_limited') {
    // Implement backoff
  }
}
```

### 3. Efficient Queries
- Use filters to minimize data transfer
- Request only needed properties
- Implement pagination for large results

### 4. Data Validation
- Validate required fields before API calls
- Check parent relations exist
- Ensure property values match schema

## Common Patterns

### Check Before Create
```javascript
// 1. Search for existing
const existing = await searchDatabase(title);
if (existing.results.length > 0) {
  // Update existing instead
  return updatePage(existing.results[0].id, updates);
}
// 2. Create new if not found
return createPage(data);
```

### Maintain Relations
```javascript
// When creating child item
const child = await createPage({
  parent: { database_id: TASKS_DB },
  properties: {
    ...properties,
    "Related Story": {
      relation: [{ id: storyId }]
    }
  }
});

// Update parent's task count
await updatePage(storyId, {
  properties: {
    "Task Count": {
      number: currentCount + 1
    }
  }
});
```

### AI Integration
```javascript
// Add AI metadata
const aiGenerated = {
  "AI Confidence": {
    number: confidence
  },
  "AI Generated": {
    checkbox: true
  },
  "Generation Date": {
    date: {
      start: new Date().toISOString()
    }
  }
};
```