---
name: build-phase
description: Execute a phase of the build pipeline to generate a desktop application from a Product Brief
---

# Build Phase Execution

Execute a specific phase of the 7-phase build pipeline. Each phase invokes specialized agents that read input documents and produce output documents or code.

**Usage:** `/build-phase <phase-number>`

**Arguments:**
- `$ARGUMENTS` - Phase number (1-7)

**References:**
- Build state: `docs/build-state.json`
- Product Brief: `docs/product-brief.md`

---

## Prerequisites

1. Read `docs/build-state.json` to check pipeline state
2. Verify the requested phase is unlocked:

| Phase | Requires |
|-------|----------|
| 1 | Always available |
| 2 | Phase 1 validated |
| 3 | Phase 2 validated |
| 4 | Phase 2 validated (can run alongside 3) |
| 5 | Phase 4 validated |
| 6 | Phase 4 validated (can run alongside 5) |
| 7 | Phases 5 and 6 completed |

If prerequisites are not met, tell the user which phases need to be completed/validated first and suggest the next `/build-phase` or `/build-validate` command.

---

## Phase Execution

### Phase 1 — Discovery & Specification

**Input:** `docs/product-brief.md`
**Output:** `docs/PRD.md`
**Agent:** `product-analyst` (opus)

1. Verify `docs/product-brief.md` exists and is filled in (not just the template placeholders)
2. Delegate to `product-analyst` agent via Task tool:
   > "Read docs/product-brief.md and CLAUDE.md. Generate a comprehensive PRD for this desktop application following your output structure. Write to docs/PRD.md."
3. Update `docs/build-state.json`: phase 1 status = "completed"
4. **STOP CHECKPOINT**: Display PRD summary (executive summary, feature count, persona count, platform targets, open questions) and tell user:
   > Review `docs/PRD.md`. When satisfied, run `/build-validate 1` to proceed.

---

### Phase 2 — Architecture & Design

**Input:** `docs/PRD.md`, `CLAUDE.md`
**Output:** `docs/architecture/`, `docs/database/`
**Agents:** `solution-architect` (opus) then `database-architect` (opus)

1. Delegate to `solution-architect` agent via Task tool:
   > "Read docs/PRD.md and CLAUDE.md. Design the complete desktop application architecture including C4 diagrams, IPC contract, project structure, class diagrams, and sequence diagrams. Write to docs/architecture/."
2. After architecture is complete, delegate to `database-architect` agent via Task tool:
   > "Read docs/PRD.md, docs/architecture/class-diagram.md, and docs/architecture/IPC-contract.md. Design the local database schema. Write to docs/database/."
3. Update `docs/build-state.json`: phase 2 status = "completed"
4. **STOP CHECKPOINT**: Display summary (ADR count, IPC command count, table count, key architecture decisions) and tell user:
   > Review `docs/architecture/` and `docs/database/`. When satisfied, run `/build-validate 2` to proceed.

---

### Phase 3 — Desktop UI Design

**Input:** `docs/PRD.md`, `docs/architecture/`
**Output:** `docs/design/`
**Agent:** `ui-designer` (opus)

1. Delegate to `ui-designer` agent via Task tool:
   > "Read docs/PRD.md, docs/architecture/project-structure.md, and docs/architecture/IPC-contract.md. Create the desktop design system, component map, navigation/window flow, and screen specs. Write to docs/design/."
2. Update `docs/build-state.json`: phase 3 status = "completed"
3. No checkpoint — inform user that Phase 3 is done and Phase 4 can begin.

---

### Phase 4 — Implementation

**Input:** `docs/architecture/`, `docs/database/`, `docs/design/`
**Output:** Source code
**Agents:** `core-dev` (sonnet) + `ui-dev` (sonnet) + `integration-glue` (sonnet)

<!-- AGENT_TEAMS_START -->
**With Agent Teams enabled:**

Use Agent Teams to parallelize core and UI implementation:

> Create a team with these teammates:
>
> 1. **core-dev**: "Read docs/architecture/ and docs/database/. Implement the complete core/main process: project scaffolding, domain layer, data layer, application layer, IPC handlers. Follow Clean Architecture. Scope: core directories only."
>
> 2. **ui-dev**: "Read docs/design/ and docs/architecture/IPC-contract.md. Implement the complete UI layer: scaffolding, design tokens, components (atoms → molecules → organisms → layouts → screens), IPC integration layer, state management, window management. Scope: UI directories only."
>
> 3. **integration-glue**: "After core and UI scaffolding is done, read docs/architecture/IPC-contract.md. Generate shared types, verify IPC contract compliance between core handlers and UI invocations, create .env.example, configure preload/contextBridge or equivalent. Scope: shared directories and config files only."
>
> Rule: Each agent works within its own scope. No agent modifies files in another agent's scope.
<!-- AGENT_TEAMS_END -->

<!-- NO_AGENT_TEAMS_START -->
**Sequential execution:**

1. Delegate to `core-dev` agent via Task tool:
   > "Read docs/architecture/ and docs/database/. Implement the complete core/main process following Clean Architecture."
2. Delegate to `ui-dev` agent via Task tool:
   > "Read docs/design/ and docs/architecture/IPC-contract.md. Implement the complete UI layer."
3. Delegate to `integration-glue` agent via Task tool:
   > "Read docs/architecture/IPC-contract.md. Generate shared types, verify IPC contract compliance, create .env.example."
<!-- NO_AGENT_TEAMS_END -->

4. Update `docs/build-state.json`: phase 4 status = "completed"
5. **STOP CHECKPOINT**: Display summary (files created, IPC handlers, screens implemented) and tell user:
   > Launch the application and smoke-test it. When satisfied, run `/build-validate 4` to proceed.

---

### Phase 5 — Quality Assurance

**Input:** Source code, all docs/
**Output:** Test files, `docs/qa/`, `docs/security/`
**Agents:** `test-writer` (sonnet) + `security-auditor` (sonnet)

1. Delegate to `test-writer` agent via Task tool:
   > "Read the source code and all docs/. Write comprehensive tests (unit, integration, desktop E2E). Write test plan to docs/qa/."
2. Delegate to `security-auditor` agent via Task tool:
   > "Perform a Phase A comprehensive security audit of the entire codebase, focusing on IPC surface, contextBridge exposure, local data storage, and OS permission usage. Write audit report to docs/security/audit-report.md and threat model to docs/security/threat-model.md."
3. Run the test suite to verify tests pass:
   ```
   {{TEST_COMMAND_CORE}}
   {{TEST_COMMAND_UI}}
   {{E2E_TEST_COMMAND}}
   ```
4. Update `docs/build-state.json`: phase 5 status = "completed"
5. Report test results and security findings summary to user.

---

### Phase 6 — Build & Distribution

**Input:** Source code, `docs/architecture/`
**Output:** Packaging config, CI/CD, `docs/devops/`
**Agent:** `devops-engineer` (sonnet)

1. Delegate to `devops-engineer` agent via Task tool:
   > "Read docs/architecture/ and CLAUDE.md. Create desktop app packaging configuration, multi-platform CI/CD pipeline, code signing setup, and distribution documentation in docs/devops/."
2. Update `docs/build-state.json`: phase 6 status = "completed"
3. Report deliverables to user (packaging targets, CI platforms, distribution method).

---

### Phase 7 — Documentation & Delivery

**Input:** All docs/, source code
**Routing:** Depends on `DOC_TARGET` setting in CLAUDE.md (value: `{{DOC_TARGET}}`)

#### If DOC_TARGET is "local":

**Output:** `README.md`, `docs/developer-guide.md`
**Agent:** `technical-writer` (sonnet)

1. Delegate to `technical-writer` agent via Task tool:
   > "Read all docs/ and source code. Create the final README.md and docs/developer-guide.md for this desktop application."
2. Update `docs/build-state.json`: phase 7 status = "completed"

#### If DOC_TARGET is "notion":

**Output:** Notion documentation database pages
**Agent:** None (main thread handles Notion MCP calls directly)

1. Read all `docs/` files and source code to understand the full project
2. Load Notion MCP tools via ToolSearch
3. Fetch the Notion enhanced markdown spec via `ReadMcpResourceTool` (server: "claude.ai Notion", uri: "notion://docs/enhanced-markdown-spec")
4. Create documentation pages in the Notion database (data source ID from CLAUDE.md `NOTION_DATABASE_ID`) with these topics:
   - **Getting Started** (Tutorial, Audience: Developers + End Users)
   - **Architecture Overview** (Explanation, Audience: Developers)
   - **IPC Contract & Module Development Guide** (How-To, Audience: Developers)
   - **Build & Distribution Guide** (How-To, Audience: Developers + Operations)
   - **Release & Update Runbook** (How-To, Audience: Developers + Operations)
   - **Security Considerations** (Reference, Audience: Developers + Operations)
5. Each page must include: Version property (1.0), Audience, Doc Type, Status (Published), version history callout + table
6. Update the Master Table of Contents page with `<mention-page>` links to all created pages
7. Update `docs/build-state.json`: phase 7 status = "completed"

#### If DOC_TARGET is "both":

1. First, follow the "local" path (delegate to `technical-writer` for README.md + developer-guide.md)
2. Then, follow the "notion" path (create Notion pages via MCP tools)
3. Update `docs/build-state.json`: phase 7 status = "completed"

#### Checkpoint (all targets):

**STOP CHECKPOINT**: Display delivery summary and tell user:
   > The build pipeline is complete. Run `/build-validate 7` to accept delivery. The project will then transition to Phase B (Issue Lifecycle) for ongoing development.

---

## Error Handling

If an agent fails or produces incomplete output:
1. Do NOT update build-state.json to "completed"
2. Report the failure to the user
3. Suggest re-running the same phase: `/build-phase $ARGUMENTS`

**This skill manages the build pipeline. Do not skip phases or bypass checkpoints.**
