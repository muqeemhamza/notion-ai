# Automated Progress Updates

AI drafts status updates for ongoing stories and tasks in Notion.

## Workflow Steps
1. Trigger: Scheduled or on status change
2. Get current status and history
3. Use OpenAI to draft a status update
4. Update Notion with the draft

## n8n JSON Template
```json
{
  "nodes": [
    {
      "parameters": {
        "operation": "updateTrigger"
      },
      "name": "Notion Status Change Trigger",
      "type": "n8n-nodes-base.notionTrigger"
    },
    {
      "parameters": {
        "operation": "get",
        "databaseId": "21e0d2195e1c806a947ff1806bffa2fb"
      },
      "name": "Get Story/Task Status",
      "type": "n8n-nodes-base.notion"
    },
    {
      "parameters": {
        "model": "gpt-3.5-turbo",
        "prompt": "Draft a status update for this story/task: {{$json[\"content\"]}}",
        "apiKey": "YOUR_OPENAI_API_KEY"
      },
      "name": "AI Draft Status Update",
      "type": "n8n-nodes-base.openai"
    },
    {
      "parameters": {
        "operation": "update",
        "databaseId": "21e0d2195e1c806a947ff1806bffa2fb",
        "updateFields": {
          "Status Update": "{{$json[\"choices\"][0][\"text\"]}}"
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
- This workflow can be extended to notify stakeholders. 