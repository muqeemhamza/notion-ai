# MCP Server Initialization Instructions

## Important Note
MCP servers need to be initialized within your development environment (VS Code, Cursor, etc.). 
The `.cursor/mcp.json` configuration file is already set up correctly.

## For Cursor IDE Users

1. **Restart Cursor**: Close and reopen Cursor to reload MCP configurations
2. **Check MCP Status**: In Cursor, you should see MCP indicators in the status bar
3. **Verify Connection**: The MCP servers should automatically connect on startup

## For VS Code Users with Continue Extension

1. **Install Continue Extension** if not already installed
2. **Configure MCP**: Copy the MCP configuration from `.cursor/mcp.json` to your Continue config
3. **Restart VS Code**

## Manual Testing

After initialization, you can test the MCP servers:

### Test Notion MCP
In your AI assistant, you should now have access to Notion tools like:
- Query databases
- Create pages
- Update content

### Test Supabase MCP
Supabase tools should be available for:
- Database queries
- Data manipulation
- Real-time subscriptions

### Test n8n MCP
n8n workflow tools should allow:
- Triggering workflows
- Getting workflow status
- Managing automations

## Troubleshooting

### If MCP servers don't appear:
1. Check the logs in your IDE's output panel
2. Verify all API keys and tokens are correct
3. Ensure network connectivity to external services
4. Try restarting your IDE again

### For n8n Docker issues:
```bash
# Stop all n8n containers
docker stop $(docker ps -q --filter "ancestor=ghcr.io/czlonkowski/n8n-mcp:latest")

# Remove them
docker rm $(docker ps -aq --filter "ancestor=ghcr.io/czlonkowski/n8n-mcp:latest")

# The MCP server will recreate them on next use
```

### Environment Variables
Make sure these are set in your `.cursor/mcp.json`:
- NOTION_API_KEY
- SUPABASE_ACCESS_TOKEN
- N8N_API_KEY
- BROWSERBASE_API_KEY (if using Browserbase)
