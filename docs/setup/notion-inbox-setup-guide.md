# Notion Inbox Database Setup Guide

## Overview
This guide provides step-by-step instructions for setting up the Inbox database in Notion with all required properties for the AI-powered workflow system.

---

## Required Database Properties

### 1. Add These Properties to Your Inbox Database

Navigate to your Inbox database (ID: `21e0d2195e1c80228d8cf8ffd2a27275`) and add the following properties:

#### Core Processing Properties

1. **AI Confidence**
   - Type: `Number`
   - Format: `Percent`
   - Description: Shows AI's confidence in its analysis (0-100%)
   - Default: Leave empty

2. **Processing Status**
   - Type: `Select`
   - Options (add in this order with colors):
     - `Draft` (Gray) 
     - `Pending Approval` (Yellow)
     - `Approved` (Green)
     - `Processing` (Blue)
     - `Completed` (Dark Green)
     - `Rejected` (Red)
   - Default: `Draft`

3. **AI Action Plan**
   - Type: `Text` (Long text/Rich text)
   - Description: Stores the formatted analysis and action plan from AI
   - Allow rich text formatting

4. **User Feedback**
   - Type: `Text` (Long text/Rich text)
   - Description: Captures user corrections and additional context
   - Allow rich text formatting

5. **Approval Actions**
   - Type: `Select`
   - Options:
     - `Approve ✅`
     - `Update Entry 📝`
     - `Discard ❌`
   - Default: Leave empty
   - Note: This should clear after processing

6. **Processing Attempts**
   - Type: `Number`
   - Format: `Number` (not percentage)
   - Default: `0`
   - Description: Tracks how many times the item has been analyzed

7. **Confidence Reasoning**
   - Type: `Text` (Long text/Rich text)
   - Description: Explains why AI has the given confidence level

#### Visual Indicator Formulas

8. **Confidence Visual** (Formula Property)
   - Type: `Formula`
   - Formula:
   ```
   if(prop("AI Confidence") >= 0.9, "🟢 Very High",
   if(prop("AI Confidence") >= 0.7, "🟡 High",
   if(prop("AI Confidence") >= 0.5, "🟠 Medium",
   if(prop("AI Confidence") >= 0.3, "🔴 Low",
   if(prop("AI Confidence") > 0, "⚫ Very Low", "⚪ Not Analyzed")))))
   ```

9. **Action Required** (Formula Property)
   - Type: `Formula`
   - Formula:
   ```
   if(prop("Processing Status") == "Pending Approval", "🔔 Action Required",
   if(prop("Processing Status") == "Draft", "📝 Add Context",
   if(prop("Processing Status") == "Processing", "⏳ Processing...",
   if(prop("Processing Status") == "Completed", "✅ Complete",
   if(prop("Processing Status") == "Rejected", "❌ Rejected", "")))))
   ```

---

## Database Views Setup

### 1. 📋 Approval Queue View
Create a new table view with these settings:

**View Name**: `📋 Approval Queue`

**Filter**:
- Processing Status is `Pending Approval`

**Sort**:
1. AI Confidence (Descending)
2. Created Date (Ascending)

**Properties to Show** (in order):
1. Note (Title)
2. Confidence Visual
3. AI Confidence
4. Action Required
5. AI Action Plan (show first 100 chars)
6. Approval Actions
7. Priority
8. Created Date

**Property Widths**:
- Note: 300px
- Confidence Visual: 120px
- AI Confidence: 80px
- Approval Actions: 150px

### 2. 📝 Drafts View
Create a table view for low-confidence items:

**View Name**: `📝 Drafts`

**Filter**:
- Processing Status is `Draft`

**Sort**:
- Created Date (Descending)

**Properties to Show**:
1. Note
2. Confidence Visual
3. User Feedback
4. Processing Attempts
5. Created Date
6. AI Action Plan

### 3. 🎯 Processing Dashboard
Create a board/gallery view:

**View Name**: `🎯 Processing Dashboard`

**Group By**: Processing Status

**Card Cover**: None

**Card Properties**:
1. Confidence Visual (Large/Title size)
2. AI Confidence
3. Priority
4. Created Date

**Card Preview**: First 200 chars of AI Action Plan

### 4. ✅ Completed Items
**View Name**: `✅ Completed Items`

**Filter**:
- Processing Status is `Completed`

**Sort**:
- Last Edited Time (Descending)

**Properties**:
1. Note
2. Converted To Task/Story/Epic (relation fields)
3. AI Confidence
4. Processing Attempts
5. Created Date

---

## Automation Rules

### 1. Trigger Re-analysis
**When**: Approval Actions changes to `Update Entry 📝`

**Then**:
1. Set Processing Status to `Draft`
2. Clear Approval Actions
3. Increment Processing Attempts by 1

### 2. Trigger Execution
**When**: Approval Actions changes to `Approve ✅`

**Then**:
1. Set Processing Status to `Approved`
2. Clear Approval Actions

### 3. Handle Rejection
**When**: Approval Actions changes to `Discard ❌`

**Then**:
1. Set Processing Status to `Rejected`
2. Clear Approval Actions

### 4. Auto-Archive Old Drafts
**When**: 
- Processing Status is `Draft`
- Last Edited Time is more than 7 days ago

**Then**:
- Add tag `auto-archived`
- Move to Archive view (if you have one)

---

## Webhook Setup for n8n

### 1. Create Integration Token (if not using existing)
1. Go to Settings & Members → Integrations
2. Find your integration or create new one
3. Ensure it has access to the Inbox database

### 2. Set Up Webhooks
You'll need to create these webhook endpoints in n8n:

1. **New Item Webhook**
   - Triggers when: New page added to Inbox
   - Send to: `https://your-n8n-url/webhook/inbox-new-item`

2. **Approval Decision Webhook**
   - Triggers when: Approval Actions is updated
   - Send to: `https://your-n8n-url/webhook/inbox-approval`

3. **Status Update Webhook**
   - Triggers when: Processing Status changes
   - Send to: `https://your-n8n-url/webhook/inbox-status`

---

## Property Display Order

Recommended order for the main table view:
1. Note (Title)
2. Confidence Visual
3. Action Required
4. Processing Status
5. AI Confidence
6. Approval Actions
7. Priority
8. Tags
9. Created Date
10. AI Action Plan (hidden by default)
11. User Feedback (hidden by default)
12. Other properties...

---

## Testing Your Setup

### 1. Create Test Entry
Create a new inbox item with:
- Note: "Create user authentication system for the Healthcare AI platform"
- Priority: High
- Tags: Development, Healthcare

### 2. Verify Properties
Check that all new properties appear and formulas calculate correctly.

### 3. Test Views
Switch between views to ensure filters work properly.

### 4. Test Automations
Try changing Approval Actions to verify automations trigger.

---

## Mobile Optimization

For mobile access, create a simplified view:

**View Name**: `📱 Mobile Inbox`

**Properties** (in order):
1. Note (full width)
2. Confidence Visual
3. Action Required
4. Approval Actions

**Hide all other properties for clean mobile experience**

---

## Troubleshooting

### Formula Not Working
- Check property names match exactly (case-sensitive)
- Ensure AI Confidence is set to Percent format
- Try removing and re-adding the formula

### Automation Not Triggering
- Check automation is turned on
- Verify property names in conditions
- Test with manual property changes

### Properties Not Showing
- Check view settings
- Ensure properties aren't hidden
- Try refreshing the page

---

## Next Steps

Once all properties are added:
1. Create a test entry
2. Set up n8n workflows using the code snippets document
3. Test the full flow from inbox to completion