# Confidence Scoring Guide

## Overview
This guide explains how the AI calculates confidence scores (0-100%) for inbox item analysis, what factors influence the score, and how to interpret and improve confidence levels.

---

## Confidence Score Components

### 1. Base Confidence Factors (25% each)

#### 1.1 Clarity of Intent (0-100%)
How clearly the inbox item expresses what needs to be done.

**High Clarity (90-100%)**
- Explicit action verbs (create, update, fix, implement)
- Clear deliverables mentioned
- Specific outcomes described
- Examples: "Create login page with email/password fields"

**Medium Clarity (60-89%)**
- General intent clear but details missing
- Some interpretation required
- Examples: "Need authentication system"

**Low Clarity (0-59%)**
- Vague or ambiguous language
- Multiple possible interpretations
- Examples: "Look into user stuff"

#### 1.2 Information Completeness (0-100%)
How much required information is present.

**Complete Information (90-100%)**
- All context provided
- Technical requirements specified
- Dependencies mentioned
- Timeline/priority indicated

**Partial Information (60-89%)**
- Core information present
- Some details missing but can be inferred
- Context mostly clear

**Insufficient Information (0-59%)**
- Critical details missing
- No context provided
- Cannot determine scope

#### 1.3 Parent Item Certainty (0-100%)
How confidently the item can be linked to existing project/epic/story.

**Clear Parent (90-100%)**
- Explicit mention of project/epic/story name
- Direct reference to existing work
- Obvious domain match
- Example: "Add to Healthcare AI Epic"

**Probable Parent (60-89%)**
- Domain keywords match existing items
- Logical connection to ongoing work
- Reasonable assumptions possible

**Uncertain Parent (0-59%)**
- No clear connection to existing work
- Could belong to multiple areas
- New area not previously defined

#### 1.4 Classification Certainty (0-100%)
How clearly the item fits into Task/Story/Epic/Knowledge categories.

**Clear Classification (90-100%)**
- Obviously fits one category
- Meets all criteria for that type
- Scope and effort clearly indicate type

**Probable Classification (60-89%)**
- Mostly fits one category
- Minor ambiguity about scope
- Could potentially be adjacent type

**Ambiguous Classification (0-59%)**
- Could be multiple types
- Scope unclear
- Missing key classification indicators

---

## Confidence Calculation Formula

```javascript
function calculateConfidence(factors) {
  // Base calculation: average of all factors
  const baseConfidence = (
    factors.clarityOfIntent +
    factors.informationCompleteness +
    factors.parentItemCertainty +
    factors.classificationCertainty
  ) / 4;
  
  // Apply modifiers
  let finalConfidence = baseConfidence;
  
  // Positive modifiers
  if (factors.hasUserFeedback) {
    finalConfidence += 15; // Boost for incorporating feedback
  }
  
  if (factors.exactProjectMatch) {
    finalConfidence += 10; // Boost for exact project name match
  }
  
  if (factors.previousSuccessfulMatch) {
    finalConfidence += 5; // Boost if similar items processed before
  }
  
  // Negative modifiers
  if (factors.multipleInterpretations > 2) {
    finalConfidence -= 20; // Penalty for high ambiguity
  }
  
  if (factors.conflictingKeywords) {
    finalConfidence -= 15; // Penalty for mixed signals
  }
  
  if (factors.attemptNumber > 2) {
    finalConfidence -= 10; // Penalty for multiple failed attempts
  }
  
  // Ensure bounds
  return Math.max(0, Math.min(100, Math.round(finalConfidence)));
}
```

---

## Confidence Score Interpretation

### 90-100% - Very High Confidence 🟢
**Meaning**: AI is very certain about classification and action plan.

**Characteristics**:
- All required information present
- Clear match to existing items
- Unambiguous classification
- Specific action plan ready

**Recommended Action**: 
- Auto-approve after quick review
- Execute immediately
- Monitor results only

### 70-89% - High Confidence 🟡
**Meaning**: AI is confident but made some reasonable assumptions.

**Characteristics**:
- Most information present
- Logical connections to existing work
- Clear classification with minor uncertainty
- Action plan needs minimal adjustment

**Recommended Action**:
- Review assumptions
- Approve if assumptions are correct
- Minor edits might improve plan

### 50-69% - Medium Confidence 🟠
**Meaning**: AI can process but significant assumptions required.

**Characteristics**:
- Key information missing
- Multiple valid interpretations
- Parent items uncertain
- Action plan is tentative

**Recommended Action**:
- Careful review required
- Add missing context
- Clarify ambiguities
- Consider feedback loop

### 30-49% - Low Confidence 🔴
**Meaning**: AI struggling to interpret, needs significant input.

**Characteristics**:
- Critical information missing
- Very ambiguous intent
- Cannot determine proper classification
- Multiple conflicting interpretations

**Recommended Action**:
- Add substantial context
- Clarify intent completely
- Consider rewriting entry
- Use feedback loop

### 0-29% - Very Low Confidence ⚫
**Meaning**: AI cannot process meaningfully without more information.

**Characteristics**:
- Insufficient information
- No clear intent
- Cannot classify
- No reasonable action possible

**Recommended Action**:
- Rewrite inbox entry completely
- Add all missing context
- Consider breaking into multiple items
- Manual processing might be faster

---

## Factors That Increase Confidence

### 1. Explicit References
```
✅ "Add this to the Healthcare AI Epic"
✅ "Create a task under User Authentication Story"
✅ "Update the Trading Dashboard Project description"
```

### 2. Clear Scope Definition
```
✅ "Build login page with email/password (2 days work)"
✅ "Research and document OAuth2 options (1 day)"
✅ "Epic: Redesign entire admin panel (2 months)"
```

### 3. Structured Information
```
✅ Title: Implement user search
   Description: Add search bar to users page
   Requirements: 
   - Search by name or email
   - Real-time results
   - Pagination
   Priority: High
   Parent: User Management Story
```

### 4. Technical Keywords Matching Domain
```
✅ Frontend task: "React component for data table"
✅ Backend task: "PostgreSQL query optimization"
✅ DevOps task: "Setup CI/CD pipeline"
```

### 5. Previous Successful Processing
- Similar items processed before
- Consistent naming patterns
- Established project structure

---

## Factors That Decrease Confidence

### 1. Vague Language
```
❌ "Need to look into that thing we discussed"
❌ "Make it better"
❌ "Fix the issues"
```

### 2. Mixed Classifications
```
❌ "Create a story about researching and implementing login, 
    also document how it works" 
    (Is it a Story? Task? Knowledge entry?)
```

### 3. Missing Context
```
❌ "Add search feature" 
    (To what? Which project? What kind of search?)
```

### 4. Conflicting Information
```
❌ "High priority but maybe next quarter"
❌ "Simple task that might take 2 weeks"
❌ "Update the epic to be a story"
```

### 5. Unknown References
```
❌ "Add to the Johnson project" (No project found)
❌ "Like we did for ClientX" (No context)
❌ "Similar to the blue system" (Unknown system)
```

---

## Improving Confidence Scores

### 1. Provide Clear Structure
```markdown
**What**: Implement user avatar upload
**Type**: Task
**Parent**: User Profile Story  
**Details**: Allow users to upload profile pictures
**Requirements**: 
- Max 5MB file size
- Auto-resize to 200x200
- Support JPG/PNG
**Effort**: 1 day
**Priority**: Medium
```

### 2. Use Consistent Naming
- Always refer to projects/epics/stories by exact name
- Use consistent terminology
- Avoid abbreviations or nicknames

### 3. Include Context Clues
- Mention the domain (Frontend/Backend/DevOps)
- Reference related work
- Specify the team or project area

### 4. Be Explicit About Intent
- Start with action verbs
- State the desired outcome
- Specify if it's new work or an update

### 5. Leverage Feedback Loop
- When confidence is low, add clarification
- Use "Update Entry" to provide context
- Build on previous analysis attempts

---

## Confidence Monitoring Dashboard

### Key Metrics to Track

#### 1. Average Confidence by Type
```
Tasks:     75% average
Stories:   68% average  
Epics:     82% average
Knowledge: 71% average
```

#### 2. Confidence Distribution
```
90-100%: ████████ 40%
70-89%:  ██████ 30%
50-69%:  ████ 20%
30-49%:  ██ 8%
0-29%:   █ 2%
```

#### 3. Confidence Improvement Rate
- First attempt: 65% average
- After feedback: 85% average
- Improvement: +20%

#### 4. Factors Impact Analysis
Most helpful for confidence:
1. Explicit parent references (+25%)
2. Clear scope definition (+20%)
3. Structured format (+15%)
4. Domain keywords (+10%)

Most harmful for confidence:
1. Vague language (-30%)
2. Mixed classifications (-25%)
3. Unknown references (-20%)
4. Conflicting info (-15%)

---

## Best Practices for High Confidence

### 1. Inbox Entry Template
```markdown
Title: [Action] [Deliverable]
Type: [Task|Story|Epic|Knowledge]
Parent: [Exact name of parent item]
Description: [What and why]
Requirements: [Bullet list]
Effort: [Hours|Days|Weeks]
Priority: [Critical|High|Medium|Low]
Tags: [Domain, Technology, Team]
```

### 2. Progressive Enhancement
- Start with basic information
- AI provides initial analysis
- Review and add missing details
- Re-analyze with higher confidence

### 3. Learning from Patterns
- Track what increases confidence in your system
- Create templates for common types
- Document successful patterns
- Train team on best practices

---

## Troubleshooting Low Confidence

### Diagnostic Questions
1. Is the intent clear from the title alone?
2. Can you identify the parent without searching?
3. Is the scope obviously Task/Story/Epic?
4. Are all requirements listed?
5. Is there conflicting information?

### Quick Fixes
- Add explicit parent reference → +15-20%
- Clarify scope and effort → +10-15%
- Add domain keywords → +5-10%
- Structure with bullet points → +5-10%
- Remove ambiguity → +10-20%

### When to Skip AI Processing
If confidence remains below 50% after 2 attempts:
- Consider manual processing
- Break into multiple clearer items
- Create as draft for human review
- Add to knowledge base for future reference