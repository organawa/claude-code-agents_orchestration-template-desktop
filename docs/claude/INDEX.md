# Documentation Index

**Project:** {{PROJECT_NAME}}

## Context Files

These files provide Claude with understanding of the system. Read only when needed.

| File | Purpose | Last Updated |
|------|---------|-------------|
| `context/ARCHITECTURE.md` | System architecture, components, data flow | {{DATE}} |
| `context/API_REFERENCE.md` | Endpoints, models, schemas, key files | {{DATE}} |
| `context/CODE_PATTERNS.md` | Code conventions, patterns, tech stack | {{DATE}} |
| `context/ENVIRONMENTS.md` | Dev/prod environments, URLs, services | {{DATE}} |
| `context/INFRASTRUCTURE.md` | Deployment, Docker, CI/CD | {{DATE}} |

## Operations Files

These files define processes and configuration for day-to-day operations.

| File | Purpose | Last Updated |
|------|---------|-------------|
| `operations/GITHUB_CONFIG.md` | GitHub Project field IDs, status values, CLI templates | {{DATE}} |
| `operations/WORK_ITEMS.md` | Epic/Story/Task hierarchy, story points, DoD | {{DATE}} |
| `operations/TROUBLESHOOTING.md` | Debug procedures, common issues, solutions | {{DATE}} |

## Build Pipeline Outputs

These files are produced during Phase A (Build Pipeline) and serve as inputs across phases.

| File/Directory | Purpose | Phase |
|---------------|---------|-------|
| `docs/product-brief.md` | User input — product description, features, constraints | Input |
| `docs/build-state.json` | Pipeline state tracker (phase status, checkpoints) | All |
| `docs/PRD.md` | Product Requirements Document | 1 |
| `docs/architecture/` | ADR, C4, API contract, project structure, diagrams | 2 |
| `docs/database/` | MCD, MLD, data dictionary, migration strategy | 2 |
| `docs/design/` | Design system, component map, page specs, navigation | 3 |
| `docs/qa/` | Test plan, coverage reports | 5 |
| `docs/security/` | Security audit report, threat model | 5 |
| `docs/devops/` | Docker, CI/CD, deployment documentation | 6 |

## Temporary Files

| Directory | Purpose |
|-----------|---------|
| `issues/ISSUE-*.md` | Working docs for active issues. Created by `/start-issue`, deleted by `/deploy-issue` or `/close-issue`. |

## Maintenance

- **Context files** are updated during `/deploy-issue` or `/close-issue` when relevant changes occur
- **Operations files** are updated when GitHub config or processes change
- **Issue docs** are temporary and should not accumulate — clean up after closing

<!-- NOTION_START -->
## Documentation Governance

- **Local docs** (`docs/claude/`): Machine-readable context for Claude. Updated automatically during issue lifecycle.
- **Notion docs**: Human-readable documentation. Created/updated during `/deploy-issue` or `/close-issue` consolidation.
- Every Notion doc must have: Version, Audience, Doc Type, version history callout + table.
<!-- NOTION_END -->
