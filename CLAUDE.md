# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AI-Augmented Notion Project Management System (PMS) and Knowledge Base that uses AI to automate workflows for managing notes, tasks, stories, epics, and knowledge entries. The system leverages Notion as the primary UI, Supabase for backend, and n8n for workflow automation.

## Critical Files to Read First

1. **PROJECT-DEFINITIONS.md** - Clear definitions of the 3 main projects and their scope
2. **AI Agent Guide**: `/docs/n8n/ai-agent-guide.md` - Single source of truth for Notion integration
3. **Instructions Directory**: `/instructions/` - Step-by-step guides for all operations:
   - `CREATE-NEW-ITEMS.md` - How to create projects/epics/stories/tasks
   - `EDIT-EXISTING-ITEMS.md` - How to edit existing items
   - `MODIFY-UPDATE-STORIES.md` - How to modify/update stories
   - `ADD-COMMENTS.md` - How to add comments
   - `DELETE-ITEMS.md` - How to safely delete items
   - `NOTION-INTEGRATION.md` - Notion MCP integration patterns
   - `KNOWLEDGE-BASE-GUIDE.md` - Knowledge Base usage
4. **Memory Bank**: `/memory-bank/` - Contains project context, technical setup, and current state

## Active Projects

1. **Techniq Company Building** - Building and operating Techniq as a business (brand, website, hiring, operations)
2. **Trading & Financial Markets Platform** - Trading infrastructure, data systems, strategy development, dashboards
3. **Healthcare AI Product Development** - AI medical products, clinical applications, healthcare data systems

For detailed scope and what belongs in each project, see PROJECT-DEFINITIONS.md

## Commands and Development

### MCP Server Initialization
```bash
# Initialize Official Notion MCP (required for all Notion operations)
# This is the official Notion MCP server with comprehensive features
# Integration Token: ntn_f35248778523jpOe6IQngDnseZlexMBsf2YC7jt6WEb9NF
# Note: We now use the official Notion MCP instead of the basic version

# Initialize Supabase MCP for backend operations

# Initialize other MCP servers as needed:
# - Sequential Thinking MCP
# - Filesystem MCP
# - Context7
# - Playwright MCP
# - Browserbase MCP
```

### Working with AI Agent Data
All AI-generated data should be stored in `/ai-agent-data/` with appropriate subdirectories:
- `inbox-processing/` - Classified inbox items
- `task-creation/` - AI-created tasks
- `story-generation/` - Generated stories
- `knowledge-capture/` - AI knowledge entries
- `logs/` - Operation logs
- `templates/` - Reusable templates

## Architecture Overview

### Notion Database Structure
- **Projects DB** (ID: `2200d219-5e1c-81e4-9522-fba13a081601`) - Top-level project containers
- **Epics DB** (ID: `21e0d2195e1c809bae77f183b66a78b2`) - High-level initiatives within projects
- **Stories DB** (ID: `21e0d2195e1c806a947ff1806bffa2fb`) - User stories/features within epics
- **Tasks DB** (ID: `21e0d2195e1c80a28c67dc2a8ed20e1b`) - Actionable items within stories
- **Inbox DB** (ID: `21e0d2195e1c80228d8cf8ffd2a27275`) - Raw capture of ideas/notes
- **Knowledge Base DB** (ID: `21e0d2195e1c802ca067e05dd1e4e908`) - Reusable knowledge

### Workflow Architecture
1. **Capture** → Daily Input Page & Inbox
2. **Classify** → AI-powered note classification
3. **Convert** → Transform notes to tasks/stories/knowledge
4. **Link** → Maintain relationships between entities
5. **Track** → Visual boards and progress monitoring
6. **Learn** → Automated retrospectives and knowledge capture

## Important Guidelines

### Template Fidelity
- **NEVER modify templates** - Use exactly as defined in `/docs/n8n/ai-agent-guide.md`
- Templates include: Epic, Story, Task, Knowledge Base, and Inbox Note
- All new Notion entries must use these templates verbatim

### AI Agent Workflow
1. Always search Knowledge Base before starting new work
2. Link all findings to relevant Epics/Stories/Tasks
3. Capture new knowledge as work progresses
4. Document all changes in appropriate locations

### Database Relations
- Project ↔ Epic (one-to-many)
- Epic ↔ Story (one-to-many)
- Story ↔ Task (one-to-many)
- All entities ↔ Knowledge Base (many-to-many)
- Inbox → Task/Story/Knowledge (conversion flow)

## n8n Automation Workflows
Key workflows documented in `/docs/n8n/`:
- Inbox automation with AI classification (`/docs/n8n/intelligent-inbox-workflow-v2.md`)
- AI prompts library (`/docs/n8n/ai-prompts-library.md`)
- Confidence scoring system (`/docs/n8n/confidence-scoring-guide.md`)
- Approval workflow (`/docs/n8n/approval-workflow-setup.md`)
- Feedback loop optimization (`/docs/n8n/feedback-loop-optimization.md`)
- Workflow code snippets (`/docs/n8n/workflow-code-snippets.md`)

Setup guides in `/docs/setup/`:
- Notion database configuration (`/docs/setup/notion-inbox-setup-guide.md`)

Testing documentation in `/docs/testing/`:
- Comprehensive test scenarios (`/docs/testing/test-scenarios.md`)

## Security and Best Practices
- Never expose the Notion Integration Token in code
- Log all AI operations for audit purposes
- Maintain referential integrity in database relations
- Request clarification if any template or property is unclear

## Testing and Validation
- Verify Notion API connections before operations
- Test template compliance before creating entries
- Validate database relations remain intact
- Check AI classification accuracy regularly

## Current Project State

### Content Created (as of 2025-07-01)
- **4 Projects** organized by business domain
- **19 Epics** organizing major initiatives
- **Stories** - Variable per epic based on requirements
- **Tasks** - Typically 5 per story, but flexible based on complexity
- **Knowledge Base** - Growing repository of reusable knowledge

### File Organization
- `/projects/` - All projects with their epics, stories, and tasks
- `/knowledge-base/` - Research, documentation, and learnings
- `/instructions/` - Comprehensive guides for all operations
- `/docs/n8n/ai-agent-guide.md` - Notion database templates and IDs
- `/ai-agent-data/` - AI-generated content and logs
- `/memory-bank/` - Project context and current state

## Common Operations

### Quick Start for New LLMs
1. Read `PROJECT-STRUCTURE.md` for complete overview
2. Review relevant `/instructions/*.md` files for the task at hand
3. Use templates from `/docs/n8n/ai-agent-guide.md`
4. Initialize Official Notion MCP with the integration token above

### Creating New Entries
- See `/instructions/CREATE-NEW-ITEMS.md` for detailed steps
- Use appropriate template from AI Agent Guide
- Maintain proper database relations
- Follow naming conventions in `PROJECT-STRUCTURE.md`

### Editing Existing Items
- See `/instructions/EDIT-EXISTING-ITEMS.md` for safe editing practices
- Check dependencies before making changes
- Document all changes with comments
- Update related items as needed

### Knowledge Base Management
- See `/instructions/KNOWLEDGE-BASE-GUIDE.md` for KB best practices
- Search existing KB before creating new entries
- Link KB entries to source Tasks/Stories/Epics
- Tag appropriately for future discovery