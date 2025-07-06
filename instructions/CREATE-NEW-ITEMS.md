# 📝 Creating New Items Guide

This guide explains how to create new Projects, Epics, Stories, and Tasks using Notion MCP and following the established templates.

> **Note:** The number and type of stories and tasks should always be determined by the real requirements and context of the project, epic, or story. There is no fixed template or quota—use your judgment (or LLM analysis) to break down work in a way that makes sense for each case.

## Prerequisites
- Notion MCP initialized with integration token
- Access to database IDs from `/docs/n8n/ai-agent-guide.md`
- Understanding of the hierarchical structure: Project → Epic → Story → Task

## Database IDs Reference
```
Projects DB: 2200d219-5e1c-81e4-9522-fba13a081601
Epics DB: 21e0d2195e1c809bae77f183b66a78b2
Stories DB: 21e0d2195e1c806a947ff1806bffa2fb
Tasks DB: 21e0d2195e1c80a28c67dc2a8ed20e1b
Knowledge Base DB: 21e0d2195e1c802ca067e05dd1e4e908
Inbox DB: 21e0d2195e1c80228d8cf8ffd2a27275
```

## Active Projects Reference
1. **Techniq Company Building** - Everything related to building the company (website, brand, hiring, operations)
2. **Trading & Financial Markets Platform** - Trading infrastructure, data systems, strategies, dashboards
3. **Healthcare AI Product Development** - AI medical products, clinical applications, healthcare data systems

See PROJECT-DEFINITIONS.md for detailed scope of each project.

---

## Creating a New Project

### 1. Project Template
```markdown
# Project: [Project Name]

## Overview
[Brief description of the project's purpose and goals]

## Category
[Data Consultancy / AI Products / Stock Trading/Strategy / Marketing / Personal Life / Adhoc Projects]

## Objectives
- [ ] [Primary objective 1]
- [ ] [Primary objective 2]
- [ ] [Primary objective 3]

## Timeline
- Start Date: [YYYY-MM-DD]
- Target End Date: [YYYY-MM-DD]
- Key Milestones:
  - [Milestone 1]: [Date]
  - [Milestone 2]: [Date]

## Resources
- Owner: [Project Owner]
- Budget: [Budget if applicable]
- Team: [Team members]

## Status
[Planning / In Progress / On Hold / Completed]

## Priority
[Critical / High / Medium / Low]

## Tags
[Relevant tags for categorization]
```

### 2. MCP Command
```javascript
// Use Notion MCP to create project
notion.pages.create({
  parent: { database_id: "2200d219-5e1c-81e4-9522-fba13a081601" },
  properties: {
    "Title": { title: [{ text: { content: "Project Name" } }] },
    "Category": { select: { name: "Category Name" } },
    "Status": { status: { name: "Planning" } },
    "Priority": { select: { name: "High" } },
    "Start Date": { date: { start: "YYYY-MM-DD" } },
    "End Date": { date: { start: "YYYY-MM-DD" } }
  }
})
```

---

## Creating a New Epic

### 1. Epic Template
```markdown
# Epic: [Epic Number] - [Epic Name]

## Executive Summary
[High-level summary of what this epic is about and why it matters.]

## Background & Context
[Detailed background, business context, and history. Why is this epic needed? What problem does it solve?]

## Goals & Objectives
- [ ] [Primary goal 1]
- [ ] [Primary goal 2]
- [ ] [Primary goal 3]

## Detailed Description
[In-depth explanation of what needs to be done. Include user journeys, workflows, diagrams, and any relevant details.]

## Scope
- **In Scope:** [What is included?]
- **Out of Scope:** [What is explicitly not included?]

## Requirements
- [Requirement 1: Detailed explanation]
- [Requirement 2: Detailed explanation]
- [Requirement 3: Detailed explanation]

## Success Criteria
- [ ] [How will we know this epic is complete/successful?]

## Approach / Solution Ideas
[Describe possible approaches, technical solutions, or design ideas. Can include pros/cons, alternatives considered, and rationale.]

## Risks & Mitigations
- Risk: [Description] → Mitigation: [Strategy]

## Dependencies
- [List any dependencies on other epics, teams, or external factors]

## Stakeholders & Contacts
- Product Owner: [Name]
- Tech Lead: [Name]
- Other Stakeholders: [Names]

## Related Project
[Link to parent project]

## Timeline & Milestones
- Start Date: [YYYY-MM-DD]
- Target End Date: [YYYY-MM-DD]
- Key Milestones:
  - [Milestone 1]: [Date]
  - [Milestone 2]: [Date]

## Status
[Planning / In Progress / Blocked / Completed]

## Attachments & References
- [Links to documents, designs, research, etc.]

## Tags
[epic-number, domain-area, priority-level]
```

> **Guidance:** Fill in as much as possible, but if information is not yet available, leave the section as a placeholder to be updated later. This template is meant to be a living document and should be updated as the epic evolves.

### 2. File Naming Convention
```
/epics-stories-tasks/epic-[number]-[descriptive-name]/
└── epic-[number]-overview.md
```

### 3. MCP Integration
Link epic to project in Notion using relation properties.

---

## Creating a New Story

### 1. Story Template
```markdown
# Story: [Story Number] - [Story Name]

## Executive Summary
[Short summary of what this story is about and why it matters.]

## Background & Context
[Relevant background, business context, or links to the epic. Why is this story needed?]

## User Story
As a [user type], I want [goal] so that [benefit].

## Detailed Description & User Journeys
[In-depth explanation of what needs to be done. Include user journeys, workflows, diagrams, and any relevant details.]

## Acceptance Criteria
- [ ] [Given context, when action, then outcome]
- [ ] [Given context, when action, then outcome]
- [ ] [Given context, when action, then outcome]

## Requirements
- [Requirement 1: Detailed explanation]
- [Requirement 2: Detailed explanation]
- [Requirement 3: Detailed explanation]

## Technical Approach / Notes
[Describe possible approaches, technical notes, or design ideas.]

## Dependencies
- [Other stories, tasks, or external dependencies]

## Risks & Mitigations
- Risk: [Description] → Mitigation: [Strategy]

## Stakeholders & Contacts
- Product Owner: [Name]
- Tech Lead: [Name]
- Other Stakeholders: [Names]

## Related Epic
Epic [Number] - [Epic Name]

## Priority
[Critical / High / Medium / Low]

## Status
[To Do / In Progress / Review / Done]

## Estimation
[Story points or time estimate]

## Attachments & References
- [Links to documents, designs, research, etc.]

## Tags
[story-number, epic-number, feature-area]
```

> **Guidance:** Fill in as much as possible, but if information is not yet available, leave the section as a placeholder to be updated later. This template is meant to be a living document and should be updated as the story evolves.

### Story Patterns
Stories should be created based on the actual requirements and complexity of the epic. There is no fixed number or structure for stories per epic. Carefully analyze the epic's objectives and break them down into stories that represent meaningful, deliverable units of work.

- Some epics may require only a few stories, while others may need many to cover all requirements.
- Stories should be as focused and independent as possible, but not artificially split or merged to fit a template.
- The number and type of stories should reflect the real work needed to achieve the epic's goals.
- When using an LLM or automation to generate stories, ensure it reads the epic context and creates stories that make sense for that specific case.
- Example: A small refactor epic might have just one or two stories, while a large product feature epic could have stories for research, design, implementation, integration, and testing.

### 2. File Structure
```
/epics-stories-tasks/epic-[number]-[name]/story-[epic]-[story]/
└── story-[epic]-[story]-overview.md
```

---

## Creating a New Task

### 1. Task Template (from AI Agent Guide)
```markdown
# ✅ Task Overview

---

## 📝 Task Description
[Detailed description of what needs to be done]

---

## 🎯 Acceptance Criteria
- [ ] [Specific, measurable criterion 1]
- [ ] [Specific, measurable criterion 2]
- [ ] [Specific, measurable criterion 3]
- [ ] [Specific, measurable criterion 4]
- [ ] [Specific, measurable criterion 5]

---

## ⏳ Status & Priority
- **Status:** Not Started
- **Priority:** [Critical/High/Medium/Low]
- **Difficulty:** [Simple/Moderate/Complex]
- **Assignee:** TBD
- **Due Date:** TBD
- **Estimated Time:** [X-Y hours]
- **Actual Time:** TBD

---

## 🔗 Links & Relations
- **Linked Story:** [Story Number] - [Story Name]
- **Created From Note:** Epic [Number] - [Epic Name]
- **Knowledge Entry?:** [Yes/No - Knowledge Base entry title if applicable]

---

## 🏷️ Tags
- [Domain tag]
- [Technical tag]
- [Priority tag]
- [Feature area tag]

---

## 🗂 Attachments & Comments
- **Attachments:** [List any relevant files or documents]
- **Comments:** [Implementation notes, considerations, or context]

---

## 📝 Summary of Outcome
[Brief description of expected outcome and value delivered]
```

### 2. Task Patterns
Tasks should be created based on the specific needs and requirements of each story. There is no fixed number or structure for tasks per story. Instead, carefully read the story (and its parent epic, if relevant) to determine what actionable steps are required to deliver the story's outcome. 

- Some stories may require only 2-3 tasks, while others may need 10 or more.
- Tasks should be as granular as needed to ensure clarity, accountability, and progress tracking.
- The type and number of tasks should reflect the real work required, not a template or quota.
- When using an LLM or automation to generate tasks, ensure it analyzes the story/epic context and creates tasks that make sense for that specific case.
- Example: A simple bug fix story might have just 2 tasks (diagnose, fix), while a new feature story could have research, design, multiple implementation, review, and documentation tasks.

### 3. File Naming
```
task-[epic]-[story]-[task]-[descriptive-name].md
Example: task-06-01-01-research-sully-ai-platform.md
```

---

## Creating Knowledge Base Entries

### 1. Knowledge Base Template
```markdown
# 📄 [Knowledge Entry Title]

**Type:**
[Research/Tutorial/Guide/Reference/Lesson Learned/Decision Record]

**Tags:**
[tag1, tag2, tag3]

**Status:**
[Draft/Review/Published/Archived]

**Importance:**
[Critical/High/Medium/Low]

---

## 📝 Summary
[Brief 2-3 sentence summary of the knowledge]

---

## 📖 Full Description
[Detailed content, can include:]
- Background and context
- Key findings or insights
- Step-by-step instructions
- Best practices
- Examples and use cases

---

## 🔗 Linked Task / Story / Epic
- [ ] Task: [Task ID] - [Task Name]
- [ ] Story: [Story ID] - [Story Name]  
- [ ] Epic: [Epic ID] - [Epic Name]

---

## 🗒️ Source Note
[Original source or context where this knowledge originated]

---

## 📎 Attachments
- [Links to relevant files, documents, or resources]

---

## 💬 Comments
[Additional notes, updates, or clarifications]

---

## ✅ Tasks / Action Items
- [ ] [Any follow-up actions needed]

---

## 🤖 Created by AI?
☐ Yes
☐ No

---

**Created Date:** [YYYY-MM-DD]
**Last Updated:** [YYYY-MM-DD]
```

---

## Best Practices

### 1. Maintain Hierarchy
- Always link tasks to stories
- Always link stories to epics
- Always link epics to projects

### 2. Use Consistent Naming
- Follow the established file naming conventions
- Use descriptive names that are searchable

### 3. Keep Templates Intact
- Don't modify the core template structure
- Add content within the template sections
- The number and type of stories and tasks should always be based on the actual requirements and context, not a fixed template. Use real project needs to guide your breakdown.

### 4. Cross-Reference Everything
- Link related items across databases
- Create Knowledge Base entries for reusable learnings

### 5. For n8n Automation
- Keep properties consistent for automated workflows
- Use standard status values for triggers
- Tag appropriately for automated categorization

---

## Quick Reference: Creation Order

1. **Create Project** (if new domain)
2. **Create Epic** (major initiative)
3. **Create Stories** (features/requirements)
4. **Create Tasks** (actionable items)
5. **Create Knowledge Base entries** (as you learn)

Always check existing items before creating new ones to avoid duplicates!