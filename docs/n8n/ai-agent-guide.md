# 🧠 AI Agent Guide: Notion PMS & Knowledge Base Automation

## Purpose
This document is the **single source of truth** for any AI Agent (using Notion MCP, Cursor, or other automation tools) to understand, manage, and populate the Notion-based Project Management and Knowledge System. **Always refer to this document before making any changes.**

---

## 1. Integration & Page IDs
- **Integration Token:** `ntn_f35248778523jpOe6IQngDnseZlexMBsf2YC7jt6WEb9NF`
- **Main Page ID:** `2200d2195e1c80bd948be2bf9db1f959`
- **Projects DB ID:** `2200d219-5e1c-81e4-9522-fba13a081601`
- **Tasks DB ID:** `21e0d2195e1c80a28c67dc2a8ed20e1b`
- **Inbox DB ID:** `21e0d2195e1c80228d8cf8ffd2a27275`
- **Stories DB ID:** `21e0d2195e1c806a947ff1806bffa2fb`
- **Epics DB ID:** `21e0d2195e1c809bae77f183b66a78b2`
- **Knowledge Base DB ID:** `21e0d2195e1c802ca067e05dd1e4e908`

### Active Projects
1. **Techniq Company Building** - Everything related to building the company (website, brand, hiring, operations)
2. **Trading & Financial Markets Platform** - Trading infrastructure, data systems, strategies, dashboards
3. **Healthcare AI Product Development** - AI medical products, clinical applications, healthcare data systems

For detailed project scope, see PROJECT-DEFINITIONS.md

---

## 2. Database Overview & Purpose

### **Projects**
- **Purpose:** Define high-level project categories and strategic initiatives that organize all work hierarchically. Projects are the top-level container for organizing work across different business domains.
- **Key Properties:** Title, Category, Description, Status, Priority, Start Date, End Date, Owner, Budget, Tags, Notes
- **Categories:** Company Operations, AI Products, Stock Trading/Strategy, Personal Life, Adhoc Projects

#### The 3 Main Projects:
1. **Techniq Company Building** (Category: Company Operations) - Brand, website, hiring, business operations
2. **Trading & Financial Markets Platform** (Category: Stock Trading/Strategy) - Trading infrastructure and strategies
3. **Healthcare AI Product Development** (Category: AI Products) - Medical AI products and systems

### **Epics**
- **Purpose:** Group related stories and tasks into larger initiatives within a specific project context.
- **Key Properties:** Title, Status, Objective, Related Project, Related Stories, Related Tasks, Tags

### **Stories**
- **Purpose:** Define user stories, requirements, or features to be implemented. Stories are linked to tasks and epics.
- **Key Properties:** Title, Status, Priority, Acceptance Criteria, Related Epic, Related Tasks, Tags

### **Tasks**
- **Purpose:** Track all actionable items, their status, assignees, deadlines, and related stories/epics.
- **Key Properties:** Title, Status, Priority, Due Date, Related Story, Related Epic, Tags, Created By, Last Updated

### **Inbox**
- **Purpose:** Capture raw notes, ideas, and unstructured information for later triage and conversion into tasks, stories, or knowledge.
- **Key Properties:** Title, Status (To Convert, Sticky, Archive), Tags, Source, Created Date

### **Knowledge Base**
- **Purpose:** Store reusable knowledge, guides, decisions, lessons learned, and documentation across all projects.
- **Key Properties:** Title, Type, Tags, Status, Importance, Summary, Full Description, Linked Task/Story/Epic, Source Note, Attachments, Comments, Related Epic/Story/Task, Created by AI?

---

## 3. Templates in Use
- **Projects:** Project template with strategic overview, timeline, and resource management.
- **Epics:** Epic template with objectives and related stories/tasks within project context.
- **Stories:** User story template with acceptance criteria and links to tasks/epics.
- **Tasks:** Standard task template with fields for status, priority, due date, and relations.
- **Inbox:** Note template for quick capture and later classification.
- **Knowledge Base:** [See 'Knowledge Base Template' in this documentation for structure.]

---

## 4. Database Relations
- **Project ↔ Epic:** Projects contain multiple epics; each epic belongs to one project.
- **Epic ↔ Story:** Epics contain multiple stories; each story belongs to one epic.
- **Story ↔ Task:** Stories contain multiple tasks; each task can be linked to a story.
- **Project/Epic/Story/Task ↔ Knowledge Base:** Knowledge entries can reference any project, epic, story, or task for context and traceability.
- **Inbox ↔ Task/Story/Epic/Knowledge:** Inbox notes can be converted into tasks, stories, epics, or knowledge entries.

### **Hierarchy Flow**
```
Projects (Strategic Level)
    ↓
Epics (Initiative Level) 
    ↓
Stories (Feature Level)
    ↓ 
Tasks (Action Level)
    ↕
Knowledge Base (Cross-cutting Documentation)
```

---

## 5. MCP Documentation & Usage
- **MCPs Used:**
  - Notion MCP: For all Notion database/page operations (read, write, update, query, etc.)
  - Cursor: For code/documentation management and workflow automation
  - Context7, Playwright MCP, Docker MCP: For advanced automation, browser actions, and environment management
- **Documentation Location:** See `docs/mcp/` for detailed MCP usage, installation, and troubleshooting guides.
- **n8n Workflows:** See `docs/n8n/` for automation templates and AI prompt references.

---

## 6. Agent Instructions
- **ALWAYS** read this document before making any changes to Notion databases or pages.
- Use the correct Integration Token and Page/Database IDs as listed above.
- Follow the template structures and maintain all required properties.
- Respect all database relations and ensure referential integrity.
- Log/document any changes or new workflows in the appropriate documentation folder.
- If a required property, template, or relation is missing, **request clarification from the user** before proceeding.

---

## 7. Requesting Clarification
If you are unclear about any property, template, relation, or workflow, **pause and request clarification from the user**. Do not make assumptions or changes without confirmation.

---

## 8. Revision Log
- _[Add entries here for any major changes to this guide or the system.]_ 

---

## 9. Template Fidelity Policy
- The AI Agent **must use the following templates verbatim** for all new entries in Notion.
- **No changes** to structure, formatting, section order, or property mapping are allowed.
- If a template is updated, this guide must be updated before the agent proceeds.
- If the agent is ever unsure about a template, it must request clarification from the user before proceeding.

---

## 10. Templates (Copy Exactly)

### 🏆 Epic Template
```
# 🏆 Epic Overview

---

## 📌 Epic Summary
Describe the epic, its scope, and its importance.

---

## 🎯 Objectives
- [ ]  [ ]
- [ ]  [ ]
- [ ]  [ ]

---

## ⏳ Status & Timeline
- **Status:**
- **Priority:**
- **Progress:**
- **Owner:**
- **Start Date:**
- **Deadline:**

---

## 🗂 Milestones
-

---

## 🔗 Linked Stories
List or link all related stories here.

---

## 🏷️ Tags
-

---

## 📝 Retrospective KB
Link to the knowledge base entry for the retrospective.

---

## 🗂 Attachments & Comments
- **Attachments:**
- **Comments:**

---

## 📝 Notes
Add any additional notes, context, or discussion here.
```

---

### 🏢 Project Template
```
# 🏢 Project Overview

---

## 📌 Project Summary
Describe the project's strategic importance, scope, and high-level objectives within the business context.

---

## 🎯 Strategic Objectives
- [ ]  [ ]
- [ ]  [ ]
- [ ]  [ ]

---

## 🏷️ Project Category
**Category:** [Data Consultancy | AI Products | Stock Trading/Strategy | Marketing | Personal Life | Adhoc Projects]

---

## ⏳ Project Timeline & Status
- **Status:** [Not Started | Planning | Active | On Hold | Completed | Cancelled]
- **Priority:** [Low | Medium | High | Critical]
- **Progress:** 
- **Owner:** 
- **Start Date:** 
- **End Date:** 
- **Budget:** $

---

## 🎯 Success Metrics & KPIs
- **Primary Metric:** 
- **Secondary Metrics:**
  - 
  - 
- **Success Criteria:**
  - [ ]  [ ]
  - [ ]  [ ]

---

## 🗂 Project Epics
List or link all related epics under this project.

- [ ]  Epic 1:
- [ ]  Epic 2: 
- [ ]  Epic 3:

---

## 👥 Stakeholders & Team
- **Project Owner:** 
- **Key Stakeholders:** 
- **Team Members:** 
- **External Dependencies:** 

---

## 💰 Resource Allocation
- **Budget Breakdown:**
  - Personnel: $
  - Tools/Software: $
  - External Services: $
  - Other: $
- **Time Allocation:** 
- **Priority Resources:** 

---

## 🚧 Risks & Mitigation
- **High Priority Risks:**
  - Risk: | Impact: | Probability: | Mitigation:
  - Risk: | Impact: | Probability: | Mitigation:
- **Dependencies:** 
- **Blockers:** 

---

## 🏷️ Tags
- 

---

## 📝 Project Retrospective
Link to knowledge base entries for project learnings and retrospectives.

- **Lessons Learned:** 
- **Best Practices:** 
- **Improvement Areas:** 

---

## 🗂 Attachments & Resources
- **Project Documents:** 
- **Reference Materials:** 
- **External Links:** 

---

## 📝 Notes
Add any additional context, decisions, or strategic considerations here.
```

---

### 📖 Story Template
```
# 📖 Story Overview

---

## 📝 User Story
Describe the user story in the format:

"As a [role], I want [feature] so that [benefit]."

---

## 🎯 Acceptance Criteria
- [ ]  [ ]
- [ ]  [ ]
- [ ]  [ ]

---

## ⏳ Status & Sprint
- **Status:**
- **Sprint:**
- **Owner:**
- **Due Date:**
- **Priority:**

---

## 🔗 Links & Relations
- **Epic:**
- **Tasks:**
- **Related Notes:**
- **KB References:**

---

## 🏷️ Tags
-

---

## 🗂 Attachments & Comments
- **Attachments:**
- **Comments:**

---

## 📝 Summary
Summarize the story, its purpose, and any key details.
```

---

### 📄 Knowledge Base Template
```
# 📄 Knowledge Entry Title

**Type:**
Guide / Reference / Decision / Lesson Learned / How-To / FAQ / Architecture / Code Snippet / *Other*

**Tags:**
Technology, Process, Team, Tool, *etc.*

**Status:**
Draft / In Review / Approved / Archived

**Importance:**
High / Medium / Low

---

## 📝 Summary *Short executive summary (1-2 sentences)*

---

## 📖 Full Description *Detailed explanation, steps, or documentation. Use headings, bullet points, and code blocks as needed.*

---

## 🔗 Linked Task / Story / Epic
- [ ]  Task:
- [ ]  Story:
- [ ]  Epic:

---

## 🗒️ Source Note *Where did this knowledge come from? (meeting, project, research, etc.)*

---

## 📎 Attachments
- [Link or file]
- [Link or file]

---

## 💬 Comments *Any discussion, clarifications, or feedback.*

---

## ✅ Tasks / Action Items
- [ ]  Action 1
- [ ]  Action 2

---

## 🤖 Created by AI?
☐ Yes
☐ No

---

**Created Date:**
{{Date}}

**Last Updated:**
{{Date}}
```

---

### 🗃️ Inbox Note Template
```
# 🗃️ Inbox Note

---

## ✍️ Note Content
Write your idea, reminder, or note here.

---

## 📅 Metadata
- **Created Date:**
- **Priority:**
- **Follow Up Date:**

---

## 🔗 Linked Items
- **Linked To:**
- **Converted To:**
- **Sticky?:**

---

## 🏷️ Tags
-

---

## 🤖 AI Suggestions
- [ ]  Classify note
- [ ]  Suggest conversion (Task/Story/Epic)
- [ ]  Link to existing item
- [ ]  Mark as sticky
- [ ]  Archive

---

## 🗂 Attachments & Comments
- **Attachments:**
- **Comments:**
```

---

### ✅ Task Template
```
# ✅ Task Overview

---

## 📝 Task Description
Describe the task, its context, and any relevant background.

---

## 🎯 Acceptance Criteria
- [ ]  [ ]
- [ ]  [ ]
- [ ]  [ ]

---

## ⏳ Status & Priority
- **Status:**
- **Priority:**
- **Difficulty:**
- **Assignee:**
- **Due Date:**
- **Estimated Time:**
- **Actual Time:**

---

## 🔗 Links & Relations
- **Linked Story:**
- **Created From Note:**
- **Knowledge Entry?:**

---

## 🏷️ Tags
-

---

## 🗂 Attachments & Comments
- **Attachments:**
- **Comments:**

---

## 📝 Summary of Outcome
Summarize the result, learnings, or next steps after task completion.
``` 

---

## 10. Project Rules, Relations & Automation

### Project Creation & Management Rules

#### 1. Project Classification Standards
- **Each project MUST have a category** from the 6 defined options:
  - Data Consultancy (Client-focused revenue work)
  - AI Products (Innovation and product development)  
  - Stock Trading/Strategy (Personal investment projects)
  - Marketing (Brand, growth, and customer acquisition)
  - Personal Life (Work-life balance and development)
  - Adhoc Projects (One-off and experimental work)

#### 2. Project Hierarchy Enforcement
- **All Epics MUST be linked to a Project** - No orphaned epics allowed
- **Project status cascades down**: If project is "On Hold", child epics should be reviewed
- **Resource allocation flows from Project level** - Budget and timeline constraints apply to all child items

#### 3. Project Template Requirements
- **Strategic Objectives**: Minimum 3 clear, measurable objectives
- **Success Metrics**: At least 1 primary metric and 2 secondary metrics
- **Stakeholder Mapping**: All key stakeholders and dependencies identified
- **Risk Assessment**: Top 3 risks documented with mitigation strategies

### Project Relations Framework

#### Required Relationships
```
Projects → Epics (One-to-Many):
- Each Epic MUST belong to exactly one Project
- Projects can have multiple Epics
- Epic completion updates Project progress automatically

Projects → Knowledge Base (Many-to-Many):
- Strategic documentation linked at Project level
- Best practices and lessons learned captured per project
- Cross-project knowledge sharing enabled

Projects → Tasks (Indirect via Epics/Stories):
- Tasks inherit project context through Epic relationships
- Project tags automatically applied to all child items
- Resource allocation tracked from Project to Task level
```

#### Automated Project Workflows

##### Project Status Automation
```
Project Status: "Planning" → Action:
- Create initial Epic structure template
- Set up project documentation in Knowledge Base
- Assign project owner and key stakeholders
- Initialize budget tracking and timeline

Project Status: "Active" → Action:
- Enable weekly progress reporting
- Activate resource allocation tracking  
- Begin automated milestone checking
- Start risk monitoring workflow

Project Status: "On Hold" → Action:
- Flag all child Epics for review
- Pause resource allocation
- Document hold reason in project notes
- Notify all stakeholders

Project Status: "Completed" → Action:
- Trigger project retrospective creation
- Archive completed Epics and Stories
- Generate final project report
- Update project metrics in Knowledge Base
```

##### Cross-Project Automation
```
Resource Conflicts Detection:
- Alert when same person assigned to critical tasks in multiple active projects
- Flag budget conflicts across concurrent projects
- Identify timeline overlaps that may impact delivery

Knowledge Base Auto-Linking:
- New projects automatically linked to relevant strategic documentation
- Project completion triggers knowledge base updates
- Cross-reference similar projects for lessons learned
```

### Project Templates & Patterns

#### Template Deployment Rules
- **New projects MUST start from approved templates**
- **Template customization allowed but core structure preserved**
- **All projects require initial strategic review before Epic creation**

#### Project Patterns by Category
```
Data Consultancy Projects:
- Client Requirements Epic (Discovery, Analysis, Documentation)
- Solution Design Epic (Architecture, Prototyping, Validation) 
- Implementation Epic (Development, Testing, Deployment)
- Client Success Epic (Training, Support, Optimization)

AI Products Projects:
- Research Epic (Market Analysis, Technical Feasibility)
- MVP Development Epic (Core Features, Testing, Launch)
- Product Evolution Epic (Feature Enhancement, Scaling)
- Market Strategy Epic (Go-to-Market, Customer Acquisition)

Marketing Projects:
- Brand Strategy Epic (Positioning, Messaging, Identity)
- Content Creation Epic (Materials, Campaigns, Distribution)
- Channel Development Epic (Platforms, Partnerships, Optimization)
- Performance Analysis Epic (Metrics, Attribution, Optimization)
```

---

## 11. Best Practices: Project/Epic/Story/Task Hierarchy & Documentation

### Hierarchy Principles
- **Project:** Strategic business domain or category. Describes the organizational context and high-level business goals (e.g., "Data Consultancy", "AI Products"). Projects provide strategic alignment and resource allocation context.
- **Epic:** High-level initiative within a project. Describes the strategic objective and the "why" within the project context. Should not contain detailed research, inspiration, or solution specifics.
- **Story:** Major sub-goals or decision areas within an epic. Describes the "what" and "how" at a tactical level. Stories break down the Epic into actionable areas (e.g., "Choose Logo Shape", "Define Slogan", "Select Theme").
- **Task:** Concrete actions, research, or deliverables. Describes the "how" at an operational level. Tasks are specific steps or research items under each Story.

### Documentation & Insights
- **Inspiration, research, and links** should be attached to Stories/Tasks as comments, attachments, or as Knowledge Base entries.
- **Epics** should remain high-level and not include solution details, research, or links directly.
- **Stories** should document the decision process, options considered, and rationale.
- **Tasks** should document actions, findings, and outcomes.

### Example: Logo Creation Project
- **Project:** Marketing (Category: Marketing)
- **Epic:** Create a professional, unique, and memorable logo for Techniq that represents the company vision and stands out in the tech/AI consultancy space.
- **Story 1:** Decide on Logo Shape & Symbolism
  - **Task:** Research logo shapes in tech/AI consultancies
  - **Task:** Brainstorm symbolism that aligns with Techniq's vision
  - **Task:** Compare options and select the most fitting shape
- **Story 2:** Define the Slogan
  - **Task:** Research slogans in similar industries
  - **Task:** Brainstorm new slogan ideas
  - **Task:** Test slogans for clarity and impact
  - **Task:** Select and document the final slogan
- **Story 3:** Choose the Theme (Color, Font, Mood)
  - **Task:** Research color psychology and trends in tech branding
  - **Task:** Collect inspiration (including provided links)
  - **Task:** Compare and select theme elements
- **Story 4:** Finalize and Deliver Logo
  - **Task:** Create initial logo drafts
  - **Task:** Gather feedback from stakeholders
  - **Task:** Refine and finalize the logo
  - **Task:** Export and deliver logo files

### Example Workflow
- **Prompt:** "Create a new logo for Techniq."
  1. Search the Knowledge Base for 'logo', 'branding', 'Techniq', 'design inspiration'.
  2. Find previous entries on color psychology and logo inspiration websites.
  3. Link these entries to the new Epic and Stories.
  4. As research is conducted (e.g., new websites found, company themes defined), create new Knowledge Base entries for each significant finding.
  5. At project completion, update the Knowledge Base with a summary of what was learned, including links to all relevant Tasks, Stories, and Epics.

- **Prompt:** "Implement a new developer onboarding process."
  1. Search the Knowledge Base for 'onboarding', 'developer setup', 'team processes', 'best practices'.
  2. Find previous entries on onboarding checklists, environment setup guides, and lessons learned from past onboarding experiences.
  3. Link these entries to the new Epic ("Developer Onboarding Revamp") and related Stories (e.g., "Document Environment Setup", "Create Welcome Guide").
  4. As new onboarding materials are created or improved (e.g., updated setup scripts, new FAQ documents, feedback from new hires), add or update Knowledge Base entries for each resource.
  5. At the end of the project, update the Knowledge Base with a comprehensive summary of the new onboarding process, including links to all relevant Tasks, Stories, and Epics, and document any improvements or feedback for future iterations.

### Mandatory Policy
- **This workflow is mandatory for all AI agents.**
- No new work should begin without searching the Knowledge Base.
- All new knowledge must be captured and linked for future reuse.
- If any step is unclear, request clarification from the user before proceeding.
```

# 🔍 Search & Query Optimization

## Search Strategy Framework

### 1. Progressive Search Methodology
Always follow this search hierarchy for maximum effectiveness:

#### Level 1: Exact Match Search
```
Purpose: Find direct matches for known entities
Query Pattern: "exact phrase" OR specific_identifier
Examples:
- "logo design for Techniq"
- "developer onboarding process"
- "React component library"
```

#### Level 2: Semantic Keyword Search
```
Purpose: Find conceptually related content
Query Pattern: primary_keyword + secondary_keywords
Examples:
- branding + visual + identity
- onboarding + developer + setup
- authentication + security + login
```

#### Level 3: Tag-Based Discovery
```
Purpose: Find items in same category/domain
Query Pattern: Filter by tags + additional context
Examples:
- Tag:Frontend + "component"
- Tag:Research + "market analysis"
- Tag:DevOps + "deployment"
```

#### Level 4: Cross-Reference Exploration
```
Purpose: Follow relationship chains
Query Pattern: Start from found items → explore links
Process:
1. Find initial matches
2. Check linked Stories/Epics/Tasks
3. Review attached Knowledge Base entries
4. Follow comment threads
```

### 2. Search Query Construction Patterns

#### Boolean Operators
```
AND: logo AND branding (both terms required)
OR: authentication OR login (either term acceptable)
NOT: design NOT prototype (exclude prototypes)
```

#### Wildcard Patterns
```
Prefix: "brand*" → brand, branding, branded
Suffix: "*ing" → developing, testing, deploying
Contains: "*script*" → JavaScript, TypeScript, script
```

#### Phrase Matching
```
Exact: "user interface design"
Partial: "interface design"
Flexible: interface + design + user
```

### 3. Context-Aware Search Strategy

#### Current Work Context
Before searching, consider:
- **Active Epic**: What's the current project focus?
- **Current Story**: What specific area are you working on?
- **Recent Tasks**: What was done recently that might be related?

#### Search Scope Optimization
```
1. Start with Current Epic scope
   → Search within linked Stories/Tasks first
   
2. Expand to Project scope  
   → Search within same project tags
   
3. Broaden to Domain scope
   → Search within same domain (Frontend, Backend, etc.)
   
4. Full database search
   → Search across all items as last resort
```

### 4. Search Quality Validation

#### Result Relevance Scoring
For each search result, evaluate:
- **Direct Relevance** (1-10): How closely does this match your need?
- **Recency** (1-10): How current is this information?
- **Completeness** (1-10): Does this have enough detail to be useful?
- **Authority** (1-10): Was this created by a reliable source?

### 5. Search Automation & Shortcuts

#### Saved Search Patterns
Create shortcuts for common searches:
```
Quick Commands:
- /recent-frontend → Last 30 days Frontend items
- /my-tasks → Assigned to current user
- /blocked-items → Status = Blocked across all databases
- /knowledge-gaps → Items missing Knowledge Base links
```

#### Search Result Management
```
Search Session Workflow:
1. Define search objective clearly
2. Start with narrow, specific search
3. Document useful results immediately
4. Gradually broaden scope if needed
5. Stop when diminishing returns reached
6. Save successful search patterns for reuse
```

### 7. Cross-Database Search Coordination

#### Multi-Database Query Strategy
```
Sequential Search Order:
1. Knowledge Base (existing solutions/learnings)
2. Current Epic's Stories/Tasks (project context)  
3. Similar Epics (past project patterns)
4. Inbox (recent ideas/notes)
5. Archived items (historical context)
```

#### Search Result Synthesis
When searching across databases:
- **Deduplicate**: Remove redundant information
- **Prioritize**: Rank by relevance and recency
- **Link**: Identify relationships between results
- **Summarize**: Create unified view of findings

---

# 🏷️ Tagging & Classification Standards

## Tag Hierarchy Framework

### 1. Primary Classification Tags
Use these standardized primary tags for all items:

#### Project Category Tags (Required for all items)
```
- Data-Consultancy     (Client-focused data analytics and consulting work)
- AI-Products          (AI/ML product development and research)
- Stock-Trading        (Investment and trading strategy projects)
- Marketing           (Brand, growth, and customer acquisition)
- Personal-Life       (Work-life balance and personal development)
- Adhoc-Projects      (One-off experiments and miscellaneous work)
```

#### Domain Tags (Required for all items)
```
- Frontend          (UI/UX, React, CSS, user-facing features)
- Backend           (APIs, databases, server logic, infrastructure)  
- DevOps           (CI/CD, deployment, monitoring, security)
- Research         (market analysis, user research, technical investigation)
- Design           (visual design, branding, user experience)
- Planning         (strategy, roadmapping, requirements gathering)
- Documentation    (guides, specs, knowledge capture)
- Testing          (QA, automation, validation, debugging)
```

#### Complexity Tags (Required for Tasks/Stories)
```
- Simple           (< 4 hours work, straightforward implementation)
- Moderate         (1-2 days work, some complexity or dependencies)
- Complex          (3-5 days work, multiple components or unknowns)
- Epic-Level       (1+ weeks work, major feature or system change)
```

#### Priority Tags (Required for active items)
```
- Critical         (system down, blocking others, urgent deadline)
- High             (important for current sprint/milestone)
- Medium           (normal priority, planned work)
- Low              (nice-to-have, future consideration)
- Backlog          (defined but not scheduled)
```

### 2. Secondary Classification Tags

#### Technology Tags
```
Web Technologies:
- React, Vue, Angular
- JavaScript, TypeScript
- HTML, CSS, SCSS
- Node.js, Express
- PostgreSQL, MongoDB

Mobile/Desktop:
- React-Native, Flutter
- iOS, Android, macOS, Windows

Infrastructure:
- Docker, Kubernetes
- AWS, Azure, GCP
- Nginx, Apache
- Redis, Elasticsearch
```

#### Project Phase Tags
```
- Discovery        (understanding requirements, research)
- Design           (creating specifications, wireframes)
- Development      (active coding/building)
- Testing          (QA, validation, debugging)
- Deployment       (release preparation, rollout)
- Maintenance      (support, minor updates)
- Archive          (completed, no longer active)
```

#### Integration Tags
```
- API              (requires API integration)
- Database         (database schema/query changes)
- Authentication   (user auth, permissions, security)
- Third-Party      (external service integration)
- Migration        (data/system migration required)
- Breaking-Change  (may affect existing functionality)
```

### 3. Dynamic Tagging Rules

#### Auto-Tagging Triggers
```
Content-Based Auto-Tags:
- Contains "API" → Add "API" tag
- Contains "database" or "SQL" → Add "Database" tag
- Contains "deploy" or "release" → Add "Deployment" tag
- Contains "test" or "QA" → Add "Testing" tag
- Assigned to Designer → Add "Design" tag
- Linked to Epic → Add Epic's primary tags
```

#### Relationship-Based Tagging
```
Parent-Child Tag Inheritance:
- Stories inherit Epic's domain tags
- Tasks inherit Story's complexity and technology tags
- Knowledge Base entries inherit tags from linked items

Cross-Reference Tagging:
- If linked to Frontend Epic → Add "Frontend" tag
- If blocks other items → Add "Dependency" tag
- If referenced in multiple projects → Add "Shared" tag
```

### 4. Tag Validation Rules

#### Required Tag Combinations
```
All Items Must Have:
- At least 1 Project Category tag (Data-Consultancy, AI-Products, etc.)
- At least 1 Domain tag (Frontend, Backend, etc.)
- At least 1 Priority tag (Critical, High, etc.)

Projects Must Also Have:
- 1 Project Category tag (required for classification)
- Strategic or Revenue tag (if applicable)
- Timeline tag (Short-term, Long-term, Ongoing)

Tasks Must Also Have:
- 1 Complexity tag (Simple, Moderate, Complex)
- 1 Phase tag (Discovery, Development, etc.)
- Inherited Project Category from parent Epic

Epics Must Also Have:
- At least 2 Domain tags (if cross-functional)
- 1 Project reference tag
- Inherited Project Category from parent Project
```

#### Forbidden Tag Combinations
```
Mutually Exclusive:
- Simple + Complex (choose appropriate complexity)
- Critical + Low (priority conflict)
- Archive + any Priority tag (archived items don't need priority)
- Frontend + Backend (use both if truly full-stack)
```

### 5. Tag Maintenance Workflow

#### Weekly Tag Audit
```
Review Process:
1. Identify items with missing required tags
2. Check for outdated priority tags
3. Update phase tags based on current status
4. Remove deprecated or unused tags
5. Ensure tag consistency across linked items
```

#### Tag Evolution Management
```
Adding New Tags:
1. Document tag purpose and usage rules
2. Apply retroactively to relevant existing items
3. Update auto-tagging rules if applicable
4. Train team on new tag usage

Retiring Old Tags:
1. Identify replacement tags
2. Migrate items to new tag system
3. Update all documentation and rules
4. Archive old tag for historical reference
```

### 6. Tag-Based Automation

#### Smart Filtering & Views
```
Pre-Built Tag Filters:
- my-frontend-tasks: Frontend + assigned to me + not Archive
- urgent-blockers: Critical + blocks other items
- ready-for-testing: Development complete + needs Testing tag
- knowledge-gaps: missing Knowledge Base links
```

#### Tag-Triggered Actions
```
Automated Workflows:
- Critical tagged → notify stakeholders immediately
- Testing tagged → assign to QA team
- Breaking-Change tagged → require approval workflow
- Archive tagged → remove from active dashboards
```

---

# 📚 Knowledge Base Maintenance

## Maintenance Schedule Framework

### 1. Daily Maintenance (Automated + Quick Manual)

#### Automated Daily Tasks
```
Link Validation:
- Check for broken links to external resources
- Verify internal Notion page references
- Flag outdated timestamp references
- Update "last verified" dates on active entries

Content Freshness Alerts:
- Flag entries not updated in 90+ days
- Identify entries referenced in recent work but not updated
- Alert on entries with outdated technology versions
- Check for entries missing recent project links
```

#### Quick Manual Review (5-10 minutes)
```
Daily Checks:
1. Review yesterday's new Knowledge Base entries
2. Verify proper tagging on recent entries
3. Check that new Tasks/Stories have Knowledge Base links
4. Scan for duplicate or near-duplicate content

#### Content Consolidation
```
Consolidation Triggers:
- Multiple entries covering same topic
- Related entries that should be unified
- Scattered information that forms a complete guide
- Deprecated entries that can be archived

Consolidation Process:
1. Identify related entries
2. Create master comprehensive entry
3. Redirect old entries to new master
4. Update all incoming links
5. Archive obsolete individual entries
```

### 5. Knowledge Base Health Metrics

#### Quality Indicators
```
Entry Quality Score (1-10):
- Completeness: All necessary information present
- Accuracy: Information is correct and current
- Usability: Clear instructions and examples
- Discoverability: Proper tags and search terms
- Maintenance: Regular updates and verification

Database Health Metrics:
- Average entry age
- Percentage of entries updated in last 90 days
- Number of broken links
- Search success rate for common queries
- User satisfaction scores (if tracked)
```

### 6. Knowledge Capture Excellence

#### Real-Time Capture Standards
```
During Active Work:
- Document decisions and rationale immediately
- Capture failed approaches and why they didn't work
- Record useful resources, tools, and references
- Note time estimates vs. actual time for future planning

Post-Completion Capture:
- Create summary entry linking all related work
- Document lessons learned and improvements
- Record reusable patterns or templates
- Update existing entries with new insights
```

#### Knowledge Quality Gates
```
Before Publishing Knowledge Base Entry:
✅ Title clearly describes content
✅ Tags include all relevant domains and technologies
✅ Links to related Tasks, Stories, or Epics
✅ Includes practical examples or code snippets
✅ Has clear next steps or implementation guidance
✅ Specifies when information should be reviewed again
```

---

# ⚡ Bulk Operations & Automations

## Batch Processing Framework

### 1. Mass Data Operations

#### Bulk Task Creation
```
Common Scenarios:
- Converting Epic breakdown into Tasks/Stories
- Creating recurring maintenance tasks
- Importing tasks from external project plans
- Duplicating successful project templates

Batch Creation Process:
1. Prepare standardized template with all required fields
2. Create parent Epic/Story structure first
3. Generate Tasks with proper linking and tagging
4. Apply consistent naming conventions
5. Set appropriate assignees and due dates
6. Validate all required fields are populated
```

### 2. Automated Workflow Triggers

#### Status-Based Automations
```
Development Complete → Testing:
- Automatically assign to QA team
- Add "Ready for Testing" tag
- Create testing checklist Task
- Notify stakeholders of progress

Testing Complete → Deployment:
- Move to deployment queue
- Check for required approvals
- Verify all dependencies are ready
- Generate deployment checklist

Archive Trigger:
- Remove from active dashboards
- Update completion metrics
- Archive related documentation
- Preserve audit trail
```

#### Dependency-Based Automations
```
Blocking Item Resolution:
- Automatically notify dependent task assignees
- Update dependent task statuses
- Recalculate timeline estimates
- Flag potential cascading delays

Resource Availability:
- Auto-assign queued tasks when resources free up
- Rebalance workloads based on capacity
- Suggest task prioritization changes
- Update project delivery estimates
```

### 3. Template & Pattern Automation

#### Project Template Deployment
```
Template Categories:
- Data Consultancy Projects (Client analysis, implementation, success)
- AI Products Projects (Research, MVP, evolution, market strategy)
- Stock Trading Projects (Strategy development, backtesting, implementation)
- Marketing Projects (Brand strategy, content, channels, performance)
- Personal Life Projects (Development, health, learning, balance)
- Software Feature Development
- Research & Discovery Projects  
- Infrastructure Improvements
- Bug Fix Workflows
- Security Incident Response

Template Deployment Process:
1. Select appropriate template based on project type
2. Customize template with project-specific details
3. Generate full Epic/Story/Task hierarchy
4. Apply consistent tagging and categorization
5. Set initial assignments and timelines
6. Link to relevant Knowledge Base entries
```
```

### 4. Cross-Database Synchronization

#### Epic-Story-Task Consistency
```
Automatic Synchronization:
- Epic status changes propagate to child Stories
- Story completion updates Epic progress
- Task assignment changes notify Story owners
- Tag updates cascade through hierarchy
- Priority changes bubble up to parent items

Conflict Resolution:
- Child item higher priority than parent → escalate
- Parent archived but children active → flag for review
- Assignee mismatches → notify project manager
- Timeline conflicts → recalculate dependencies
```

#### Knowledge Base Integration
```
Auto-Linking Rules:
- New Tasks automatically search for relevant Knowledge Base entries
- Completed work auto-creates Knowledge Base summaries
- Knowledge Base updates trigger notifications on linked items
- Outdated Knowledge Base entries flag linked active work

Quality Assurance:
- Ensure all Epics link to strategic Knowledge Base entries
- Validate Stories have relevant technical documentation
- Check Tasks have procedural guidance links
- Flag missing Knowledge Base connections
```

### 5. Performance & Quality Automation

#### Automated Quality Checks
```
Data Integrity Validation:
- All required fields populated
- Project category assigned and consistent through hierarchy
- Consistent naming conventions
- Proper tag applications (including project-specific tags)
- Valid assignee selections
- Realistic timeline estimates
- Project budget and resource allocation validated

Workflow Validation:
- Proper Epic → Story → Task hierarchy
- Logical status progressions
- Appropriate dependency relationships
- Complete acceptance criteria
- Proper Knowledge Base linkage
```

#### Change Management
```
Change Documentation:
- Record what operations were performed
- Document who authorized and executed changes
- Track timeline of all modifications
- Preserve audit trail for compliance
- Enable change impact analysis

---

These four comprehensive sections provide actionable guidance that AI agents can immediately implement to enhance their effectiveness with your Notion-based Project Management System. Each section includes specific procedures, automation rules, and quality gates that ensure consistent, high-quality operations at scale.