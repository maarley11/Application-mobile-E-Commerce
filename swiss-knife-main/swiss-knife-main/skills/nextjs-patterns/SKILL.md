---
description: Patterns and best practices for minimal Next.js testing UIs.
---

# Minimal Next.js Testing UI Patterns

This skill defines the preferred patterns for creating minimal, functional frontend applications in Next.js designed for testing backend features, rather than building complete consumer-facing products.

## 1. Zero-Friction Setup
- **Rule**: Use Next.js App Router with default configurations. 
- **Pattern**: `npx -y create-next-app@latest ./app-name --typescript --tailwind --eslint --app --no-src-dir --import-alias "@/*" --use-npm`

## 2. Minimalist Styling
- **Rule**: Avoid fancy animations, complex transitions, and overly engineered CSS.
- **Pattern**:
    - Use standard Tailwind utility classes for basic layout (`flex`, `grid`, `p-4`, `m-2`).
    - Stick to basic borders and highly legible standard typography.
    - Focus on structural clarity over aesthetic polish.

## 3. Data Fetching & State
- **Rule**: Use simple React Hooks (`useState`, `useEffect`) for testing rather than complex state management libraries (no Redux, no Zustand unless absolutely necessary).
- **Pattern**:
    - Build simple `fetch()` wrappers for calling backend APIs.
    - Display raw JSON responses in `<pre><code>` blocks if it helps debugging.

## 4. Component Structure
- **Rule**: Keep components large and consolidated for testing setups.
- **Pattern**: Use single-file pages (`app/page.tsx`) with inline sub-components if it reduces boilerplate, only extracting components when they are reused across multiple test views.

## 5. Error Visibility
- **Rule**: Always show errors on screen.
- **Pattern**: If an API call fails, render the error message visibly in the UI (e.g., a simple red text block) mapping to the backend's HTTP status.
