# {Project Name}

<!--
PRD Template for Loki Mode
Copy this template and fill in the sections below.
-->

## Metadata

| Field | Value |
|-------|-------|
| **Complexity** | Beginner / Intermediate / Advanced |
| **Estimated Time** | X minutes/hours |
| **Agents Required** | implementer, tester, reviewer, deployer |
| **Prerequisites** | Node.js 18+, npm |

## Executive Summary

{2-3 sentences describing what we're building and why.}

## User Stories

```
As a [user type], I want to [action] so that [benefit].
```

1. As a user, I want to {action} so that {benefit}.
2. As an admin, I want to {action} so that {benefit}.

## Functional Requirements

### Feature 1: {Feature Name}

**Priority:** P0 (Must Have) | P1 (Should Have) | P2 (Nice to Have)

- [ ] Requirement 1.1: {Description}
- [ ] Requirement 1.2: {Description}

### Feature 2: {Feature Name}

**Priority:** P0

- [ ] Requirement 2.1: {Description}

## Non-Functional Requirements

### Performance
- API response time: < {X}ms p99
- Page load time: < {X}s
- Concurrent users: {X}

### Security
- Authentication: {method}
- Authorization: {method}
- Data encryption: {at rest / in transit}

### Accessibility
- WCAG Level: {A / AA / AAA}

### Reliability
- Uptime target: {X}%
- RTO: {X} hours
- RPO: {X} hours

## Tech Stack (Suggested)

| Layer | Technology | Rationale |
|-------|------------|-----------|
| Frontend | {React, Vue, etc.} | {Why this choice} |
| Backend | {Node, Python, etc.} | {Why this choice} |
| Database | {Postgres, MongoDB, etc.} | {Why this choice} |
| Hosting | {Vercel, AWS, etc.} | {Why this choice} |

## Data Model

### Entity: {EntityName}

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | Yes | Primary key |
| {field} | {type} | {Yes/No} | {Description} |

## API Endpoints

### {Resource}

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/{resource} | List all {resources} |
| POST | /api/{resource} | Create new {resource} |
| GET | /api/{resource}/:id | Get single {resource} |
| PUT | /api/{resource}/:id | Update {resource} |
| DELETE | /api/{resource}/:id | Delete {resource} |

## UI Wireframes

{Describe key screens or link to wireframes}

### Screen 1: {Name}
- Purpose: {what the screen does}
- Key elements: {list of UI elements}

## Success Criteria

### Definition of Done
- [ ] All P0 requirements implemented
- [ ] Tests passing with > {X}% coverage
- [ ] No critical/high security vulnerabilities
- [ ] Lighthouse score > {X}
- [ ] Documentation complete

### Acceptance Tests
1. {User can accomplish X workflow}
2. {System handles Y error gracefully}

## Out of Scope

- {Feature that will NOT be built}
- {Integration that will NOT happen}

## Open Questions

1. {Question that needs clarification}
2. {Decision that needs to be made}

## Appendix

### Glossary
- **{Term}**: {Definition}

### References
- {Link to relevant documentation}
