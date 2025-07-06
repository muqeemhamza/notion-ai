# Quick Reference Guide

## Essential Operations

### 1. Creating New Items
```python
# Always search first
search_knowledge_base(query)
search_existing_items(type, query)

# Then create with proper template
create_task(title, description, story_id)
create_story(title, description, epic_id)
create_epic(title, description, project_id)
create_knowledge_entry(title, content, source_ids)
```

### 2. Required Fields by Type

#### Task
- Task Name (title)
- Description
- Related Story (relation)
- Priority
- Status
- Estimated Hours
- Tags

#### Story
- Story Name (title)
- User Story
- Epic (relation)
- Priority
- Status
- Acceptance Criteria
- Tags

#### Epic
- Epic Name (title)
- Overview
- Project (relation)
- Priority
- Status
- Timeline
- Success Metrics

#### Knowledge Base
- Title
- Content
- Source (relation)
- Category
- Tags
- Verified (checkbox)

### 3. Status Values

#### Standard Status
- Not Started
- In Progress
- Blocked
- In Review
- Complete
- Cancelled

#### Inbox Processing Status
- Draft
- Pending Approval
- Approved
- Processing
- Completed
- Rejected

### 4. Priority Values
- Critical
- High
- Medium
- Low

### 5. Common Tags
- Development
- Research
- Documentation
- Bug
- Enhancement
- Security
- Performance
- UI/UX
- Backend
- Frontend
- Data
- Integration
- Testing
- Deployment

## Workflow Rules

### Before Creating
1. Search Knowledge Base
2. Check for existing similar items
3. Verify parent item exists
4. Use correct template

### After Creating
1. Set all relations
2. Add relevant tags
3. Link to Knowledge Base entries
4. Update parent item if needed

### When Updating
1. Check dependencies
2. Update related items
3. Document changes
4. Maintain audit trail

## AI Processing

### Confidence Levels
- 90-100%: Very High (auto-process)
- 70-89%: High (recommend approval)
- 50-69%: Medium (needs review)
- 30-49%: Low (needs more info)
- 0-29%: Very Low (draft only)

### Classification Types
- Task: Specific, actionable work
- Story: Feature or user-facing change
- Epic: Large initiative or project
- Knowledge: Reusable information
- Note: Uncategorized capture

### Actions
- CREATE_NEW: Make new item
- UPDATE_EXISTING: Modify existing
- LINK_TO_EXISTING: Create relationship
- CONVERT: Change type
- ARCHIVE: Move to archive

## Error Prevention

### Common Mistakes
1. Creating duplicates - Always search first
2. Missing relations - Set parent links
3. Wrong template - Use exact format
4. No KB search - Check knowledge first
5. Orphaned items - Link properly

### Validation Checks
- Title not empty
- Parent relation exists
- Status is valid
- Priority is set
- Template followed
- Relations established