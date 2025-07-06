# [LAUNCH] Cursor Code MCP Setup Guide

## Overview
This guide shows how to use MCP (Model Context Protocol) servers with **Cursor Code** terminal/chat, not Claude Desktop.

## Current Setup Status
- [DONE] **Notion Integration**: Fully working
- [DONE] **n8n API**: Connected and functional
- [DONE] **n8n Production Webhook**: Active (SSE endpoint working)
- [DONE] **Docker**: Installed and ready
- [DONE] **Supabase**: Configured
- [DONE] **ChatGPT**: API ready

## How MCP Works in Cursor Code

Unlike Claude Desktop which requires a global config file, Cursor Code uses a project-specific configuration:

1. **Configuration Location**: `.cursor/mcp.json` (in your project root)
2. **Integration Method**: Through Cursor's Claude integration
3. **Server Management**: Cursor handles server lifecycle automatically

## Your Current Configuration

Your `.cursor/mcp.json` includes these servers:

### 1. Notion MCP
```json
{
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-notion"],
  "env": {
    "NOTION_API_KEY": "ntn_f35248778523jpOe6IQngDnseZlexMBsf2YC7jt6WEb9NF"
  }
}
```

### 2. n8n MCP
```json
{
  "command": "docker",
  "args": ["run", "-i", "--rm", "--pull=always", 
           "-e", "N8N_API_KEY=n8n_api_b9...",
           "-e", "N8N_BASE_URL=https://techniq.app.n8n.cloud",
           "-e", "MCP_PRODUCTION_URL=https://techniq.app.n8n.cloud/mcp/...",
           "ghcr.io/cloudmachine-ai/n8n-mcp:latest"]
}
```

### 3. Supabase MCP
```json
{
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-supabase", 
           "zzmancxxkpwdqjuworvfq", 
           "supabase_access_token_here"]
}
```

### 4. Other Servers
- Sequential Thinking MCP
- Filesystem MCP
- Context7
- Playwright MCP
- Browserbase MCP
- ChatGPT (OpenAI)

## Using MCP in Cursor

### 1. Start a Claude Chat
- Open Cursor Code
- Press `Cmd+K` (Mac) or `Ctrl+K` (Windows/Linux)
- Select "Claude" as your model

### 2. MCP Commands Available
When MCP servers are active, you can use these commands:

**Notion Operations:**
- Query databases
- Create pages
- Update content
- Search across workspace

**n8n Operations:**
- List workflows
- Execute workflows
- Check execution history
- Monitor webhook status

**Supabase Operations:**
- Query database tables
- Insert/update records
- Manage data

### 3. Example Commands

```bash
# List all projects in Notion
"Show me all projects in the Notion Projects database"

# Create a new task
"Create a new task in Notion for implementing user authentication"

# Execute n8n workflow
"Run the Notion Workflow in n8n"

# Query Supabase
"Get all records from the users table in Supabase"
```

## Troubleshooting

### If MCP servers don't respond:
1. Check Docker is running: `docker ps`
2. Verify config exists: `ls -la .cursor/mcp.json`
3. Restart Cursor Code
4. Check server logs in Cursor's output panel

### Common Issues:
- **"MCP server not found"**: Ensure `.cursor/mcp.json` exists
- **"Docker not running"**: Start Docker Desktop
- **"API key invalid"**: Check your API keys in the config

## Next Steps

1. **Test Notion**: Try querying your databases
2. **Test n8n**: List available workflows
3. **Activate Workflows**: Turn on your 2 inactive n8n workflows
4. **Build Automations**: Start implementing AI features

## Quick Test Commands

1. **Notion Test**:
   ```
   "List all items in the Notion Inbox database"
   ```

2. **n8n Test**:
   ```
   "Show me all workflows in n8n"
   ```

3. **Combined Test**:
   ```
   "Create a test entry in Notion Inbox and then execute the Notion Workflow in n8n"
   ```

---

## Important Notes

- No need to copy configs to Claude Desktop locations
- MCP servers start automatically when you use Claude in Cursor
- All configurations are project-specific
- Server logs appear in Cursor's output panel

## Support

If you encounter issues:
1. Check the `.cursor/mcp.json` file for syntax errors
2. Ensure all API keys are valid
3. Verify Docker is installed and running
4. Check network connectivity to external services