# Tech Context

## Technologies Used
- Notion (as primary UI and data store)
- Supabase (PostgreSQL-based backend)
- MCP servers (Notion, Supabase, Sequential Thinking, Filesystem, Context7, Playwright, Browserbase)
- Node.js, TypeScript, npx for server orchestration
- Cursor (AI-powered development environment)

## Development Setup
- All MCPs configured in .cursor/mcp.json
- memory-bank/ for documentation and context
- docs/mcp/ for MCP documentation
- system/ for scripts and configs

## Technical Constraints
- Notion API rate limits and permissions
- Supabase project reference and access token required
- MCP servers must be started and validated individually
- All automation must respect Notion and Supabase data models

## Dependencies
- Notion integration token (provided)
- Supabase access token (provided)
- npx and Node.js installed

---

**This file documents the technical environment and dependencies.**

---

## [2024-07-01] Story & Task Creation Process
- Story and task creation is now context-driven and flexible, with no fixed number or structure.
- See July 2024 update in `activeContext.md` and `instructions/CREATE-NEW-ITEMS.md` for details.

## [2024-07-01] Epic & Story Templates
- Epic and story templates are now comprehensive, with detailed sections for all relevant information, and are intended to be living documents.
- See July 2024 update in `CREATE-NEW-ITEMS.md` for details. 