# Sync Guide: Main Project ↔ Claude Instructions

## What to Keep Synchronized

### 1. Database IDs
**Source**: `/docs/n8n/ai-agent-guide.md`
**Target**: `NOTION-DATABASE-IDS.md`
- All database IDs
- Any new databases added
- Relationship changes

### 2. Templates
**Source**: `/docs/n8n/ai-agent-guide.md`
**Target**: `TEMPLATES.md`
- Task template
- Story template
- Epic template
- Knowledge Base template
- Inbox template

### 3. Property Updates
**Source**: `/docs/setup/notion-inbox-setup-guide.md`
**Target**: `NOTION-DATABASE-IDS.md`
- New properties added
- Property type changes
- Required vs optional

### 4. Workflow Logic
**Source**: `/docs/n8n/intelligent-inbox-workflow-v2.md`
**Target**: `INBOX-WORKFLOW.md`
- Processing flow changes
- Confidence score adjustments
- Classification logic updates

### 5. Project Definitions
**Source**: `/PROJECT-DEFINITIONS.md`
**Target**: `PROJECT-CONTEXT.md`
- New projects added
- Project scope changes
- Active project updates

## Sync Checklist

When making changes in main project:

- [ ] Update database IDs if changed
- [ ] Copy template modifications
- [ ] Sync new properties
- [ ] Update workflow descriptions
- [ ] Reflect project changes
- [ ] Test in Claude Desktop
- [ ] Version bump in README

## Files That Don't Need Sync

These are unique to claude_instructions:
- `README.md` - Specific to this folder
- `QUICK-REFERENCE.md` - Simplified for Claude
- `NOTION-API-USAGE.md` - Claude-specific examples
- `SYNC-GUIDE.md` - This file

## Automated Sync Script

```bash
#!/bin/bash
# sync-claude-instructions.sh

MAIN_DIR="/Users/hamza/Desktop/AI Notion"
CLAUDE_DIR="$MAIN_DIR/claude_instructions"

echo "Syncing Database IDs..."
# Extract database IDs from ai-agent-guide.md and update NOTION-DATABASE-IDS.md

echo "Syncing Templates..."
# Extract templates from ai-agent-guide.md and update TEMPLATES.md

echo "Syncing Project Context..."
# Copy relevant sections from PROJECT-DEFINITIONS.md to PROJECT-CONTEXT.md

echo "Sync complete!"
```

## Manual Sync Process

1. **Review Changes**
   ```bash
   cd /Users/hamza/Desktop/AI\ Notion
   git diff docs/n8n/ai-agent-guide.md
   git diff PROJECT-DEFINITIONS.md
   ```

2. **Update Claude Instructions**
   - Open both source and target files
   - Copy changed sections
   - Maintain Claude-specific formatting

3. **Test in Claude Desktop**
   - Copy folder to test project
   - Verify all operations work
   - Check template compliance

4. **Commit Changes**
   ```bash
   git add claude_instructions/
   git commit -m "Sync claude_instructions with main project updates"
   ```

## Version Tracking

Track versions in README.md:
```markdown
*Last Updated: 2024-01-15*
*Version: 1.1*
*Changes: Added new inbox properties*
```

## Important Notes

1. **Don't Over-Sync** - Keep Claude instructions focused and simple
2. **Test First** - Verify changes work in Claude Desktop
3. **Document Changes** - Note what was updated and why
4. **Preserve Simplicity** - Claude instructions should be cleaner than main docs