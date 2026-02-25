# Claude Code Agents Orchestration Template — Desktop

A comprehensive template for building **desktop applications** from scratch using agent orchestration, then maintaining them with a full issue lifecycle. Combines a **7-phase build pipeline** (Phase A) with an **issue lifecycle workflow** (Phase B).

Supports any desktop tech stack: **Electron**, **Tauri**, **Qt**, **.NET WinForms/WPF**, **Swift/AppKit**, **Flutter Desktop**, and more.

## Two-Phase Architecture

### Phase A — Build Pipeline (New Project)

7-phase agent orchestration that transforms a Product Brief into a packaged desktop application:

| Phase | Name | Agent(s) | Output |
|-------|------|----------|--------|
| 1 | Discovery & Specification | `product-analyst` | `docs/PRD.md` |
| 2 | Architecture & Design | `solution-architect` + `database-architect` | `docs/architecture/`, `docs/database/` |
| 3 | Desktop UI Design | `ui-designer` | `docs/design/` |
| 4 | Implementation | `core-dev` + `ui-dev` + `integration-glue` | Source code |
| 5 | Quality Assurance | `test-writer` + `security-auditor` | Tests, `docs/qa/`, `docs/security/` |
| 6 | Build & Distribution | `devops-engineer` | Packaging, CI/CD, `docs/devops/` |
| 7 | Documentation & Delivery | `technical-writer` | `README.md`, `docs/developer-guide.md` |

Human checkpoints after phases 1, 2, 4, and 7 ensure quality at each stage.

```
/build-phase 1       → Discovery: produces PRD → STOP
/build-validate 1    → User validates → unlocks phase 2
/build-phase 2       → Architecture (IPC contract, not REST) → STOP
/build-validate 2    → User validates → unlocks phases 3-4
/build-phase 3       → Desktop UI design (screens, not web pages)
/build-phase 4       → Implementation (core + UI + IPC glue) → STOP
/build-validate 4    → User smoke-tests the app → unlocks phases 5-7
/build-phase 5       → QA: tests + security (IPC surface focus)
/build-phase 6       → Packaging: installers + code signing + CI/CD
/build-validate 7    → Final delivery → transitions to Phase B
```

### Phase B — Issue Lifecycle (Ongoing Maintenance)

Two workflow tiers for ongoing development:

- **Dev workflow:** `/create-issue` → `/start-issue` → `/ready-for-testing` → `/start-testing` → `/approve-testing` → `/deploy-issue`
- **Lightweight workflow:** `/create-issue` → `/start-issue` → `/close-issue`

## What's Included

### Build Pipeline Skills (3 skills)
- `/build-phase <1-7>` — Execute a build pipeline phase
- `/build-validate <1,2,4,7>` — Validate and approve a phase checkpoint
- `/build-status` — Display pipeline progress

### Issue Lifecycle Skills (9 skills)
Complete GitHub-integrated workflow with Dev and Lightweight tiers.

### Build Pipeline Agents (10 agents)
- **product-analyst** — PRD generation from Product Brief (desktop-aware: screens, platform targets, offline capability)
- **solution-architect** — System architecture, ADR, C4 diagrams, **IPC contract** (not REST/OpenAPI)
- **database-architect** — Local database schema, MCD, MLD, migrations (SQLite, LevelDB, etc.)
- **ui-designer** — Desktop design system, component map, **screen specs** (not web page specs)
- **core-dev** — Core/main process implementation (Clean Architecture, IPC handlers, OS APIs)
- **ui-dev** — UI layer implementation (keyboard-first, dark/light mode, OS conventions)
- **integration-glue** — Shared types, **IPC contract verification** (contextBridge, Tauri commands)
- **test-writer** — Unit, integration, **desktop E2E** test creation
- **devops-engineer** — App **packaging**, code signing, multi-platform CI/CD, **distribution docs**
- **technical-writer** — README, developer guide

### Lifecycle Agents (6 agents)
- **code-reviewer** — Quality, security, conventions review
- **debugger** — Root cause investigation
- **security-auditor** — IPC surface analysis, local data security, OS permission audit
- **test-runner** — Run tests, report results
- **test-generator** — Write tests following project patterns
- **ui-builder** — UI components and screens

### Quick Commands (4 commands)
- `/review` — Review staged changes
- `/test` — Run all tests
- `/status` — Project dashboard
- `/check-deploy` — Pre-release checklist

### Safety Hooks (3 hooks)
- **safe-bash.sh** — Blocks destructive git ops, prevents committing secrets
- **session-warnings.sh** — Warns about uncommitted data and multiple branches
- **auto-format.sh** — Auto-formats Python and JS/TS on save

### Optional Features
- **Agent Teams** — Parallel implementation in Phase 4 (core + UI + integration agents working simultaneously)
- **Notion Integration** — Two-tier documentation governance: local docs + Notion for humans

## Desktop vs Web Template — Key Differences

| Aspect | Web Template | Desktop Template |
|--------|-------------|-----------------|
| Architecture contract | OpenAPI / REST | IPC contract (Electron, Tauri, etc.) |
| Phase 3 | Frontend designer (web pages, 375px) | UI designer (screens, OS conventions) |
| Phase 4 agents | `backend-dev` + `frontend-dev` | `core-dev` + `ui-dev` |
| Phase 6 | Docker + GitHub Actions deploy | App packaging + code signing + distribution |
| E2E testing | Playwright web | Desktop E2E (Playwright + electron, tauri-driver, etc.) |
| Dev mode | Frontend/backend dev servers + ports | Single app launch command |
| Release | Deploy to server | Package installer (`.dmg`, `.exe`, `.AppImage`) |

## Prerequisites

- **GitHub CLI** (`gh`) — installed and authenticated
- **jq** — for auto-detecting GitHub Project IDs
- **GitHub Projects V2 board** (auto-created during setup)

## Quick Start

### Interactive (prompted)

```bash
# 1. Clone the template
git clone <template-repo-url> my-desktop-app
cd my-desktop-app

# 2. Remove template git history
rm -rf .git

# 3. Run setup
bash setup.sh
```

### Non-interactive (config file)

```bash
git clone <template-repo-url> my-desktop-app
cd my-desktop-app
rm -rf .git

cp setup.env.example setup.env
# Edit setup.env with your values...

bash setup.sh --config setup.env
```

The setup script will:
1. Ask for project name, GitHub repo, app build/launch commands
2. Auto-detect or create GitHub Project board with all required fields
3. Ask about Agent Teams (parallel Phase 4) and Notion integration
4. Replace all `{{PLACEHOLDER}}` values across all files
5. Strip unused conditional sections (Agent Teams, Notion)
6. Inject Agent Teams env var into settings.json if enabled
7. Verify the configuration
8. Optionally initialize a git repo with initial commit
9. Self-delete

## After Setup

1. **Review `CLAUDE.md`** — Customize rules for your project
2. **Fill in `docs/product-brief.md`** — Describe your desktop app, users, features, platform targets
3. **Run `/build-phase 1`** — Start the build pipeline
4. **Follow the pipeline** — Validate each checkpoint, run phases in order
5. **After Phase 7** — The project transitions to Phase B for ongoing development

## File Structure

```
.claude/
├── settings.json              # Hook configuration + Agent Teams env
├── settings.local.json        # Permission allowlist
├── hooks/                     # Safety and formatting hooks
├── skills/                    # Build pipeline (3) + Issue lifecycle (9)
├── commands/                  # Quick commands (4)
└── agents/                    # Build (10) + Lifecycle (6) agents

docs/
├── product-brief.md           # Your desktop app description (fill in)
├── build-state.json           # Pipeline state tracker
├── architecture/              # Phase 2 output (ADR, C4, IPC contract)
├── database/                  # Phase 2 output (MCD, MLD, data dictionary)
├── design/                    # Phase 3 output (design system, screen specs)
├── qa/                        # Phase 5 output (test plan, coverage)
├── security/                  # Phase 5 output (audit report, threat model)
├── devops/                    # Phase 6 output (packaging, CI/CD docs)
└── claude/
    ├── INDEX.md               # Documentation index
    ├── context/               # System knowledge (fill in post-build)
    ├── operations/            # Process configuration
    ├── issues/                # Temp working docs (auto-managed)
    └── diagrams/              # Architecture diagrams

start-app.sh                   # App launcher (dev/build/package)
CLAUDE.md                      # Main Claude instructions
```

## Git Workflow

```
main (production) ← develop (integration) ← feature/<issue>-<desc> (work)
```

## Commit Convention

```
<type>: <description>

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`
