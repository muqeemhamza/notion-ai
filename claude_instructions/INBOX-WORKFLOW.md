# Inbox Workflow Processing

## Overview
The Inbox is the capture point for all raw ideas, notes, and tasks. AI processes these into structured project management items.

## Inbox Properties
1. **Note** (Title) - The raw captured text
2. **Processing Status** - Current state in workflow
3. **AI Confidence** - How certain AI is about classification (0-100%)
4. **AI Action Plan** - Formatted analysis and recommendations
5. **User Feedback** - Additional context from user
6. **Approval Actions** - User decision (Approve/Update/Discard)
7. **Processing Attempts** - Number of analysis iterations
8. **Confidence Reasoning** - Why AI has given confidence level

## Processing Flow

### 1. Initial Capture
```
User creates inbox item → Status: "Draft"
```

### 2. AI Analysis
```
AI reads item → Classifies type → Calculates confidence → Generates action plan
```

### 3. Status Assignment
- **90-100% confidence** → "Pending Approval"
- **Below 90% confidence** → "Draft" (needs more info)

### 4. User Review
User has three options:
- **Approve ✅** → Execute AI plan
- **Update Entry 📝** → Add more context and re-analyze
- **Discard ❌** → Archive without action

### 5. Execution
If approved:
1. Create new item (Task/Story/Epic/Knowledge)
2. Set all properties from AI analysis
3. Link to identified parents
4. Mark inbox item "Completed"

## AI Classification Logic

### Task Detection
- Action verbs (implement, fix, create, update)
- Specific deliverable mentioned
- Time estimate present
- Technical details included

### Story Detection
- User story format detected
- Feature description
- Multiple acceptance criteria
- User benefit mentioned

### Epic Detection
- Strategic language
- Multiple features mentioned
- Timeline spanning months
- Budget or resource allocation

### Knowledge Detection
- How-to format
- Documentation style
- Best practices mentioned
- Reusable information

## Confidence Scoring

### Very High (90-100%)
- All required information present
- Clear classification signals
- Parent items identified
- No ambiguity

### High (70-89%)
- Most information present
- Classification probable
- Minor assumptions needed
- Parent items likely

### Medium (50-69%)
- Key information missing
- Multiple classifications possible
- Moderate assumptions
- Parent unclear

### Low (30-49%)
- Significant gaps
- Unclear intent
- Major assumptions needed
- No clear classification

### Very Low (0-29%)
- Insufficient information
- Cannot determine intent
- Would be guessing
- Needs user input

## Example Processing

### Input
```
"Fix the login bug where users can't reset password on mobile"
```

### AI Analysis
```json
{
  "confidence": 85,
  "classification": "Task",
  "action": "CREATE_NEW",
  "reasoning": "Clear bug description with specific issue",
  "suggested_properties": {
    "title": "Fix password reset functionality on mobile devices",
    "priority": "High",
    "type": "Bug",
    "estimated_hours": 4
  }
}
```

### Result
- Status: "Pending Approval"
- Shows 85% confidence
- Awaits user approval
- Creates bug task if approved

## Best Practices

1. **Complete Information** - Include as much context as possible
2. **Clear Intent** - State what type of item you're creating
3. **Link Context** - Mention related projects/epics/stories
4. **Use Keywords** - Include priority, deadlines, assignments
5. **Review Carefully** - Check AI's interpretation before approving

## Common Patterns

### Quick Task
```
"TODO: Update API documentation for v2 endpoints"
```

### Feature Story
```
"As a user, I want to export my data as CSV so I can analyze it in Excel"
```

### Knowledge Capture
```
"Learned: Redis connection pooling prevents timeout errors in production. Set pool size to 50 for optimal performance."
```

### Project Epic
```
"Q2 Initiative: Implement complete authentication system including SSO, 2FA, and password policies. Timeline: 3 months, Team: 4 devs"
```