# MCP Server Initialization Guide

## Current Status
- ✅ MCP configurations are properly set up in `.cursor/mcp.json`
- ⚠️ MCP servers need to be initialized within your IDE (Cursor)
- ✅ n8n Docker containers have been restarted and are starting up
- ❌ MCP tools are not yet available in the current session

## Required Steps to Initialize MCP Servers

### Step 1: Restart Your Cursor IDE
**This is the most important step!**

1. **Save all your work**
2. **Completely quit Cursor** (Cmd+Q on Mac)
3. **Reopen Cursor** and open this project
4. **Wait for MCP servers to initialize** (usually takes 10-30 seconds)

### Step 2: Verify MCP Initialization
After restarting Cursor, you should see:
- MCP status indicators in the Cursor status bar
- New tools available when interacting with Claude

### Step 3: Test MCP Functionality
Once Cursor is restarted, ask Claude to:
1. "List available MCP tools" - You should see Notion, Supabase, n8n tools
2. "Query the Notion Projects database" - This will test Notion MCP
3. "Check n8n workflow status" - This will test n8n MCP

## What Happens During Initialization

When Cursor starts with the `.cursor/mcp.json` configuration:

1. **Notion MCP** connects using your API key and provides tools for:
   - Querying databases
   - Creating/updating pages
   - Managing content

2. **Supabase MCP** connects to your project and provides:
   - Database query tools
   - Data manipulation capabilities
   - Real-time features

3. **n8n MCP** uses Docker containers to provide:
   - Workflow execution
   - Automation triggers
   - Integration capabilities

4. **Other MCPs** provide:
   - File system access
   - Browser automation
   - Sequential thinking capabilities

## Troubleshooting

### If MCP tools don't appear after restart:

1. **Check Cursor Console** (View → Output → Select "MCP" from dropdown)
2. **Verify API Keys** in `.cursor/mcp.json`:
   ```json
   "NOTION_API_KEY": "ntn_f35248778523jpOe6IQngDnseZlexMBsf2YC7jt6WEb9NF"
   "SUPABASE_ACCESS_TOKEN": "sbp_1118d8cba6b43d7752083dd01f0b5d1d0befb270"
   ```

3. **Check Docker** for n8n:
   ```bash
   docker ps | grep n8n-mcp
   ```

4. **Network Issues**: Ensure you have internet connectivity

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| MCP tools not showing | Restart Cursor completely |
| n8n containers unhealthy | Already restarted, wait 2-3 minutes |
| Notion connection fails | Verify API key is valid |
| Supabase timeout | Check project reference and token |

## Next Steps After Initialization

Once MCP servers are initialized:

1. **Test Notion Integration**:
   - Query existing projects
   - Create a test task
   - Update task status

2. **Test n8n Workflows**:
   - Trigger a test workflow
   - Check automation status

3. **Test Supabase**:
   - Query backend data
   - Test data synchronization

## Important Notes

- **MCP initialization is session-based**: You need to restart Cursor to load MCP servers
- **The current Claude session cannot initialize MCPs**: This must be done at the IDE level
- **Configuration is already complete**: No need to modify `.cursor/mcp.json`
- **Docker containers are running**: n8n containers are restarting and should be healthy soon

## Quick Commands for Verification

After restarting Cursor, you can use these commands to verify:

```bash
# Check n8n container health
docker ps | grep n8n-mcp

# Test Notion API directly (optional)
curl -X POST https://api.notion.com/v1/databases/2200d219-5e1c-81e4-9522-fba13a081601/query \
  -H "Authorization: Bearer ntn_f35248778523jpOe6IQngDnseZlexMBsf2YC7jt6WEb9NF" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json"
```

---

**ACTION REQUIRED**: Please restart Cursor now to initialize the MCP servers!