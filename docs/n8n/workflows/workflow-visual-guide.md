# Visual Workflow Guide

## Intelligent Inbox Processing - Flow Diagram

```
┌─────────────────┐
│  Inbox Trigger  │ (New item added to Inbox)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   AI Analysis   │ (Classify & Extract)
└────────┬────────┘
         │
    ┌────┴────┬────────┬─────────┬──────────┐
    ▼         ▼        ▼         ▼          ▼
┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐
│Search  ││Search  ││Search  ││Search  ││Search  │
│Projects││ Epics  ││Stories ││ Tasks  ││  KB    │
└────┬───┘└────┬───┘└────┬───┘└────┬───┘└────┬───┘
     └─────────┴─────────┴─────────┴─────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │  Decision Engine    │
              │ (Analyze all results)│
              └──────────┬──────────┘
                         │
       ┌─────────────────┼─────────────────┐
       ▼                 ▼                 ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│CREATE ACTION │ │UPDATE ACTION │ │ LINK ACTION  │
├──────────────┤ ├──────────────┤ ├──────────────┤
│• New Task    │ │• Add to Epic │ │• Connect KB  │
│• New Story   │ │• Update Story│ │• Link Tasks  │
│• New Epic    │ │• Append Task │ │• Tag Related │
│• New KB Entry│ │• Merge Dupe  │ │              │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       └─────────────────┴─────────────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │  Update Inbox Item  │
              │ (Mark as processed) │
              └─────────────────────┘
```

## Decision Logic Examples

### Example 1: New Feature Request
**Inbox Entry**: "Add dark mode to mobile app"

```
AI Analysis → Classification: Story
           → Related: "Mobile App" Epic exists
           
Decision   → CREATE Story under Mobile App Epic
           → LINK to existing "UI/UX" tasks
           → UPDATE Epic with new scope
```

### Example 2: Bug Report
**Inbox Entry**: "Login button not working on iPhone"

```
AI Analysis → Classification: Task
           → Related: "Mobile Login" Story exists
           
Decision   → CREATE Task under Mobile Login Story
           → UPDATE Story status to "In Progress"
           → LINK to similar iOS bug tasks
```

### Example 3: Strategic Initiative
**Inbox Entry**: "We should explore AI integration for customer support"

```
AI Analysis → Classification: Epic
           → Related: No existing epic found
           
Decision   → CREATE new Epic
           → CREATE initial research Story
           → CREATE KB entry for "AI Integration Research"
```

### Example 4: Knowledge/Learning
**Inbox Entry**: "Discovered PostgreSQL performs better with connection pooling"

```
AI Analysis → Classification: Knowledge
           → Related: "Database Optimization" tasks
           
Decision   → CREATE KB entry
           → LINK to all database-related items
           → TAG with "performance", "postgresql"
```

### Example 5: Update to Existing Work
**Inbox Entry**: "Update: Payment integration now needs to support Apple Pay"

```
AI Analysis → Classification: Update
           → Related: "Payment Integration" Epic exists
           
Decision   → UPDATE Epic description
           → CREATE new Story for Apple Pay
           → UPDATE acceptance criteria
```

## Workflow Components Breakdown

### 1. Search Strategy
The workflow searches intelligently across all databases:

```
For Epics:    Name contains keywords OR Description matches
For Stories:  Name/Description matches AND Status != Done  
For Tasks:    Exact mentions OR technical keywords
For KB:       Tags match technical terms
```

### 2. Relationship Mapping
```
Project ←→ Epic (one-to-many)
  └── Epic ←→ Story (one-to-many)
       └── Story ←→ Task (one-to-many)
            └── All ←→ Knowledge Base (many-to-many)
```

### 3. Priority Cascading
- If Epic is "Critical" → Stories inherit "High"
- If Story is "High" → Tasks inherit at least "Medium"
- Explicit priority in inbox overrides inheritance

### 4. Smart Duplicate Detection
Before creating any item:
1. Fuzzy match against existing titles (80% similarity)
2. Check for recent similar items (last 7 days)
3. If potential duplicate → Flag for review

## Implementation Tips

### Start Simple
1. Begin with Task creation only
2. Add Story creation after testing
3. Add Epic/KB creation last
4. Enable update logic after all creation works

### Test Cases
Always test with these scenarios:
- Single task: "Fix login button color"
- Story with tasks: "Implement user profile page with edit, view, and delete"
- Epic description: "Build customer portal for Q3"
- Knowledge: "Best practices for React hooks"
- Update: "Add to existing story: include export feature"

### Monitoring
Track these metrics:
- Classification accuracy (aim for >85%)
- Correct parent assignment (aim for >90%)
- Duplicate creation rate (should be <5%)
- Processing time (<30 seconds)

## Common Patterns

### Pattern 1: Feature Development
```
Inbox → "Add search to products page"
      ↓
Creates → Story: "Product Search Feature"
        → Task: "Design search UI"
        → Task: "Implement search API"
        → Task: "Add search tests"
```

### Pattern 2: Bug Workflow
```
Inbox → "Users can't reset password"
      ↓
Creates → Task: "Fix password reset flow"
Updates → Story: "Authentication" (status → In Progress)
Links  → KB: Previous password reset issues
```

### Pattern 3: Research & Planning
```
Inbox → "Research microservices architecture"
      ↓
Creates → Epic: "Microservices Migration"
        → Story: "Architecture Research"
        → Task: "Evaluate service boundaries"
        → KB: "Microservices Research Notes"
```