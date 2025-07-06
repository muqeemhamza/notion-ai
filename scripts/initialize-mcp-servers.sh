#!/bin/bash

# MCP Server Initialization Script
# This script helps initialize all configured MCP servers

echo "🚀 MCP Server Initialization Script"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Change to project directory
cd "$(dirname "$0")/.." || exit

echo "📁 Working directory: $(pwd)"
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command_exists npx; then
    echo -e "${RED}❌ npx not found. Please install Node.js/npm first.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ npx found${NC}"
fi

if ! command_exists docker; then
    echo -e "${RED}❌ Docker not found. Please install Docker first.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Docker found${NC}"
fi

echo ""

# Test Notion MCP
echo "1️⃣ Testing Notion MCP Server..."
echo "Testing with: npx -y @notionhq/notion-mcp-server --version"
timeout 30s npx -y @notionhq/notion-mcp-server --version 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Notion MCP server is accessible${NC}"
else
    echo -e "${YELLOW}⚠️  Notion MCP server test failed or timed out${NC}"
fi
echo ""

# Test Supabase MCP
echo "2️⃣ Testing Supabase MCP Server..."
echo "Testing with: npx -y @supabase/mcp-server-supabase@latest --version"
timeout 30s npx -y @supabase/mcp-server-supabase@latest --version 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Supabase MCP server is accessible${NC}"
else
    echo -e "${YELLOW}⚠️  Supabase MCP server test failed or timed out${NC}"
fi
echo ""

# Check n8n Docker containers
echo "3️⃣ Checking n8n MCP Docker Containers..."
n8n_containers=$(docker ps --filter "ancestor=ghcr.io/czlonkowski/n8n-mcp:latest" --format "table {{.ID}}\t{{.Status}}\t{{.Names}}")
if [ -n "$n8n_containers" ]; then
    echo -e "${GREEN}✅ n8n containers found:${NC}"
    echo "$n8n_containers"
    
    # Check for unhealthy containers
    unhealthy_count=$(docker ps --filter "ancestor=ghcr.io/czlonkowski/n8n-mcp:latest" --filter "health=unhealthy" -q | wc -l)
    if [ $unhealthy_count -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Found $unhealthy_count unhealthy n8n containers${NC}"
        echo "Attempting to restart unhealthy containers..."
        docker restart $(docker ps --filter "ancestor=ghcr.io/czlonkowski/n8n-mcp:latest" --filter "health=unhealthy" -q)
    fi
else
    echo -e "${YELLOW}⚠️  No n8n containers found${NC}"
fi
echo ""

# Test other MCP servers
echo "4️⃣ Testing other MCP servers..."

# Sequential Thinking
echo "Testing Sequential Thinking MCP..."
timeout 10s npx -y @modelcontextprotocol/server-sequential-thinking@latest --version 2>/dev/null
[ $? -eq 0 ] && echo -e "${GREEN}✅ Sequential Thinking MCP accessible${NC}" || echo -e "${YELLOW}⚠️  Sequential Thinking MCP test failed${NC}"

# Filesystem MCP
echo "Testing Filesystem MCP..."
timeout 10s npx -y @modelcontextprotocol/server-filesystem@latest --version 2>/dev/null
[ $? -eq 0 ] && echo -e "${GREEN}✅ Filesystem MCP accessible${NC}" || echo -e "${YELLOW}⚠️  Filesystem MCP test failed${NC}"

echo ""

# Create initialization instructions
cat > mcp-init-instructions.md << 'EOF'
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
EOF

echo -e "${GREEN}✅ Created mcp-init-instructions.md${NC}"
echo ""

# Summary
echo "📋 Summary"
echo "=========="
echo "1. MCP configuration file exists at: .cursor/mcp.json"
echo "2. Some MCP servers are accessible via npx"
echo "3. n8n Docker containers may need attention"
echo "4. Please follow the instructions in mcp-init-instructions.md"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: MCP servers must be initialized from within your IDE${NC}"
echo -e "${YELLOW}   Please restart Cursor/VS Code to load the MCP configurations${NC}"