# Data Integrity Validator Workflow

## Overview
This workflow ensures data consistency across all Notion databases, validates relationships, checks for orphaned items, and maintains the integrity of your hierarchical project management structure.

## Workflow Components

### 1. Trigger: Schedule
- **Primary**: Daily at 2 AM (low activity time)
- **Secondary**: After bulk operations
- **Manual**: On-demand validation
- **Event-based**: After major updates or imports

### 2. Database Schema Validation

#### 2a. Verify Database Structure
```javascript
const validateDatabaseSchema = async () => {
  const expectedDatabases = {
    projects: {
      id: '2200d219-5e1c-81e4-9522-fba13a081601',
      required_properties: ['Name', 'Status', 'Description', 'Start Date'],
      relations: []
    },
    epics: {
      id: '21e0d2195e1c809bae77f183b66a78b2',
      required_properties: ['Name', 'Status', 'Project', 'Description'],
      relations: ['Project']
    },
    stories: {
      id: '21e0d2195e1c806a947ff1806bffa2fb',
      required_properties: ['Name', 'Status', 'Epic', 'Project', 'Description'],
      relations: ['Epic', 'Project']
    },
    tasks: {
      id: '21e0d2195e1c80a28c67dc2a8ed20e1b',
      required_properties: ['Name', 'Status', 'Story', 'Description'],
      relations: ['Story']
    },
    inbox: {
      id: '21e0d2195e1c80228d8cf8ffd2a27275',
      required_properties: ['Name', 'Category', 'Created'],
      relations: []
    },
    knowledge_base: {
      id: '21e0d2195e1c802ca067e05dd1e4e908',
      required_properties: ['Title', 'Key Insights', 'Tags'],
      relations: ['Source']
    }
  };
  
  const validationResults = {};
  
  for (const [dbName, schema] of Object.entries(expectedDatabases)) {
    const database = await notion.databases.retrieve({ database_id: schema.id });
    
    validationResults[dbName] = {
      exists: !!database,
      properties_valid: validateProperties(database.properties, schema.required_properties),
      missing_properties: findMissingProperties(database.properties, schema.required_properties),
      extra_properties: findExtraProperties(database.properties, schema.required_properties)
    };
  }
  
  return validationResults;
};
```

### 3. Hierarchical Integrity Checks

#### 3a. Validate Parent-Child Relationships
```javascript
const validateHierarchy = async () => {
  const issues = {
    orphaned_items: [],
    circular_references: [],
    broken_relations: [],
    inconsistent_projects: []
  };
  
  // Check Tasks → Stories relationship
  const tasks = await notion.databases.query({
    database_id: TASKS_DB_ID
  });
  
  for (const task of tasks.results) {
    const storyRelation = task.properties.Story?.relation[0];
    if (!storyRelation) {
      issues.orphaned_items.push({
        type: 'task',
        id: task.id,
        name: task.properties.Name.title[0]?.plain_text,
        issue: 'No parent story'
      });
    } else {
      // Verify story exists
      try {
        const story = await notion.pages.retrieve({ page_id: storyRelation.id });
        
        // Check if task's project matches story's project
        const taskProject = await getProjectFromTask(task);
        const storyProject = story.properties.Project?.relation[0]?.id;
        
        if (taskProject && storyProject && taskProject !== storyProject) {
          issues.inconsistent_projects.push({
            type: 'task',
            id: task.id,
            name: task.properties.Name.title[0]?.plain_text,
            task_project: taskProject,
            story_project: storyProject,
            issue: 'Project mismatch with parent story'
          });
        }
      } catch (error) {
        issues.broken_relations.push({
          type: 'task',
          id: task.id,
          name: task.properties.Name.title[0]?.plain_text,
          related_id: storyRelation.id,
          issue: 'Related story not found'
        });
      }
    }
  }
  
  // Similar checks for Stories → Epics and Epics → Projects
  await validateStoriesHierarchy(issues);
  await validateEpicsHierarchy(issues);
  
  // Check for circular references
  issues.circular_references = await detectCircularReferences();
  
  return issues;
};
```

#### 3b. Detect Circular References
```javascript
const detectCircularReferences = async () => {
  const circularRefs = [];
  
  // Check dependencies don't create cycles
  const allItems = await getAllItemsWithDependencies();
  
  for (const item of allItems) {
    const visited = new Set();
    const path = [];
    
    if (hasCycle(item, visited, path, allItems)) {
      circularRefs.push({
        item_id: item.id,
        cycle_path: [...path],
        type: item.type
      });
    }
  }
  
  return circularRefs;
};
```

### 4. Data Consistency Validation

#### 4a. Required Fields Validation
```javascript
const validateRequiredFields = async () => {
  const missingFields = {
    projects: [],
    epics: [],
    stories: [],
    tasks: []
  };
  
  // Validate each database
  const databases = ['projects', 'epics', 'stories', 'tasks'];
  
  for (const dbType of databases) {
    const items = await notion.databases.query({
      database_id: DATABASE_IDS[dbType]
    });
    
    for (const item of items.results) {
      const missing = [];
      
      // Check required fields based on type
      const requiredFields = getRequiredFields(dbType);
      
      for (const field of requiredFields) {
        const value = item.properties[field];
        
        if (!value || isEmptyValue(value)) {
          missing.push(field);
        }
      }
      
      if (missing.length > 0) {
        missingFields[dbType].push({
          id: item.id,
          name: item.properties.Name?.title[0]?.plain_text || 'Unnamed',
          missing_fields: missing,
          url: item.url
        });
      }
    }
  }
  
  return missingFields;
};
```

#### 4b. Status Consistency Validation
```javascript
const validateStatusConsistency = async () => {
  const statusIssues = [];
  
  // Check if completed items have incomplete children
  const completedEpics = await notion.databases.query({
    database_id: EPICS_DB_ID,
    filter: {
      property: 'Status',
      status: { equals: 'Completed' }
    }
  });
  
  for (const epic of completedEpics.results) {
    const incompleteStories = await notion.databases.query({
      database_id: STORIES_DB_ID,
      filter: {
        and: [
          { property: 'Epic', relation: { contains: epic.id } },
          { property: 'Status', status: { does_not_equal: 'Completed' } }
        ]
      }
    });
    
    if (incompleteStories.results.length > 0) {
      statusIssues.push({
        type: 'epic_with_incomplete_stories',
        epic: {
          id: epic.id,
          name: epic.properties.Name.title[0]?.plain_text
        },
        incomplete_stories: incompleteStories.results.map(s => ({
          id: s.id,
          name: s.properties.Name.title[0]?.plain_text,
          status: s.properties.Status?.status?.name
        }))
      });
    }
  }
  
  // Similar checks for stories with incomplete tasks
  await validateStoryTaskConsistency(statusIssues);
  
  return statusIssues;
};
```

### 5. Knowledge Base Integrity

#### 5a. Validate Knowledge Base Links
```javascript
const validateKnowledgeBase = async () => {
  const kbIssues = {
    broken_sources: [],
    duplicate_entries: [],
    orphaned_knowledge: [],
    missing_tags: []
  };
  
  const kbEntries = await notion.databases.query({
    database_id: KNOWLEDGE_BASE_DB_ID
  });
  
  for (const entry of kbEntries.results) {
    // Check source links
    const sourceRelations = entry.properties.Source?.relation || [];
    for (const source of sourceRelations) {
      try {
        await notion.pages.retrieve({ page_id: source.id });
      } catch (error) {
        kbIssues.broken_sources.push({
          kb_entry: entry.id,
          title: entry.properties.Title?.title[0]?.plain_text,
          broken_source: source.id
        });
      }
    }
    
    // Check for missing tags
    const tags = entry.properties.Tags?.multi_select || [];
    if (tags.length === 0) {
      kbIssues.missing_tags.push({
        id: entry.id,
        title: entry.properties.Title?.title[0]?.plain_text
      });
    }
    
    // Check if knowledge is orphaned (no source)
    if (sourceRelations.length === 0) {
      kbIssues.orphaned_knowledge.push({
        id: entry.id,
        title: entry.properties.Title?.title[0]?.plain_text
      });
    }
  }
  
  // Detect potential duplicates
  kbIssues.duplicate_entries = await detectKBDuplicates(kbEntries.results);
  
  return kbIssues;
};
```

### 6. AI Analysis of Issues (OpenAI Chat)
```json
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "system",
      "content": "Analyze the data integrity issues and provide:\n1. Severity assessment for each issue\n2. Root cause analysis\n3. Remediation recommendations\n4. Priority order for fixes\n5. Potential impact if not addressed\n\nFocus on maintaining data quality and system reliability."
    },
    {
      "role": "user",
      "content": "Schema Validation: {{JSON.stringify($node['Validate Database Schema'].json)}}\n\nHierarchy Issues: {{JSON.stringify($node['Validate Hierarchy'].json)}}\n\nData Consistency: {{JSON.stringify($node['Validate Required Fields'].json)}}\n\nStatus Issues: {{JSON.stringify($node['Validate Status Consistency'].json)}}\n\nKnowledge Base Issues: {{JSON.stringify($node['Validate Knowledge Base'].json)}}"
    }
  ],
  "temperature": 0.3,
  "max_tokens": 2000
}
```

### 7. Generate Integrity Report
```javascript
const generateIntegrityReport = (validationResults, aiAnalysis) => {
  const totalIssues = countAllIssues(validationResults);
  const severityScore = calculateSeverityScore(validationResults, aiAnalysis);
  
  return {
    summary: {
      total_issues: totalIssues,
      severity_score: severityScore,
      status: getSeverityStatus(severityScore),
      last_check: new Date(),
      databases_checked: 6
    },
    
    critical_issues: aiAnalysis.critical_issues.map(issue => ({
      ...issue,
      auto_fix_available: canAutoFix(issue.type),
      manual_action_required: requiresManualIntervention(issue.type)
    })),
    
    issue_breakdown: {
      schema_issues: validationResults.schema.filter(i => i.missing_properties.length > 0),
      orphaned_items: validationResults.hierarchy.orphaned_items,
      broken_relations: validationResults.hierarchy.broken_relations,
      circular_references: validationResults.hierarchy.circular_references,
      missing_required_fields: validationResults.consistency.missing_fields,
      status_inconsistencies: validationResults.consistency.status_issues,
      knowledge_base_issues: validationResults.knowledge_base
    },
    
    recommendations: aiAnalysis.recommendations,
    
    auto_fix_summary: {
      fixable_issues: countAutoFixable(validationResults),
      estimated_time: estimateFixTime(validationResults),
      confidence: aiAnalysis.fix_confidence
    }
  };
};
```

### 8. Auto-Fix Implementation

#### 8a. Safe Auto-Fixes
```javascript
const autoFixIssues = {
  // Fix orphaned tasks by creating placeholder story
  fixOrphanedTasks: async (orphanedTasks) => {
    const placeholderStory = await notion.pages.create({
      parent: { database_id: STORIES_DB_ID },
      properties: {
        Name: { title: [{ text: { content: "Orphaned Tasks Container" } }] },
        Description: { 
          rich_text: [{ 
            text: { 
              content: "Temporary container for orphaned tasks. Please review and reassign." 
            } 
          }] 
        },
        Status: { status: { name: "To Do" } },
        Project: { relation: [{ id: getDefaultProjectId() }] }
      }
    });
    
    // Move orphaned tasks to placeholder
    for (const task of orphanedTasks) {
      await notion.pages.update({
        page_id: task.id,
        properties: {
          Story: { relation: [{ id: placeholderStory.id }] }
        }
      });
      
      await addComment(task.id, 
        "Moved from orphaned state to placeholder story for review"
      );
    }
    
    return { fixed: orphanedTasks.length, placeholder_id: placeholderStory.id };
  },
  
  // Fix missing required fields with defaults
  fixMissingFields: async (itemsWithMissingFields) => {
    const fixes = [];
    
    for (const item of itemsWithMissingFields) {
      const updates = {};
      
      for (const field of item.missing_fields) {
        updates[field] = getDefaultValue(field, item.type);
      }
      
      await notion.pages.update({
        page_id: item.id,
        properties: updates
      });
      
      fixes.push({
        item_id: item.id,
        fields_fixed: item.missing_fields
      });
    }
    
    return fixes;
  },
  
  // Fix broken relations by removing them
  fixBrokenRelations: async (brokenRelations) => {
    for (const item of brokenRelations) {
      // Remove the broken relation
      await notion.pages.update({
        page_id: item.id,
        properties: {
          [item.relation_field]: { relation: [] }
        }
      });
      
      // Add comment about the fix
      await addComment(item.id, 
        `Removed broken relation to non-existent item: ${item.related_id}`
      );
    }
    
    return { fixed: brokenRelations.length };
  }
};
```

#### 8b. Manual Fix Requests
```javascript
const createManualFixTasks = async (issuesRequiringManualFix) => {
  const fixTasks = [];
  
  for (const issue of issuesRequiringManualFix) {
    const task = await notion.pages.create({
      parent: { database_id: TASKS_DB_ID },
      properties: {
        Name: { 
          title: [{ 
            text: { 
              content: `Fix Data Integrity Issue: ${issue.type}` 
            } 
          }] 
        },
        Description: { 
          rich_text: [{ 
            text: { 
              content: formatIssueDescription(issue) 
            } 
          }] 
        },
        Priority: { select: { name: getPriorityFromSeverity(issue.severity) } },
        Status: { status: { name: "To Do" } },
        Tags: { 
          multi_select: [
            { name: "Data Integrity" },
            { name: "Manual Fix Required" }
          ] 
        }
      }
    });
    
    fixTasks.push(task);
  }
  
  return fixTasks;
};
```

### 9. Update Monitoring Dashboard
```javascript
const updateIntegrityDashboard = async (report) => {
  // Update main metrics
  await notion.pages.update({
    page_id: INTEGRITY_DASHBOARD_ID,
    properties: {
      'Total Issues': { number: report.summary.total_issues },
      'Severity Score': { number: report.summary.severity_score },
      'Last Check': { date: { start: report.summary.last_check } },
      'Status': { 
        select: { 
          name: report.summary.status,
          color: getStatusColor(report.summary.status)
        } 
      }
    }
  });
  
  // Update issue log
  await createIssueLogEntry(report);
  
  // Update trends
  await updateIntegrityTrends(report);
};
```

### 10. Preventive Measures

#### 10a. Implement Validation Rules
```javascript
const implementValidationRules = async () => {
  // Set up database rules to prevent future issues
  const rules = {
    // Prevent task creation without story
    task_creation: {
      rule: 'require_parent_story',
      enforcement: 'block'
    },
    
    // Prevent status inconsistencies
    status_changes: {
      rule: 'check_child_status',
      enforcement: 'warn'
    },
    
    // Require minimum fields
    required_fields: {
      rule: 'enforce_required',
      enforcement: 'block'
    }
  };
  
  // These would be implemented through n8n webhook validations
  await setupValidationWebhooks(rules);
};
```

## Configuration

### Validation Rules
```javascript
const validationConfig = {
  hierarchy_rules: {
    task_requires_story: true,
    story_requires_epic: true,
    epic_requires_project: true,
    enforce_project_consistency: true
  },
  
  field_requirements: {
    projects: ['Name', 'Status', 'Description'],
    epics: ['Name', 'Status', 'Project', 'Description'],
    stories: ['Name', 'Status', 'Epic', 'Description'],
    tasks: ['Name', 'Status', 'Story']
  },
  
  auto_fix_settings: {
    enabled: true,
    fix_orphaned_items: true,
    fix_missing_fields: true,
    fix_broken_relations: true,
    require_confirmation: false
  },
  
  alert_thresholds: {
    critical_issues: 10,
    warning_issues: 25,
    info_issues: 50
  }
};
```

## Example Validation Reports

### Clean System
```json
{
  "summary": {
    "total_issues": 0,
    "severity_score": 100,
    "status": "healthy"
  },
  "message": "All data integrity checks passed successfully"
}
```

### System with Issues
```json
{
  "summary": {
    "total_issues": 23,
    "severity_score": 72,
    "status": "warning"
  },
  "critical_issues": [
    {
      "type": "circular_reference",
      "items": ["task_123", "task_456"],
      "severity": "critical",
      "impact": "Prevents proper dependency tracking"
    }
  ],
  "auto_fix_summary": {
    "fixable_issues": 18,
    "manual_required": 5,
    "estimated_time": "5 minutes"
  }
}
```

## Benefits

### Data Quality Assurance
- Maintains referential integrity
- Prevents data corruption
- Ensures consistency across databases

### Automated Remediation
- Fixes common issues automatically
- Reduces manual maintenance burden
- Prevents issue accumulation

### Proactive Problem Detection
- Catches issues before they impact users
- Provides early warning system
- Maintains system reliability

## Future Enhancements

1. **Real-time Validation**: Validate on every database change
2. **Custom Validation Rules**: User-defined integrity rules
3. **Historical Tracking**: Track integrity scores over time
4. **Backup Integration**: Auto-backup before fixes
5. **Rollback Capability**: Undo auto-fixes if needed
6. **Cross-Database Validation**: Validate across multiple workspaces