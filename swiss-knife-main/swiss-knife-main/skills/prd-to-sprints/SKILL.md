---
description: Chunks a Product Requirements Document (PRD) into cohesive feature-based markdown documents with cross-feature context and end-to-end execution details.
---

# PRD to Feature Chunks (prd-to-sprints)

Use this skill when the user asks to break down a Product Requirement Document (PRD) into actionable execution phases, feature chunks, or sprints.

## 🎯 Primary Goal
Transform a monolithic PRD into robust, isolated-yet-coherent Feature Chunk Markdown files. Because AI models execute these chunks independently (sometimes in parallel), each document must contain enough overlapping context and global architecture constraints to prevent hallucinated inconsistencies. Moving away from time-based "sprints," we group work by cohesive features to ensure complete end-to-end functionality per chunk.

## 🔄 Workflow

1. **Analyze the PRD & Context**: Read the provided PRD to understand the core features, tech stack, data models, and end-to-end scope.
2. **Decompose into Feature Chunks**: Group the work into logical, cohesive features (e.g., User Authentication, Financial Dashboard, Report Generation) rather than arbitrary time-boxes.
3. **Generate Markdown Files**: For each feature, create a sequenced markdown file **in the root directory of the project**, following the strict naming convention `feature-XX-[name].md` (e.g., `feature-01-auth-system.md`).
4. **Generate Master Tracker**: Create an overarching `features-index.md` file in the root directory acting as a table of contents and dependency graph to track the overall progress and status of all feature chunks.

## 📄 Feature Chunk Document Template
Each generated feature markdown file MUST strictly adhere to this template:

```markdown
# Feature [Number]: [Feature Name]
> **Goal**: [1-sentence summary of the feature's end-to-end purpose]

## 🔗 Context & Dependencies
* **Required Pre-requisites**: [Brief summary of which earlier features must be completed before starting this one. If this is foundational (Feature 01), specify "None - Project Foundation".]
* **Enables Downstream Features**: [Brief summary of future features that will rely on the implementation of this feature. This ensures correct API/contract design.]

## 🎯 Core Objectives & Tasks
[List the high-level goals of this feature. Task granularity MUST be kept at high-level Epic goals covering vertical slices (e.g. "Implement authentication flow: DB schema + API + UI" rather than "Write auth router syntax").]
- [ ] Sub-feature / Vertical Slice 1
- [ ] Sub-feature / Vertical Slice 2

## 🌐 End-to-End Execution Guidelines
[CRITICAL: Include this section in EVERY feature document to ensure parallel implementation doesn't break the project integration.]
* **Architecture Stack**: [e.g., Next.js App Router for frontend, FastAPI for backend. No exceptions.]
* **Target Data Models / State**: [Mention any shared database tables (e.g., "Users", "Jobs") or global state accessed during this feature]
* **API Contracts & Interfaces**: [List API endpoints or interfaces this feature must expose or respect.]
* **Testing & Deployment Restrictions**: [e.g., "Must write pytest cases with 80% coverage. Must not alter docker-compose.yml without explicit permission."]
```

## 🚨 Feature Grouping Pattern (BAD vs. GOOD)

When transforming the PRD, focus on vertical feature slices, not horizontal engineering layers or simple time-boxed sprints.

```markdown
<!-- BAD: Time-boxed or horizontal layer sprints -->
# Sprint 1: Database Setup
- [ ] Create all database tables for the whole app
# Sprint 2: All APIs
- [ ] Create all REST endpoints for the whole app

<!-- GOOD: Vertical, cohesive feature chunks -->
# Feature 01: Core Authentication
- [ ] Database users table
- [ ] Auth API endpoints
- [ ] Login/Register UI

# Feature 02: Candidate Dashboard
- [ ] Candidate profile tables
- [ ] Profile retrieval APIs
- [ ] Dashboard UI components
```

## 🚨 Core Rules
- **Vertical Slices**: Features must represent complete, testable vertical slices of functionality.
- **No Isolated Features**: Never generate a feature chunk that lacks the "Context & Dependencies" or "End-to-End Execution" blocks.
- **Root Directory Naming**: Feature documents and the master tracker MUST be placed directly in the project root. File names must sequence starting with `feature-01-`, `feature-02-`.
- **Master Tracker**: You MUST always generate `features-index.md`.
- **Global Context Overload Requirement**: The "End-to-End Execution Guidelines" section MUST be virtually identical across all feature chunks for a given project. It acts as the immutable constitution for the agent executing that specific task.
