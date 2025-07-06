# Notion Database IDs and Structure

## Database IDs
- **Projects DB**: `2200d219-5e1c-81e4-9522-fba13a081601`
- **Epics DB**: `21e0d2195e1c809bae77f183b66a78b2`
- **Stories DB**: `21e0d2195e1c806a947ff1806bffa2fb`
- **Tasks DB**: `21e0d2195e1c80a28c67dc2a8ed20e1b`
- **Inbox DB**: `21e0d2195e1c80228d8cf8ffd2a27275`
- **Knowledge Base DB**: `21e0d2195e1c802ca067e05dd1e4e908`

## Database Relationships
1. **Project → Epic** (one-to-many)
   - Epic has "Project" relation property
   
2. **Epic → Story** (one-to-many)
   - Story has "Epic" relation property
   
3. **Story → Task** (one-to-many)
   - Task has "Related Story" relation property
   
4. **All → Knowledge Base** (many-to-many)
   - All databases have "Knowledge Base" relation property
   
5. **Inbox → All** (conversion flow)
   - Inbox items convert to Tasks, Stories, or Knowledge

## Required Properties

### All Databases Share
- **Status** (Select)
- **Priority** (Select: Low, Medium, High, Critical)
- **Tags** (Multi-select)
- **Created Date** (Created time)
- **Last Updated** (Last edited time)
- **AI Confidence** (Number/Percent) - For AI-created items
- **Knowledge Base** (Relation)

### Inbox Specific Properties
- **Note** (Title)
- **Processing Status** (Select: Draft, Pending Approval, Approved, Processing, Completed, Rejected)
- **AI Action Plan** (Rich text)
- **User Feedback** (Rich text)
- **Approval Actions** (Select: Approve ✅, Update Entry 📝, Discard ❌)
- **Processing Attempts** (Number)
- **Confidence Reasoning** (Rich text)
- **Confidence Visual** (Formula)
- **Action Required** (Formula)