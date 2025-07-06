# Inbox Note Classification (AI)

Automatically classify new Inbox notes in Notion using OpenAI and update the database with the predicted category.

## Workflow Steps
1. Trigger: Notion 'New Database Item' (Inbox DB)
2. Get note content from Notion
3. Send content to OpenAI for classification
4. Update Notion item with AI-predicted category

## n8n JSON Template
```json
{
  "nodes": [
    {
      "parameters": {
        "databaseId": "21e0d2195e1c80228d8cf8ffd2a27275"
      },
      "name": "Notion Trigger",
      "type": "n8n-nodes-base.notionTrigger"
    },
    {
      "parameters": {
        "operation": "get",
        "databaseId": "21e0d2195e1c80228d8cf8ffd2a27275"
      },
      "name": "Get Note Content",
      "type": "n8n-nodes-base.notion"
    },
    {
      "parameters": {
        "model": "gpt-3.5-turbo",
        "prompt": "Classify this note into one of: [To Convert, Sticky, Archive, Other]. Note: {{$json[\"content\"]}}",
        "apiKey": "YOUR_OPENAI_API_KEY"
      },
      "name": "Classify with OpenAI",
      "type": "n8n-nodes-base.openai"
    },
    {
      "parameters": {
        "operation": "update",
        "databaseId": "21e0d2195e1c80228d8cf8ffd2a27275",
        "updateFields": {
          "Category": "{{$json[\"choices\"][0][\"text\"]}}"
        }
      },
      "name": "Update Notion Category",
      "type": "n8n-nodes-base.notion"
    }
  ]
}
```

## Usage Notes
- Replace `YOUR_OPENAI_API_KEY` with your actual key.
- Adjust Notion property names as needed.
- This workflow can be extended to trigger notifications or further automations. 