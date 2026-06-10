---
name: skill-creator
description: Meta-skill outlining the structure, patterns, and best practices for creating highly effective skills for an AI coding agent.
origin: ECC
---

# Skill Creator (Meta-Skill)

This document provides a template and guidelines for creating new skills. A "skill" is a markdown file that guides an AI agent's behavior for a specific technology, workflow, or pattern. The goal of a skill is to maximize the agent's contextual awareness and code accuracy.

## When to Activate

- Writing a new `.agent/skills/<skill-name>/SKILL.md` file
- Reviewing or heavily refactoring an existing skill
- Defining new engineering standards for a team

## The Perfect Skill Structure

An effective skill is highly pragmatic. It prioritizes exact code snippets, clear triggers, and actionable checklists over abstract theories. 

Every skill MUST follow this structure:

### 1. YAML Frontmatter
Used by the AI router to evaluate if reading this skill is necessary.
```yaml
---
name: short-descriptive-name
description: A 1-2 sentence heavily keyworded summary of what the skill covers and when it should be used.
origin: ECC
---
```

### 2. The Activation Section (`## When to Activate`)
The very first markdown section should be a bulleted list of triggers. This helps the AI context-match the user's prompt to the skill.

```markdown
## When to Activate

- Setting up X technology for the first time
- Debugging Y common error
- Implementing Z architectural pattern
```

### 3. Concrete Code Snippets (The "Show, Don't Tell" Rule)
AI agents work best with explicit examples rather than philosophical instructions. Use code blocks for configurations, standard implementation structures, or Dockerfiles.

```markdown
## Standard Implementation

```java
// GOOD: Provide the exact standard template required
@RestController
@RequestMapping("/api/resource")
@RequiredArgsConstructor
public class ConcreteResourceController { ... }
```
```

### 4. Pragmatic Rule Enforcements & Anti-Patterns
Contrast "BAD" vs "GOOD" code. This acts as a boundary constraint to prevent the AI from hallucinating incorrect patterns or applying basic tutorials that violate enterprise standards.

```markdown
## Common Pitfalls

- **BAD**: Doing `X` because it creates N+1 queries.
- **GOOD**: Using `JOIN FETCH` (example code) to resolve it.

```java
// BAD: Concatenation
String q = "SELECT * FROM users WHERE name = '" + name + "'";

// GOOD: Parameterized
String q = "SELECT * FROM users WHERE name = :name";
```
```

### 5. Final Checklist (`## Checklist Before Release`)
If the skill involves a multi-step workflow (like creating a feature or securing an API), provide a checklist. The AI agent can loop through this list during Code Review requests.

```markdown
## Review Checklist

- [ ] Are logs masking sensitive PII?
- [ ] Is the DTO safely handling nulls with defaults?
- [ ] Is the transaction boundary correctly marked `noRollbackFor=Exception.class` for read operations?
```

## Anti-Patterns of Skill Creation

- **BAD: Being Too Theoretical**: Explaining the *history* of REST instead of showing the exact `@RestController` template the project uses.
- **BAD: Missing the "When"**: Failing to define the trigger points, causing the AI to over-apply or under-apply the skill.
- **BAD: Mixing Domains**: A single skill shouldn't cover both "React UI Patterns" and "PostgreSQL Indexing". Break them up into `frontend-patterns` and `db-optimization`.

## Example High-Quality Skills

- `spring-security-config`: Focuses deeply on practical Auth, CSRF, input validation, and rate-limiting snippets.
- `docker-patterns`: Provides exact Dev vs Prod `docker-compose.yml` templates and Volume strategies.
- `spring-boot-patterns`: Gives the literal MVC Controller/Service/Repo blueprints with DTO constraints.

## Goal

Create skills that feel like an "Internal Tech Lead's Cheat Sheet". The AI should be able to read your skill and immediately produce production-ready code that matches your specific enterprise standards.
