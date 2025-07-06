# AI Prompts Library for Notion PMS

## Overview
This library contains precise, template-driven prompts for the AI-powered Notion Project Management System. Each prompt is designed to produce consistent, actionable results with clear confidence scoring.

---

## Core Analysis Prompts

### 1. Master Inbox Analysis Prompt
```javascript
const MASTER_INBOX_PROMPT = `
You are an AI assistant for a Notion-based Project Management System. Your role is to analyze inbox entries and create precise action plans.

SYSTEM ARCHITECTURE:
- Projects: Top-level business domains (e.g., "Trading Platform", "Healthcare AI")
- Epics: Major initiatives within projects (1-3 months)
- Stories: User-facing features within epics (1-2 weeks)
- Tasks: Specific work items within stories (1-3 days)
- Knowledge Base: Reusable documentation and learnings

CLASSIFICATION DEFINITIONS:
- Task: Single deliverable with clear acceptance criteria, typically 1-3 days
- Story: Feature or capability requiring multiple tasks, typically 1-2 weeks
- Epic: Strategic initiative containing multiple stories, typically 1-3 months
- Knowledge: Documentation, best practices, learnings, or reference material
- Question: Requires clarification before processing
- Update: Modification or addition to existing item

INBOX ENTRY:
Title: {title}
Content: {content}
Priority: {priority}
Tags: {tags}
Created Date: {created_date}
User Feedback: {user_feedback}
Attempt: {attempt_number}

CONFIDENCE SCORING CRITERIA:
90-100%: All required information present, clear classification, obvious parent items
70-89%: Clear intent with reasonable assumptions, minor details missing
50-69%: Multiple valid interpretations, significant context missing
30-49%: Very ambiguous, major clarification needed
0-29%: Cannot determine intent without user input

ANALYSIS REQUIREMENTS:
1. Determine classification with reasoning
2. Identify parent items (project/epic/story)
3. Extract technical keywords and domain
4. Create specific, actionable titles
5. Generate clear acceptance criteria
6. Estimate effort realistically
7. Suggest relevant searches
8. List clarification needs

OUTPUT FORMAT (strict JSON):
{
  "confidence": 0-100,
  "confidence_factors": {
    "clarity_of_intent": 0-100,
    "information_completeness": 0-100,
    "parent_item_certainty": 0-100,
    "classification_certainty": 0-100
  },
  "confidence_reasoning": "Detailed explanation of score",
  
  "classification": "Task|Story|Epic|Knowledge|Question|Update",
  "classification_reasoning": "Why this classification",
  
  "action": "CREATE_NEW|UPDATE_EXISTING|LINK_RELATED|SPLIT_MULTIPLE|DRAFT_ONLY",
  "action_reasoning": "Why this action",
  
  "extracted_entities": {
    "mentioned_projects": ["Project1", "Project2"],
    "mentioned_epics": ["Epic1", "Epic2"],
    "mentioned_stories": ["Story1", "Story2"],
    "technical_keywords": ["keyword1", "keyword2"],
    "domain_areas": ["Frontend", "Backend", "DevOps"],
    "team_members": ["person1", "person2"]
  },
  
  "action_plan": {
    "summary": "One-line summary of plan",
    "creates": [...],
    "updates": [...],
    "links": [...]
  },
  
  "clarification_needed": ["question1", "question2"],
  "search_suggestions": {...},
  "alternative_interpretations": [...]
}
`;
```

### 2. Task-Specific Analysis Prompt
```javascript
const TASK_ANALYSIS_PROMPT = `
Analyze this inbox entry specifically as a TASK.

TASK CRITERIA:
- Single, specific deliverable
- Can be completed by one person
- Clear definition of "done"
- Typically 1-3 days of effort
- Part of a larger story/feature

REQUIRED TASK ELEMENTS:
1. Action verb in title (Create, Update, Fix, Implement, etc.)
2. Specific deliverable described
3. Clear acceptance criteria (min 2-3)
4. Realistic effort estimate
5. Parent story relationship

INBOX CONTENT:
{content}

EXTRACT AND STRUCTURE:
{
  "task_title": "Action verb + specific deliverable",
  "description": "What needs to be done and why",
  "acceptance_criteria": [
    "User can...",
    "System should...",
    "Output includes..."
  ],
  "technical_requirements": ["req1", "req2"],
  "estimated_hours": 1-24,
  "suggested_parent_story": "Story title this belongs to",
  "dependencies": ["dependency1", "dependency2"],
  "priority_reasoning": "Why this priority level"
}
`;
```

### 3. Story-Specific Analysis Prompt
```javascript
const STORY_ANALYSIS_PROMPT = `
Analyze this inbox entry specifically as a USER STORY.

STORY CRITERIA:
- Delivers value to end user
- Contains multiple tasks
- Has clear user benefit
- Typically 1-2 weeks effort
- Part of a larger epic

USER STORY FORMAT:
"As a [user type], I want [feature] so that [benefit]"

REQUIRED STORY ELEMENTS:
1. User story statement
2. Acceptance criteria (3-5)
3. Technical approach outline
4. Task breakdown (3-7 tasks)
5. Parent epic relationship

INBOX CONTENT:
{content}

STRUCTURE AS:
{
  "story_title": "Feature name",
  "user_story": "As a..., I want..., so that...",
  "acceptance_criteria": [
    "Given... When... Then...",
    "User can successfully...",
    "System validates..."
  ],
  "task_breakdown": [
    {
      "task_title": "Design UI mockups",
      "estimated_hours": 8
    },
    {
      "task_title": "Implement backend API",
      "estimated_hours": 16
    }
  ],
  "suggested_parent_epic": "Epic title",
  "story_points": 1-13,
  "technical_notes": "Implementation approach"
}
`;
```

### 4. Epic-Specific Analysis Prompt
```javascript
const EPIC_ANALYSIS_PROMPT = `
Analyze this inbox entry specifically as an EPIC.

EPIC CRITERIA:
- Strategic initiative or major feature set
- Contains multiple user stories
- Aligns with business objectives
- Typically 1-3 months effort
- Significant business value

REQUIRED EPIC ELEMENTS:
1. Clear business objective
2. Success metrics
3. High-level scope
4. Story breakdown (5-10 stories)
5. Timeline estimate
6. Resource requirements

INBOX CONTENT:
{content}

STRUCTURE AS:
{
  "epic_title": "Strategic initiative name",
  "business_objective": "What business goal this achieves",
  "success_metrics": [
    "Metric 1: Target value",
    "Metric 2: Target value"
  ],
  "scope_description": "What's included and excluded",
  "story_outline": [
    {
      "story_title": "User authentication",
      "story_description": "Allow users to register and login",
      "estimated_weeks": 2
    }
  ],
  "suggested_parent_project": "Project name",
  "estimated_months": 1-6,
  "resource_needs": {
    "developers": 2,
    "designers": 1,
    "qa": 1
  },
  "risks": ["risk1", "risk2"],
  "dependencies": ["dependency1", "dependency2"]
}
`;
```

### 5. Knowledge Base Entry Prompt
```javascript
const KNOWLEDGE_ENTRY_PROMPT = `
Analyze this inbox entry as a KNOWLEDGE BASE item.

KNOWLEDGE CRITERIA:
- Reusable information
- Best practices or learnings
- Technical documentation
- Decision records
- Reference material

KNOWLEDGE TYPES:
- How-to Guide
- Best Practice
- Technical Reference
- Decision Record
- Lessons Learned
- Architecture Documentation

INBOX CONTENT:
{content}

STRUCTURE AS:
{
  "kb_title": "Clear, searchable title",
  "kb_type": "Guide|Reference|Decision|Lesson|Architecture",
  "summary": "1-2 sentence overview",
  "content_sections": [
    {
      "heading": "Section title",
      "content": "Section content"
    }
  ],
  "tags": ["tag1", "tag2", "tag3"],
  "related_items": {
    "tasks": ["task1", "task2"],
    "stories": ["story1"],
    "epics": ["epic1"]
  },
  "search_keywords": ["keyword1", "keyword2"],
  "expiry_date": "When to review/update",
  "importance": "High|Medium|Low"
}
`;
```

---

## Specialized Analysis Prompts

### 6. Multi-Item Detection Prompt
```javascript
const MULTI_ITEM_PROMPT = `
Analyze if this inbox entry contains MULTIPLE distinct items.

DETECTION CRITERIA:
- Multiple unrelated deliverables
- Different classification types mixed
- Separate timelines mentioned
- Different owners/teams involved

INBOX CONTENT:
{content}

IDENTIFY:
{
  "contains_multiple": true|false,
  "item_count": 1-n,
  "items": [
    {
      "item_number": 1,
      "classification": "Task|Story|Epic|Knowledge",
      "title": "Item title",
      "content": "Relevant content for this item",
      "confidence": 0-100
    }
  ],
  "splitting_reasoning": "Why these should be separate items"
}
`;
```

### 7. Update Detection Prompt
```javascript
const UPDATE_DETECTION_PROMPT = `
Determine if this inbox entry is an UPDATE to existing work.

UPDATE INDICATORS:
- References existing item by name
- Uses words like "update", "add to", "modify"
- Mentions previous decisions/work
- Contains additional requirements

INBOX CONTENT:
{content}

ANALYZE:
{
  "is_update": true|false,
  "update_type": "addition|modification|correction|expansion",
  "target_item": {
    "likely_type": "Task|Story|Epic",
    "search_terms": ["term1", "term2"],
    "identifying_features": ["feature1", "feature2"]
  },
  "update_content": {
    "what_to_add": "Content to append",
    "what_to_change": "Modifications needed",
    "new_requirements": ["req1", "req2"]
  },
  "confidence_in_match": 0-100
}
`;
```

### 8. Project/Epic Matching Prompt
```javascript
const HIERARCHY_MATCHING_PROMPT = `
Identify the correct Project > Epic > Story hierarchy for this item.

KNOWN PROJECTS:
1. Techniq Company Building - Brand, website, operations
2. Trading & Financial Markets - Trading systems and strategies
3. Healthcare AI Product - Medical AI products

MATCHING CRITERIA:
- Domain keywords
- Business context
- Technical stack mentioned
- Team/department references

CONTENT TO MATCH:
{content}

DETERMINE:
{
  "project_match": {
    "name": "Project name",
    "confidence": 0-100,
    "matching_keywords": ["keyword1", "keyword2"]
  },
  "epic_match": {
    "name": "Epic name",
    "confidence": 0-100,
    "search_strategy": "How to find this epic"
  },
  "story_match": {
    "name": "Story name",
    "confidence": 0-100,
    "create_new": true|false
  },
  "hierarchy_path": "Project > Epic > Story > Task"
}
`;
```

---

## Feedback Processing Prompts

### 9. Feedback Integration Prompt
```javascript
const FEEDBACK_INTEGRATION_PROMPT = `
Re-analyze with user feedback to improve accuracy.

PREVIOUS ANALYSIS:
Classification: {previous_classification}
Confidence: {previous_confidence}%
Action: {previous_action}

USER FEEDBACK:
"{user_feedback}"

LEARNING POINTS:
1. What did user correct?
2. What context was missing?
3. What assumptions were wrong?
4. What specific details were provided?

RE-ANALYZE WITH EMPHASIS ON:
- User's corrections
- Newly provided context
- Specific items/projects mentioned
- Preferred classification

PROVIDE UPDATED ANALYSIS:
{
  "confidence_boost": 0-30,
  "confidence_reasoning": "How feedback improved certainty",
  "classification_change": true|false,
  "key_learnings": ["learning1", "learning2"],
  "updated_action_plan": {...}
}
`;
```

### 10. Pattern Learning Prompt
```javascript
const PATTERN_LEARNING_PROMPT = `
Analyze feedback patterns to improve future processing.

FEEDBACK HISTORY:
{feedback_examples}

IDENTIFY PATTERNS:
{
  "common_misclassifications": {
    "task_as_story": frequency,
    "story_as_epic": frequency
  },
  "missing_context_patterns": [
    "Project names often implicit",
    "Technical stack assumptions"
  ],
  "user_preferences": {
    "title_format": "preferred pattern",
    "detail_level": "high|medium|low",
    "hierarchy_style": "deep|shallow"
  },
  "improvement_suggestions": [
    "Always check for...",
    "Assume X when Y is mentioned",
    "Default to Z classification when unclear"
  ]
}
`;
```

---

## Prompt Engineering Best Practices

### 1. Consistency Rules
- Always use the same property names
- Maintain JSON structure exactly
- Use consistent confidence scales
- Apply same classification criteria

### 2. Context Inclusion
- Include system architecture context
- Provide clear definitions
- Give examples when helpful
- Reference known entities

### 3. Output Validation
- Require valid JSON
- Specify required fields
- Set value constraints
- Include reasoning fields

### 4. Iterative Improvement
- Track prompt performance
- Update based on feedback
- Version control prompts
- Document changes

---

## Usage Guidelines

### When to Use Each Prompt:
1. **Master Inbox Prompt**: First analysis of any inbox item
2. **Type-Specific Prompts**: When classification is certain
3. **Multi-Item Prompt**: When content seems mixed
4. **Update Detection**: When "update" keywords present
5. **Hierarchy Matching**: For proper organization
6. **Feedback Integration**: On user corrections

### Prompt Chaining Strategy:
1. Start with Master Inbox Prompt
2. If multi-item detected → Multi-Item Prompt
3. If update detected → Update Detection Prompt
4. Based on classification → Type-Specific Prompt
5. For organization → Hierarchy Matching Prompt
6. After feedback → Feedback Integration Prompt

### Temperature Settings:
- Analysis prompts: 0.3 (consistency)
- Creative prompts: 0.7 (variety)
- Feedback prompts: 0.5 (balance)

---

## Monitoring and Optimization

Track these metrics for each prompt:
- Average confidence score
- User approval rate
- Feedback frequency
- Processing time
- Token usage

Optimize prompts when:
- Approval rate < 80%
- Average confidence < 70%
- Consistent feedback patterns
- Processing errors occur