---
name: Frontend Feature Implementation
description: Standardized workflow for implementing frontend features in the sib-back-office project, adhering to the Feature vs App architecture and consistent page structure.
---

# Frontend Feature Implementation

This skill provides a standardized workflow for implementing frontend features in the `sib-back-office` project. It ensures consistency with the existing architecture, specifically the separation of concerns between `features/` (logic & components) and `app/` (routing & structure).

## Architectural Principles

1.  **Feature vs. App Separation**:
    *   **Apps (`app/`)**: STRICTLY for routing and page layout. Pages should contain minimal logic.
    *   **Features (`features/`)**: Contains all business logic, UI components, server actions, and types.
2.  **Domain Integrity**:
    *   All Treasury-related code MUST reside in `features/tresorerie` or `app/(protected)/tresorerie`.
    *   Avoid modifying shared directories unless absolutely necessary (e.g., global UI components).
3.  **Page Structure Consistency**:
    *   All pages must follow a standard layout: `PageHeader` -> `PageHeroSection` -> Feature Component.

## Workflow Steps

### 1. Feature Logic (`features/`)

Start by implementing the core logic and components in the `features` directory.

**Structure:** `features/tresorerie/[feature-name]/`
*   `actions/`: Server actions for data fetching/mutations (e.g., `[feature].actions.ts`).
*   `components/`: React components (e.g., `[Feature]Client.tsx`, `[Feature]List.tsx`).
*   `types/`: TypeScript interfaces (if not shared globally).

**Example:**
```typescript
// features/tresorerie/payments/components/PaymentList.tsx
"use client";
import { Payment } from "../../types";
// ... component implementation
```

### 2. Page Assembly (`app/`)

Create or update the page in the `app` directory to display the feature.

**Structure:** `app/(protected)/tresorerie/[feature-name]/page.tsx`

**Template:**
```typescript
import { PageHeader } from "@/components/page-header";
import { PageHeroSection } from "@/components/page-hero-section";
import { LayoutDashboard } from "lucide-react"; // Use appropriate icon
import { [Feature]Client } from "@/features/tresorerie/[feature-name]/components/[Feature]Client";

export default function [Feature]Page() {
  return (
    <>
      <PageHeader
        title="[Page Title]"
        breadcrumbs={[
          { title: "Trésorerie", href: "/tresorerie" },
          { title: "[Feature]", href: "/tresorerie/[feature-name]" }
        ]}
      />

      <div className="p-4 sm:p-6 space-y-6">
        <PageHeroSection
          icon={LayoutDashboard}
          title="[Hero Title]"
          description="[Hero Description]"
        />

        {/* Feature Component */}
        <[Feature]Client />
      </div>
    </>
  );
}
```

### 3. Verification

*   Ensure TypeScript types are strictly used (no `any`).
*   Verify the page renders correctly with the Header and Hero section.
*   Confirm data fetching flows through the server actions in the features folder.

## Rules

*   **Restricted Scope**: Modifying files outside of `tresorerie` requires explicit justification.
*   **Consistency**: Do not deviate from the `PageHeader` + `PageHeroSection` pattern.
