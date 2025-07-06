# AI-Augmented Notion Project Management System

## Overview
An AI-powered project management system that uses Notion as the UI, n8n for workflow automation, and AI for intelligent task processing and knowledge management.

## Quick Start
1. **Read First**: 
   - `CLAUDE.md` - Instructions for Claude AI
   - `PROJECT-DEFINITIONS.md` - Understanding the 3 main projects
   - `MCP-INITIALIZATION-GUIDE.md` - Setting up MCP servers

2. **For Implementation**:
   - Check `CURRENT-ACTION-ITEMS.md` for immediate tasks
   - Review `TODO-LIST-FOR-USER.md` for priority items

## Project Structure
```
/
├── claude_instructions/     # Claude AI context and templates
├── config/                 # Configuration files (API keys, etc.)
├── docs/                   # Documentation
│   ├── n8n/               # n8n workflow documentation
│   ├── mcp/               # MCP server documentation
│   └── setup/             # Setup guides
├── instructions/           # Step-by-step operation guides
├── memory-bank/           # Project context and state
└── ai-agent-data/         # AI-generated content and workflows
```

## Key Components
- **Notion Database**: Project/Epic/Story/Task hierarchy
- **n8n Workflows**: Automated inbox processing and task management
- **AI Integration**: Intelligent classification and knowledge extraction
- **MCP Servers**: Notion, Supabase, and other integrations

## Active Projects
1. **Techniq Company Building** - Business operations and development
2. **Trading Platform** - Financial markets and trading infrastructure
3. **Healthcare AI** - Medical AI products and systems

## Security Note
Remember to keep your API keys secure and never commit them to version control.

## Documentation
- `/instructions/` - How to create, edit, and manage items
- `/docs/n8n/ai-agent-guide.md` - Notion templates and database IDs
- `/claude_instructions/` - AI assistant context