# Claude Instructions for Notion AI Project

## Purpose
This folder contains all essential context and instructions for Claude Desktop Projects to work with the Notion AI Project Management System. Copy this entire folder to any Claude project that needs to interact with Notion databases.

## File Structure

### Core Context
- **PROJECT-CONTEXT.md** - System overview and active projects
- **NOTION-DATABASE-IDS.md** - All database IDs and relationships
- **TEMPLATES.md** - Exact templates for each item type
- **QUICK-REFERENCE.md** - Common operations and values

### Technical Guides
- **NOTION-API-USAGE.md** - API patterns and code examples
- **INBOX-WORKFLOW.md** - Detailed inbox processing logic

## Quick Start

1. **Initialize Notion Connection**
   ```bash
   # Use the official Notion MCP
   # Integration Token: ntn_f35248778523jpOe6IQngDnseZlexMBsf2YC7jt6WEb9NF
   ```

2. **Understand the Hierarchy**
   ```
   Project → Epic → Story → Task
   ```

3. **Always Search First**
   - Check Knowledge Base before creating new items
   - Look for existing items to update/link

4. **Use Templates Exactly**
   - Never modify the provided templates
   - All fields are required

5. **Maintain Relations**
   - Every child must link to its parent
   - Knowledge Base links to everything

## Key Operations

### Creating Items
1. Search for existing first
2. Use the appropriate template
3. Set all required properties
4. Link to parent item
5. Add relevant tags

### Processing Inbox
1. AI analyzes and classifies
2. Calculates confidence score
3. User reviews and approves
4. Item created if approved
5. Inbox marked complete

### Knowledge Management
1. Capture reusable information
2. Link to source items
3. Tag for discovery
4. Keep updated

## Database IDs Quick Reference
- Projects: `2200d219-5e1c-81e4-9522-fba13a081601`
- Epics: `21e0d2195e1c809bae77f183b66a78b2`
- Stories: `21e0d2195e1c806a947ff1806bffa2fb`
- Tasks: `21e0d2195e1c80a28c67dc2a8ed20e1b`
- Inbox: `21e0d2195e1c80228d8cf8ffd2a27275`
- Knowledge Base: `21e0d2195e1c802ca067e05dd1e4e908`

## Important Notes

1. **Template Fidelity** - Use templates exactly as provided
2. **Search First** - Always check for existing items
3. **Link Everything** - Maintain relationships
4. **Capture Knowledge** - Document as you work
5. **AI Confidence** - Add for AI-generated items

## Updates
When updating this folder:
1. Keep all files in sync
2. Test changes before copying
3. Document any new patterns
4. Maintain backwards compatibility

---

*Last Updated: [Current Date]*
*Version: 1.0*