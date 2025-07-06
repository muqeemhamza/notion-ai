# Task Prioritization Automation

AI suggests which tasks to focus on next based on status and deadlines.

## Workflow Steps
1. Trigger: Scheduled or on new task creation
2. Query Notion Tasks DB
3. Use OpenAI to prioritize tasks
4. Update 'Next Up' property

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
        "databaseId": "21e0d2195e1c80a28c67dc2a8ed20e1b"
      },
      "name": "Get Tasks",
      "type": "n8n-nodes-base.notion"
    },
    {
      "parameters": {
        "model": "gpt-3.5-turbo",
        "prompt": "Given these tasks, their status, and deadlines, which should be prioritized? {{$json}}",
        "apiKey": "YOUR_OPENAI_API_KEY"
      },
      "name": "AI Prioritization",
      "type": "n8n-nodes-base.openai"
    },
    {
      "parameters": {
        "operation": "update",
        "databaseId": "21e0d2195e1c80a28c67dc2a8ed20e1b",
        "updateFields": {
          "Next Up": "Yes"
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