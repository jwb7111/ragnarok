# Loki Mode Example PRDs

Sample Product Requirement Documents for testing Loki Mode at different complexity levels.

## Quick Start

1. Choose a PRD from the appropriate complexity level
2. Copy it to your project directory
3. Run Loki Mode with the PRD

```bash
# Example: Run the static landing page
cp examples/beginner/static-landing.md ./PRD.md
claude --dangerously-skip-permissions -p "Loki Mode with PRD at ./PRD.md"
```

## Complexity Levels

### Beginner (5-15 minutes)

Perfect for testing your setup and understanding Loki Mode basics.

| PRD | Description | Agents Used |
|-----|-------------|-------------|
| [static-landing.md](beginner/static-landing.md) | Responsive landing page | frontend, deployer |

### Intermediate (30-60 minutes)

Full-stack applications with authentication and database.

| PRD | Description | Agents Used |
|-----|-------------|-------------|
| [todo-app.md](intermediate/todo-app.md) | CRUD app with auth | frontend, backend, database, tester |

### Advanced (2-4 hours)

Production-ready applications with complex integrations.

| PRD | Description | Agents Used |
|-----|-------------|-------------|
| [saas-starter.md](advanced/saas-starter.md) | SaaS with teams + billing | All agents + compliance |

### Showcase

Complete, tested implementations with honest results.

| Project | Description | Status |
|---------|-------------|--------|
| [Invoice Tracker](/poc/invoice-tracker/) | Full invoicing SaaS | POC |

## PRD Template

Use [PRD-TEMPLATE.md](PRD-TEMPLATE.md) to create your own PRDs. Key sections:

- **Metadata**: Complexity, time estimate, agents required
- **User Stories**: Who uses this and why
- **Functional Requirements**: What it must do
- **Non-Functional Requirements**: Performance, security, accessibility
- **Tech Stack**: Suggested technologies with rationale
- **Data Model**: Entity definitions
- **API Endpoints**: REST/GraphQL endpoints
- **Success Criteria**: Definition of done

## Tips for Writing PRDs

1. **Be specific**: "User authentication" is too vague. "Email/password auth with JWT" is better.

2. **Prioritize clearly**: Use P0/P1/P2 labels. Loki Mode will focus on P0 first.

3. **Include constraints**: If you need specific versions or tech, say so explicitly.

4. **Define success**: What does "done" look like? Include testable criteria.

5. **Note out-of-scope**: Prevents scope creep by being explicit about limits.

## Expected Results

| Complexity | Success Rate | Interventions | Cost |
|------------|--------------|---------------|------|
| Beginner | ~90% | 0-1 | < $2 |
| Intermediate | ~70% | 1-3 | < $10 |
| Advanced | ~50% | 3-5 | < $30 |

*These are estimates. Actual results depend on PRD quality, environment, and network conditions.*

## Contributing

To add a new example PRD:

1. Use the template
2. Test it with Loki Mode
3. Include expected results
4. Submit a PR

We need examples for:
- Python/Django stack
- Go backend
- Mobile (React Native)
- CLI tools
- Browser extensions
