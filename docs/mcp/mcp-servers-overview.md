# MCP Servers Overview and Setup Guide

## Overview
This document explains the Model Context Protocol (MCP) servers configured for the AI Notion Project Management System. These servers enable AI agents to interact with various services and tools programmatically.

## Configured MCP Servers

### 1. Notion MCP Server (Official)
**Purpose**: Provides comprehensive Notion API access for database operations, page management, and content manipulation.

**Configuration**:
```json
{
  "command": "npx",
  "args": ["-y", "@notionhq/notion-mcp-server"],
  "env": {
    "NOTION_API_KEY": "ntn_f35248778523jpOe6IQngDnseZlexMBsf2YC7jt6WEb9NF"
  }
}
```

**Key Features**:
- Full CRUD operations on Notion databases
- Page creation and management
- Database querying and filtering
- Content block manipulation
- Property updates and relations management

**Database IDs**:
- Projects DB: `2200d219-5e1c-81e4-9522-fba13a081601`
- Epics DB: `21e0d2195e1c809bae77f183b66a78b2`
- Stories DB: `21e0d2195e1c806a947ff1806bffa2fb`
- Tasks DB: `21e0d2195e1c80a28c67dc2a8ed20e1b`
- Inbox DB: `21e0d2195e1c80228d8cf8ffd2a27275`
- Knowledge Base DB: `21e0d2195e1c802ca067e05dd1e4e908`

### 2. Supabase MCP Server
**Purpose**: Backend database operations and data persistence outside of Notion.

**Configuration**:
```json
{
  "command": "npx",
  "args": ["-y", "@supabase/mcp-server-supabase@latest", "--project-ref=zzmancxxkpwdqjuworvfq"],
  "env": {
    "SUPABASE_ACCESS_TOKEN": "sbp_1118d8cba6b43d7752083dd01f0b5d1d0befb270"
  }
}
```

### 3. n8n MCP Server (Docker)
**Purpose**: Workflow automation and integration with n8n workflows.

**Configuration**:
```json
{
  "command": "docker",
  "args": [
    "run", "-i", "--rm",
    "-e", "MCP_MODE=stdio",
    "-e", "LOG_LEVEL=error",
    "-e", "DISABLE_CONSOLE_OUTPUT=true",
    "-e", "N8N_API_URL=https://techniq.app.n8n.cloud/mcp/a8dd0882-2b3b-4e03-ba8d-26721908a89b/sse",
    "-e", "N8N_API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjNDhlYjhmMC0wODM2LTRmOTMtYTRmMC1lN2EwZGE1MmI1MGMiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzUxNDk1MDg1fQ.1bTzsZ3hQOuwcC98EviAQsvTbmljz1NHDwH66C3v4Go",
    "ghcr.io/czlonkowski/n8n-mcp:latest"
  ]
}
```

**Status**: Docker image available locally

### 4. Sequential Thinking MCP
**Purpose**: Provides structured thinking and reasoning capabilities for complex problem-solving.

**Configuration**:
```json
{
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-sequential-thinking@latest"]
}
```

### 5. Filesystem MCP
**Purpose**: Local file system operations within the project directory.

**Configuration**:
```json
{
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem@latest", "/Users/hamza/Desktop/AI Notion"]
}
```

### 6. Context7 MCP
**Purpose**: Advanced context management and state preservation.

**Configuration**:
```json
{
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-context7@latest"]
}
```

### 7. Playwright MCP
**Purpose**: Browser automation and web scraping capabilities.

**Configuration**:
```json
{
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-playwright@latest"]
}
```

### 8. Browserbase MCP
**Purpose**: Cloud browser infrastructure for scalable web automation.

**Configuration**:
```json
{
  "command": "npx",
  "args": ["-y", "@browserbasehq/mcp"],
  "env": {
    "BROWSERBASE_API_KEY": "bb_live_c0T2_8iqIphqXkaTd238Ygq0kGA",
    "BROWSERBASE_PROJECT_ID": "90e69ae4-5e03-4192-be82-8f52a64836d7"
  }
}
```

### 9. Docker MCP
**Purpose**: Docker container management and operations.

**Configuration**:
```json
{
  "command": "uvx",
  "args": ["docker-mcp"]
}
```

## Usage Guidelines

### Primary Operations Flow
1. **Notion MCP**: Primary interface for all Notion operations
2. **n8n MCP**: Workflow automation and complex integrations
3. **Supabase MCP**: Backend data operations and analytics
4. **Other MCPs**: Supporting tools for specific tasks

### Best Practices
1. Always use the official Notion MCP for Notion operations
2. Refer to `/docs/n8n/ai-agent-guide.md` for database schemas and templates
3. Follow the project hierarchy: Projects → Epics → Stories → Tasks
4. Maintain proper tagging and categorization
5. Link all items to the Knowledge Base appropriately

### Common Operations
- **Create new items**: Use Notion MCP with templates from ai-agent-guide.md
- **Query databases**: Use Notion MCP's query capabilities
- **Automate workflows**: Use n8n MCP for complex automations
- **File operations**: Use Filesystem MCP for local file management
- **Web automation**: Use Playwright or Browserbase MCP

## Troubleshooting

### MCP Server Issues
1. Verify the server configuration in `.cursor/mcp.json`
2. Check environment variables are correctly set
3. Ensure Docker is running for n8n MCP
4. Use `npx` commands to test server availability

### Connection Issues
- Notion API: Verify the integration token is valid
- Supabase: Check access token and project reference
- n8n: Ensure the API URL and key are current
- Docker: Verify Docker daemon is running

## Security Notes
- Never expose API keys or tokens in code
- Use environment variables for sensitive data
- Regularly rotate access tokens
- Monitor API usage for anomalies