# Knowledge Reuse Suggestion

AI recommends relevant knowledge entries for current stories/tasks in Notion.

## Workflow Steps
1. Trigger: On story/task update
2. Get story/task content
3. Query Knowledge Base DB
4. Use OpenAI to match relevant knowledge
5. Update story/task with recommended knowledge links

## n8n JSON Template
```json
{
  "nodes": [
    {
      "parameters": {
        "operation": "updateTrigger"
      },
      "name": "Notion Update Trigger",
      "type": "n8n-nodes-base.notionTrigger"
    },
    {
      "parameters": {
        "operation": "get",
        "databaseId": "21e0d2195e1c806a947ff1806bffa2fb"
      },
      "name": "Get Story/Task Content",
      "type": "n8n-nodes-base.notion"
    },
    {
      "parameters": {
        "operation": "getAll",
        "databaseId": "21e0d2195e1c802ca067e05dd1e4e908"
      },
      "name": "Get Knowledge Entries",
      "type": "n8n-nodes-base.notion"
    },
    {
      "parameters": {
        "model": "gpt-3.5-turbo",
        "prompt": "Given this story/task and these knowledge entries, recommend the most relevant ones. Story/Task: {{$json[\"content\"]}} Knowledge: {{$json[\"knowledge\"]}}",
        "apiKey": "YOUR_OPENAI_API_KEY"
      },
      "name": "AI Knowledge Match",
      "type": "n8n-nodes-base.openai"
    },
    {
      "parameters": {
        "operation": "update",
        "databaseId": "21e0d2195e1c806a947ff1806bffa2fb",
        "updateFields": {
          "Recommended Knowledge": "{{$json[\"choices\"][0][\"text\"]}}"
        }
      },
      "name": "Update Story/Task",
      "type": "n8n-nodes-base.notion"
    }
  ]
}
```

## Usage Notes
- Replace `YOUR_OPENAI_API_KEY` with your actual key.
- Adjust Notion property names as needed.
- This workflow can be adapted for both stories and tasks. 