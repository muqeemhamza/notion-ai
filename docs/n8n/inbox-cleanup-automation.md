# AI-powered Inbox Cleanup

Suggests archiving or converting old notes in the Notion Inbox using OpenAI.

## Workflow Steps
1. Trigger: Scheduled (e.g., weekly)
2. Query Inbox for old notes
3. Use OpenAI to suggest action
4. Update Notion or send notification

## n8n JSON Template
```json
{
  "nodes": [
    {
      "parameters": {
        "interval": "1w"
      },
      "name": "Weekly Schedule Trigger",
      "type": "n8n-nodes-base.scheduleTrigger"
    },
    {
      "parameters": {
        "operation": "getAll",
        "databaseId": "21e0d2195e1c80228d8cf8ffd2a27275"
      },
      "name": "Get Old Inbox Notes",
      "type": "n8n-nodes-base.notion"
    },
    {
      "parameters": {
        "model": "gpt-3.5-turbo",
        "prompt": "For each of these notes, suggest whether to archive, convert, or keep. {{$json}}",
        "apiKey": "YOUR_OPENAI_API_KEY"
      },
      "name": "AI Suggest Cleanup",
      "type": "n8n-nodes-base.openai"
    },
    {
      "parameters": {
        "operation": "update",
        "databaseId": "21e0d2195e1c80228d8cf8ffd2a27275",
        "updateFields": {
          "Cleanup Suggestion": "{{$json[\"choices\"][0][\"text\"]}}"
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
- You can add notifications or further automations as needed. 