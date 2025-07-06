# AI Inbox Workflow Test Scenarios

## Overview
This document provides comprehensive test scenarios to validate the AI-powered inbox workflow system. Each scenario includes test data, expected outcomes, and validation steps.

---

## Test Categories

### 1. Basic Classification Tests
Test the AI's ability to correctly classify different types of entries.

### 2. Confidence Level Tests  
Validate confidence scoring accuracy across various input qualities.

### 3. Approval Workflow Tests
Test the complete approval cycle including user feedback loops.

### 4. Error Handling Tests
Ensure graceful handling of edge cases and errors.

### 5. Integration Tests
Validate end-to-end workflow from inbox to task/story creation.

---

## Detailed Test Scenarios

### Test Set 1: Task Classification

#### Test 1.1: Clear Task with All Information
**Input:**
```
Title: Implement user authentication system for healthcare platform
Priority: High
Tags: Development, Security, Healthcare

Additional context: Need to implement OAuth2 with support for multiple providers (Google, Microsoft, Apple). Should include 2FA and comply with HIPAA requirements. Estimated 40 hours of work.
```

**Expected Result:**
- Classification: Task
- Confidence: 95-100%
- Action: CREATE_NEW
- Correctly identifies project: Healthcare AI Product Development
- Suggested properties properly extracted

#### Test 1.2: Vague Task Description
**Input:**
```
Title: Fix the thing that's broken
Priority: Not set
Tags: None
```

**Expected Result:**
- Classification: Task (uncertain)
- Confidence: 20-30%
- Action: CREATE_NEW (with questions)
- Status: Draft (not Pending Approval)
- Questions for user about what's broken, which system, priority

#### Test 1.3: Bug Report Format
**Input:**
```
Title: BUG: Export function throws error when dataset > 1000 rows
Priority: Critical
Tags: Bug, Production

Error: "OutOfMemoryException" in DataExporter.cs line 245
Steps to reproduce:
1. Load dataset with 1500 rows
2. Click Export > CSV
3. Error appears

Expected: Export completes successfully
Actual: Application crashes
```

**Expected Result:**
- Classification: Task
- Confidence: 90-95%
- Action: CREATE_NEW
- Correctly formats as bug report
- Maintains reproduction steps in description

---

### Test Set 2: Story Classification

#### Test 2.1: Well-Defined User Story
**Input:**
```
Title: As a physician, I want to view patient history timeline so that I can quickly understand treatment progression
Priority: High
Tags: Feature, Healthcare, UX

Acceptance Criteria:
- Timeline shows all appointments, procedures, medications
- Can filter by date range
- Can filter by type (medication, procedure, visit)
- Export timeline as PDF
- Mobile responsive design
```

**Expected Result:**
- Classification: Story
- Confidence: 95-100%
- Action: CREATE_NEW
- Correctly identifies epic (if applicable)
- Preserves acceptance criteria format

#### Test 2.2: Feature Request Without User Story Format
**Input:**
```
Title: Need dashboard for monitoring system performance
Priority: Medium
Tags: Feature

Should show CPU, memory, response times. Refresh every 5 seconds. Include alerts for threshold breaches.
```

**Expected Result:**
- Classification: Story
- Confidence: 70-80%
- Action: CREATE_NEW
- AI reformats as proper user story
- Suggests: "As a system administrator, I want to..."

---

### Test Set 3: Epic Classification

#### Test 3.1: Large Initiative Description
**Input:**
```
Title: Q2 2025 Healthcare Compliance Initiative
Priority: High
Tags: Compliance, Healthcare, Q2-2025

We need to achieve full HIPAA compliance across all our healthcare products. This includes:
- Audit trail implementation
- Encryption at rest and in transit  
- Access control overhaul
- Staff training program
- Third-party security audit
- Documentation update

Timeline: 3 months
Budget: $250,000
Team: 8 developers, 2 security experts
```

**Expected Result:**
- Classification: Epic
- Confidence: 90-95%
- Action: CREATE_NEW
- Suggests breaking down into multiple stories
- Identifies this belongs to Healthcare AI Product Development project

---

### Test Set 4: Knowledge Base Entries

#### Test 4.1: Technical Documentation
**Input:**
```
Title: How to configure Redis caching in production
Tags: Documentation, Redis, DevOps

Steps:
1. Install Redis 7.0+ on Ubuntu 22.04
2. Configure redis.conf:
   - Set maxmemory to 2gb
   - Enable persistence with AOF
   - Set password authentication
3. Configure application connection string
4. Test with redis-cli

Common issues:
- Memory errors: Increase maxmemory
- Connection refused: Check firewall rules
- Performance: Enable pipelining
```

**Expected Result:**
- Classification: Knowledge
- Confidence: 95-100%
- Action: CREATE_NEW
- Properly formatted as KB article
- Tagged appropriately for discovery

---

### Test Set 5: Confidence Edge Cases

#### Test 5.1: Ambiguous Entry
**Input:**
```
Title: Meeting notes from Thursday
Priority: Low
Tags: Meeting

Discussed stuff about the project. John mentioned something about deadlines. Need to follow up.
```

**Expected Result:**
- Classification: Note
- Confidence: 30-40%
- Action: LINK_TO_EXISTING (uncertain)
- Multiple questions about which project, what deadlines, action items

#### Test 5.2: Multiple Possible Classifications
**Input:**
```
Title: Explore using AI for customer support
Priority: Medium
Tags: AI, Research

Could be really useful. Might reduce support load by 50%. Need to look into different solutions and pricing. Could be a big project if we decide to build custom.
```

**Expected Result:**
- Classification: Story or Epic (uncertain)
- Confidence: 50-60%
- Questions about scope, timeline, just research vs implementation

---

### Test Set 6: Approval Workflow Tests

#### Test 6.1: High Confidence Auto-Approval Test
**Setup:** Configure workflow to auto-approve items > 90% confidence

**Input:** Use Test 1.1 (Clear Task)

**Expected Flow:**
1. Item created → AI analyzes (95% confidence)
2. Status: Pending Approval (despite high confidence)
3. User reviews and clicks "Approve ✅"
4. Task created automatically
5. Inbox item marked "Completed"

#### Test 6.2: Feedback Loop Test
**Input:** Use Test 5.1 (Ambiguous Entry)

**Expected Flow:**
1. AI analyzes (35% confidence) → Status: Draft
2. User adds feedback: "This is about the Healthcare AI project. Deadline is API integration by March 15"
3. User triggers re-analysis
4. AI re-analyzes with context (85% confidence)
5. Status: Pending Approval
6. User approves → Task created

#### Test 6.3: Multiple Feedback Iterations
**Test:** User provides insufficient feedback initially

**Expected Flow:**
1. Initial analysis: 30% confidence
2. First feedback: "It's about the trading platform"
3. Re-analysis: 50% confidence (still draft)
4. Second feedback: "Specifically about fixing the real-time data feed that's lagging"
5. Re-analysis: 90% confidence
6. Approval and task creation

---

### Test Set 7: Error Handling

#### Test 7.1: Malformed Input
**Input:**
```
Title: [Empty]
Priority: InvalidValue
Tags: 
```

**Expected Result:**
- AI handles gracefully
- Returns low confidence (10-20%)
- Provides helpful error message
- Suggests required information

#### Test 7.2: Circular Reference Detection
**Input:**
```
Title: Update the task about updating tasks
Tags: Meta

This task is about the task system itself. Need to update how we update task updates.
```

**Expected Result:**
- AI detects potential confusion
- Asks for clarification
- Suggests better title/description

---

### Test Set 8: Integration Tests

#### Test 8.1: Full Cycle - Task Creation
**Scenario:** From inbox to completed task with relations

**Steps:**
1. Create inbox item about healthcare feature
2. AI analyzes → 85% confidence
3. User approves
4. Task created in correct project/epic
5. Relations properly set
6. Original inbox item archived

**Validation:**
- Task appears in Tasks database
- Relations to Healthcare project established
- Inbox item status is "Completed"
- Audit trail maintained

#### Test 8.2: Cross-Project Reference
**Input:**
```
Title: Integrate trading alerts with healthcare monitoring dashboard
Priority: Medium
Tags: Integration, Trading, Healthcare

Need to show trading portfolio health metrics alongside patient health metrics for our physician-investor users.
```

**Expected Result:**
- AI recognizes cross-project nature
- Suggests creating items in both projects
- Links items appropriately
- Confidence: 70-75% due to complexity

---

### Test Set 9: Performance Tests

#### Test 9.1: Bulk Processing
**Scenario:** 50 inbox items created simultaneously

**Expected Behavior:**
- All items processed within 5 minutes
- No timeout errors
- Proper queuing and rate limiting
- Database consistency maintained

#### Test 9.2: Large Content Item
**Input:** Inbox item with 10,000 character description

**Expected Result:**
- AI handles without truncation errors
- Appropriate summarization in task description
- Full content preserved in archives

---

### Test Set 10: Special Cases

#### Test 10.1: Recurring Task Detection
**Input:**
```
Title: Weekly database backup verification
Priority: Medium
Tags: Maintenance, Recurring

Every Monday, verify that weekend backups completed successfully and test restore process.
```

**Expected Result:**
- AI detects recurring nature
- Suggests creating recurring task template
- Appropriate scheduling metadata

#### Test 10.2: Dependency Detection
**Input:**
```
Title: Deploy user auth system after security audit completes
Priority: High
Tags: Development, Blocked

Can't start this until the security team finishes their review of the auth architecture. Probably blocked until next Friday.
```

**Expected Result:**
- AI identifies dependency
- Suggests linking to security audit task
- Sets appropriate status (Blocked/Waiting)

---

## Validation Checklist

For each test scenario, verify:

- [ ] Correct classification
- [ ] Confidence score within expected range
- [ ] Appropriate action suggested
- [ ] Processing status correctly set
- [ ] User-facing messages are clear
- [ ] No data loss during processing
- [ ] Audit trail maintained
- [ ] Relations properly established
- [ ] Error handling works as expected
- [ ] Performance within acceptable limits

---

## Regression Test Suite

Run these tests after any workflow changes:

1. Basic task creation (Test 1.1)
2. Story with acceptance criteria (Test 2.1)
3. Knowledge base entry (Test 4.1)
4. Feedback loop (Test 6.2)
5. Error handling (Test 7.1)
6. Full integration cycle (Test 8.1)

---

## Test Data Reset

Between test runs:
1. Clear test items from Inbox
2. Reset any modified workflow settings
3. Clear test-created tasks/stories
4. Verify clean state