# Story Suggestion Automation

Suggest the next story to work on based on priority and progress using OpenAI.

## Workflow Steps
1. Trigger: Scheduled (e.g., daily) or on new story creation
2. Query Notion Stories DB for all stories
3. Use OpenAI to analyze and suggest the next story
4. Update a 'Suggested' property or send a notification

## n8n JSON Template
```json
{
  "nodes": [
    {
      "parameters": {
        "interval": "1d"
      },
      "name": "Schedule Trigger",
      "type": "n8n-nodes-base.scheduleTrigger"
    },
    {
      "parameters": {
        "operation": "getAll",
        "databaseId": "21e0d2195e1c806a947ff1806bffa2fb"
      },
      "name": "Get Stories",
      "type": "n8n-nodes-base.notion"
    },
    {
      "parameters": {
        "model": "gpt-3.5-turbo",
        "prompt": "Given these stories with their status and priority, which should be worked on next? {{$json}}",
        "apiKey": "YOUR_OPENAI_API_KEY"
      },
      "name": "AI Suggestion",
      "type": "n8n-nodes-base.openai"
    },
    {
      "parameters": {
        "operation": "update",
        "databaseId": "21e0d2195e1c806a947ff1806bffa2fb",
        "updateFields": {
          "Suggested": "Yes"
        }
      },
      "name": "Update Notion",
      "type": "n8n-nodes-base.notion"
    }
  ]
}
```

## Usage Notes
- Replace `YOUR_OPENAI_API_KEY` with your actual key.
- Adjust Notion property names as needed.
- You can notify users via Slack/Email as an additional step. 