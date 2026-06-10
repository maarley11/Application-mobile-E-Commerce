---
name: API Registry & Gap Analysis
description: Standardized workflow for registering required backend APIs, mapping them to frontend features, and tracking implementation gaps.
---

# API Registry & Gap Analysis

This skill defines the process for maintaining a "Source of Truth" regarding the APIs required by the frontend and their status in the backend.

## Purpose
To prevent "integration hell" where frontend components are built for non-existent or mismatched backend endpoints. This registry serves as a contract between Frontend and Backend development.

## The API Registry File
The registry is maintained in `docs/api_registry.md` (or a similar central location).

### Format
The registry should use a table format for clarity:

| Feature | Action / Use Case | Required Endpoint | Method | Backend Status | implementation Note |
|:---|:---|:---|:---|:---|:---|
| Dashboard | Fetch Snapshot | `/api/treasury/snapshot` | GET | ✅ Ready | `TreasuryController` |
| Dashboard | Cash Flow History | `/api/treasury/cash-flows` | GET | ❌ Missing | **MOCKED** in `treasury-actions.ts` |

## Workflow

### 1. When Planning a New Feature
Before writing code:
1.  **Identify Data Needs**: List every piece of data the UI requires.
2.  **Check Registry**: See if endpoints already exist.
3.  **Check Backend**: If not in registry, use `find_by_name` or `grep_search` in the backend codebase to find matching controllers.
4.  **Register**: Add the requirements to the `api_registry.md`.
    *   If found: Mark as ✅ Ready.
    *   If not found: Mark as ❌ Missing.

### 2. When Implementing Frontend
1.  **Strict Typing**: Define TypeScript interfaces that match the *expected* API response.
2.  **Mocking**: If Backend Status is ❌ Missing, implement a fallback mock in the Server Action (as seen in `treasury-actions.ts`).
    *   *Crucial*: Add a `console.warn` or `TODO` comment indicating this is a mock.
3.  **Update Registry**: Update the "Implementation Note" with the file path where the fetch/mock happens.

### 3. When Backend Updates
1.  **Verify**: Test the new endpoint.
2.  **Update Registry**: Change Status to ✅ Ready.
3.  **Refactor**: Remove the mock data and point `treasury-actions.ts` to the real endpoint.

## Integration Commands
Use these commands to quickly scan for usage:
- **Scan Mocks**: `grep -r "MOCK" features/` to find technical debt.
- **Scan API Calls**: `grep -r "serverGet" features/` to list all integration points.
