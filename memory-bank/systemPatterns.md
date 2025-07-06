# System Patterns

## Architecture Overview
- Modular, microservices-inspired architecture using MCP (Multi-Component Prompting) servers
- Notion as the primary data store and UI for PMS and Knowledge Base
- Supabase for structured data and advanced querying
- AI/automation layer for classification, linking, and knowledge generation

## Key Technical Decisions
- Use of Notion MCP for direct Notion API integration
- Supabase MCP for scalable, real-time database operations
- Sequential Thinking MCP for multi-step reasoning and automation
- Filesystem, Context7, Playwright, and Browserbase MCPs for extensibility
- Memory bank for persistent project context and documentation

## Design Patterns
- Separation of concerns: each MCP handles a specific domain
- Event-driven automation: triggers for note classification, task completion, epic retrospectives
- Centralized documentation and context management (memory-bank)
- Scalable, testable, and robust system design

---

**This file documents the system architecture and key patterns.**

## [2024-07-01] Story & Task Creation Pattern
- Story and task creation now follows a context-driven, flexible pattern based on real requirements, not a fixed template.
- See July 2024 update in `activeContext.md` and `instructions/CREATE-NEW-ITEMS.md` for details.

## [2024-07-01] Epic & Story Templates
- Epic and story templates are now comprehensive, with detailed sections for all relevant information, and are intended to be living documents.
- See July 2024 update in `CREATE-NEW-ITEMS.md` for details. 