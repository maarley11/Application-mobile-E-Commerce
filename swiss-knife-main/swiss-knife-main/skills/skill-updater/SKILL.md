---
name: skill-updater
description: Meta-skill outlining the workflow, criteria, and formatting rules for safely and effectively updating an existing AI coding agent skill based on newly discovered patterns or project context.
origin: ECC
---

# Skill Updater (Meta-Skill)

This document provides a template and guidelines for **updating an existing AI skill** (`.agent/skills/<skill-name>/SKILL.md`). A skill should never be static; it must evolve as the team discovers new edge cases, updates frameworks, or identifies recurring bugs.

## When to Activate

- You (the AI) encountered a recurring bug that violates an existing skill, and you want to prevent it from happening again.
- The user explicitly asks to update a skill to reflect a new architectural decision, framework version, or coding standard.
- You realize a current skill is too theoretical and needs more concrete code snippets.

## The Skill Update Workflow

Before modifying an existing `SKILL.md`, follow this systematic approach:

### 1. Read & Analyze the Existing Skill
**Always** use `view_file` to read the entire target `SKILL.md` before making any edits. Understand its current scope, triggers (`When to Activate`), and existing patterns.

### 2. Identify the "Missing Link"
Determine why the update is necessary:
- **Resilience Gap**: A common exception (e.g., `UnexpectedRollbackException`) wasn't covered.
- **Context Gap**: The skill lacks framework-specific details (e.g., using `BigDecimal.ZERO` as a fallback).
- **Format Gap**: The skill consists of text blocks without exact code snippets (violating the `Show, Don't Tell` rule).

### 3. Apply the "Skill Creator" DNA
When injecting the update, ensure it adheres strictly to the `skill-creator` format:

- **Concrete Examples ONLY**: Do not add paragraphs of theory. Add a new `###` section containing exactly what to type.
- **Use BAD vs. GOOD**: Show the incorrect approach that triggered the update, followed immediately by the correct, standard approach.
- **Update the Activation Rules**: If the update introduces a new topic (e.g., "Adding Rate Limiting"), ensure you add a bullet point under the `## When to Activate` section.
- **Update the Checklist**: If the new pattern requires manual verification during a PR review, append a checkbox to the `## Checklist Before Release` at the bottom.

## Standard Update Structure (Example)

When appending a new Resilience Pattern to a Backend Skill, format your edit like this:

```markdown
### N. [Name of the New Pattern/Pitfall]

Explain the specific risk or error in 1-2 sentences.

```java
// BAD: Why the previous approach fails
@Transactional
public void process() {
   try { ... } catch (Exception e) {} // Leads to UnexpectedRollbackException
}

// GOOD: The correct, highly-actionable template
@Transactional(noRollbackFor = Exception.class)
public void safeProcess() { ... }
```
```

## Anti-Patterns for Updating Skills

- **BAD: Deleting Existing Context**: Unless explicitly instructed, do not rewrite the entire skill or delete existing core patterns just to add a new one. **Append** or strategically inject.
- **BAD: Adding Theoretical Noise**: "It is important to secure endpoints because hackers can steal data." → We know. Only add *how* to secure it.
- **BAD: Over-Generalizing**: Don't add a React-specific hook optimization to a generic Kafka event-streaming skill. If the topic is diverging too far, propose creating a *new* skill instead.

## Goal

Treat skill updates like open-source contributions. Every update must leave the skill more actionable, more pragmatic, and richer in immediately usable code snippets than it was before you touched it.
