#!/bin/bash
# Claude Code Project Template - Setup Script
# Replaces all {{PLACEHOLDER}} values with your project configuration
#
# Usage:
#   Interactive:     bash setup.sh
#   Non-interactive: bash setup.sh --config setup.env
#
# Prerequisites: GitHub CLI (gh) installed and authenticated, jq installed
# Windows users: Run this script in Git Bash or WSL (not PowerShell or cmd)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE=""
NON_INTERACTIVE=false

# ─── Portable sed -i (macOS BSD vs Linux/Windows GNU) ─────
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed_inplace() { sed -i '' "$@"; }
else
    # Linux, Git Bash (MSYS/MINGW), WSL — all use GNU sed
    sed_inplace() { sed -i "$@"; }
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --config)
            CONFIG_FILE="$2"
            NON_INTERACTIVE=true
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: bash setup.sh [--config <env-file>]"
            exit 1
            ;;
    esac
done

# Load config file if provided
if [ "$NON_INTERACTIVE" = true ]; then
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Config file not found: $CONFIG_FILE"
        exit 1
    fi
    source "$CONFIG_FILE"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE} Claude Code Desktop App Template Setup${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

if [ "$NON_INTERACTIVE" = true ]; then
    echo -e "${GREEN}Running in non-interactive mode from: $CONFIG_FILE${NC}"
    echo ""
fi

# Check prerequisites
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Warning: jq not found. GitHub Project auto-detection will be skipped.${NC}"
    echo "Install with: brew install jq"
    HAS_JQ=false
else
    HAS_JQ=true
fi

if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}Warning: GitHub CLI (gh) not found. GitHub Project auto-detection will be skipped.${NC}"
    echo "Install with: brew install gh"
    HAS_GH=false
else
    HAS_GH=true
fi

# Helper: prompt with default value (skips prompt in non-interactive mode)
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    if [ "$NON_INTERACTIVE" = true ]; then
        echo "${default}"
        return
    fi
    local result
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " result
        echo "${result:-$default}"
    else
        read -p "$prompt: " result
        echo "$result"
    fi
}

# ═══════════════════════════════════════════════════════════════
# SECTION 1: Core Project Info
# ═══════════════════════════════════════════════════════════════

echo -e "${GREEN}--- Core Project Info ---${NC}"
PROJECT_NAME="${PROJECT_NAME:-$(prompt_with_default "Project name (human-readable)" "My Project")}"
echo -e "  Project name: ${GREEN}$PROJECT_NAME${NC}"

# Auto-generate slug from name
DEFAULT_SLUG=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
PROJECT_SLUG="${PROJECT_SLUG:-$(prompt_with_default "Project slug (kebab-case)" "$DEFAULT_SLUG")}"
echo -e "  Project slug: ${GREEN}$PROJECT_SLUG${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════
# SECTION 2: GitHub Configuration
# ═══════════════════════════════════════════════════════════════

echo -e "${GREEN}--- GitHub Configuration ---${NC}"
GITHUB_OWNER="${GITHUB_OWNER:-$(prompt_with_default "GitHub owner (username or org)" "")}"
GITHUB_REPO="${GITHUB_REPO:-$(prompt_with_default "GitHub repo name" "$PROJECT_SLUG")}"
echo -e "  GitHub: ${GREEN}$GITHUB_OWNER/$GITHUB_REPO${NC}"

# ─── Create GitHub repo if it doesn't exist ──────────────────
if [ "$HAS_GH" = true ]; then
    REPO_EXISTS=$(gh repo view "$GITHUB_OWNER/$GITHUB_REPO" --json name --jq '.name' 2>/dev/null || echo "")
    if [ -z "$REPO_EXISTS" ]; then
        if [ "$NON_INTERACTIVE" = true ]; then
            CREATE_REPO="${CREATE_REPO:-y}"
        else
            echo ""
            read -p "Repository '$GITHUB_OWNER/$GITHUB_REPO' not found. Create it on GitHub? (y/n): " CREATE_REPO
        fi
        if [ "$CREATE_REPO" = "y" ] || [ "$CREATE_REPO" = "Y" ]; then
            if [ "$NON_INTERACTIVE" != true ]; then
                read -p "Visibility (public/private) [private]: " REPO_VISIBILITY
                REPO_VISIBILITY="${REPO_VISIBILITY:-private}"
            else
                REPO_VISIBILITY="${REPO_VISIBILITY:-private}"
            fi
            gh repo create "$GITHUB_OWNER/$GITHUB_REPO" "--$REPO_VISIBILITY" --description "$PROJECT_NAME" 2>/dev/null \
                && echo -e "  ${GREEN}Created:${NC} github.com/$GITHUB_OWNER/$GITHUB_REPO ($REPO_VISIBILITY)" \
                || echo -e "  ${YELLOW}Could not create repo. Create it manually on github.com before pushing.${NC}"
        fi
    else
        echo -e "  ${GREEN}Repo exists:${NC} github.com/$GITHUB_OWNER/$GITHUB_REPO"
    fi
fi
echo ""

# ═══════════════════════════════════════════════════════════════
# SECTION 3: GitHub Project Board
# ═══════════════════════════════════════════════════════════════

echo -e "${GREEN}--- GitHub Projects V2 Board ---${NC}"
if [ "$NON_INTERACTIVE" != true ]; then
    echo "The issue lifecycle requires a GitHub Projects V2 board with these fields:"
    echo "  - Status (Todo, Dev Started, Automated Tests, Ready for testing, Being tested, Ready for Prod, Done)"
    echo "  - Priority (P1-Critical, P2-High, P3-Medium, P4-Low)"
    echo "  - Story Points (number)"
    echo "  - Sprint (Backlog + sprint iterations)"
    echo "  - Type (Epic, Story, Task)"
    echo ""
fi

if [ "$NON_INTERACTIVE" = true ]; then
    # In non-interactive mode, auto-detect if GITHUB_PROJECT_NUMBER is set
    HAS_PROJECT="${HAS_PROJECT:-n}"
    if [ -n "$GITHUB_PROJECT_NUMBER" ] && [ "$GITHUB_PROJECT_NUMBER" != "REPLACE_ME" ]; then
        HAS_PROJECT="y"
    fi
else
    read -p "Do you have a GitHub Project board set up? (y/n): " HAS_PROJECT
fi

# Initialize all IDs to REPLACE_ME (preserving any values from config file)
GITHUB_PROJECT_NUMBER="${GITHUB_PROJECT_NUMBER:-REPLACE_ME}"
GITHUB_PROJECT_ID="${GITHUB_PROJECT_ID:-REPLACE_ME}"
STATUS_FIELD_ID="${STATUS_FIELD_ID:-REPLACE_ME}"
PRIORITY_FIELD_ID="${PRIORITY_FIELD_ID:-REPLACE_ME}"
SP_FIELD_ID="${SP_FIELD_ID:-REPLACE_ME}"
SPRINT_FIELD_ID="${SPRINT_FIELD_ID:-REPLACE_ME}"
TYPE_FIELD_ID="${TYPE_FIELD_ID:-REPLACE_ME}"
STATUS_TODO="${STATUS_TODO:-REPLACE_ME}"
STATUS_IN_PROGRESS="${STATUS_IN_PROGRESS:-REPLACE_ME}"
STATUS_DEV_STARTED="${STATUS_DEV_STARTED:-REPLACE_ME}"
STATUS_AUTO_TESTS="${STATUS_AUTO_TESTS:-REPLACE_ME}"
STATUS_READY_TEST="${STATUS_READY_TEST:-REPLACE_ME}"
STATUS_BEING_TESTED="${STATUS_BEING_TESTED:-REPLACE_ME}"
STATUS_READY_PROD="${STATUS_READY_PROD:-REPLACE_ME}"
STATUS_DONE="${STATUS_DONE:-REPLACE_ME}"
PRIORITY_P1="${PRIORITY_P1:-REPLACE_ME}"
PRIORITY_P2="${PRIORITY_P2:-REPLACE_ME}"
PRIORITY_P3="${PRIORITY_P3:-REPLACE_ME}"
PRIORITY_P4="${PRIORITY_P4:-REPLACE_ME}"
SPRINT_BACKLOG="${SPRINT_BACKLOG:-REPLACE_ME}"
SPRINT_1="${SPRINT_1:-REPLACE_ME}"
SPRINT_2="${SPRINT_2:-REPLACE_ME}"
SPRINT_3="${SPRINT_3:-REPLACE_ME}"
TYPE_EPIC="${TYPE_EPIC:-REPLACE_ME}"
TYPE_STORY="${TYPE_STORY:-REPLACE_ME}"
TYPE_TASK="${TYPE_TASK:-REPLACE_ME}"

# ─── Helper: fetch all field/option IDs from a project ─────
fetch_project_ids() {
    local PROJECT_ID="$1"
    GITHUB_PROJECT_ID="$PROJECT_ID"

    OPTIONS_JSON=$(gh api graphql -f query="
    query {
      node(id: \"$PROJECT_ID\") {
        ... on ProjectV2 {
          fields(first: 20) {
            nodes {
              ... on ProjectV2SingleSelectField { name id options { name id } }
              ... on ProjectV2Field { name id }
              ... on ProjectV2IterationField { name id }
            }
          }
        }
      }
    }" 2>/dev/null || echo "")

    if [ -n "$OPTIONS_JSON" ]; then
        STATUS_FIELD_ID=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Status") | .id' 2>/dev/null || echo "REPLACE_ME")
        PRIORITY_FIELD_ID=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Priority") | .id' 2>/dev/null || echo "REPLACE_ME")
        SP_FIELD_ID=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Story Points") | .id' 2>/dev/null || echo "REPLACE_ME")
        SPRINT_FIELD_ID=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Sprint") | .id' 2>/dev/null || echo "REPLACE_ME")
        TYPE_FIELD_ID=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Type") | .id' 2>/dev/null || echo "REPLACE_ME")
        echo -e "  ${GREEN}Fields:${NC} Status=$STATUS_FIELD_ID, Priority=$PRIORITY_FIELD_ID, SP=$SP_FIELD_ID"

        STATUS_TODO=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Status") | .options[] | select(.name == "Todo") | .id' 2>/dev/null || echo "REPLACE_ME")
        STATUS_IN_PROGRESS=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Status") | .options[] | select(.name == "In Progress") | .id' 2>/dev/null || echo "REPLACE_ME")
        STATUS_DEV_STARTED=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Status") | .options[] | select(.name == "Dev Started") | .id' 2>/dev/null || echo "REPLACE_ME")
        STATUS_AUTO_TESTS=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Status") | .options[] | select(.name == "Automated Tests") | .id' 2>/dev/null || echo "REPLACE_ME")
        STATUS_READY_TEST=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Status") | .options[] | select(.name == "Ready for testing") | .id' 2>/dev/null || echo "REPLACE_ME")
        STATUS_BEING_TESTED=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Status") | .options[] | select(.name == "Being tested") | .id' 2>/dev/null || echo "REPLACE_ME")
        STATUS_READY_PROD=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Status") | .options[] | select(.name == "Ready for Prod") | .id' 2>/dev/null || echo "REPLACE_ME")
        STATUS_DONE=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Status") | .options[] | select(.name == "Done") | .id' 2>/dev/null || echo "REPLACE_ME")
        echo -e "  ${GREEN}Status options:${NC} Todo=$STATUS_TODO, Done=$STATUS_DONE"

        PRIORITY_P1=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Priority") | .options[] | select(.name | startswith("P1")) | .id' 2>/dev/null || echo "REPLACE_ME")
        PRIORITY_P2=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Priority") | .options[] | select(.name | startswith("P2")) | .id' 2>/dev/null || echo "REPLACE_ME")
        PRIORITY_P3=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Priority") | .options[] | select(.name | startswith("P3")) | .id' 2>/dev/null || echo "REPLACE_ME")
        PRIORITY_P4=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Priority") | .options[] | select(.name | startswith("P4")) | .id' 2>/dev/null || echo "REPLACE_ME")

        SPRINT_BACKLOG=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Sprint") | .options[]? | select(.name == "Backlog") | .id' 2>/dev/null || echo "REPLACE_ME")
        SPRINT_1=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Sprint") | .options[]? | select(.name == "Sprint 1") | .id' 2>/dev/null || echo "REPLACE_ME")
        SPRINT_2=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Sprint") | .options[]? | select(.name == "Sprint 2") | .id' 2>/dev/null || echo "REPLACE_ME")
        SPRINT_3=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Sprint") | .options[]? | select(.name == "Sprint 3") | .id' 2>/dev/null || echo "REPLACE_ME")

        TYPE_EPIC=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Type") | .options[] | select(.name == "Epic") | .id' 2>/dev/null || echo "REPLACE_ME")
        TYPE_STORY=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Type") | .options[] | select(.name == "Story") | .id' 2>/dev/null || echo "REPLACE_ME")
        TYPE_TASK=$(echo "$OPTIONS_JSON" | jq -r '.data.node.fields.nodes[] | select(.name == "Type") | .options[] | select(.name == "Task") | .id' 2>/dev/null || echo "REPLACE_ME")
        echo -e "  ${GREEN}Type options:${NC} Epic=$TYPE_EPIC, Story=$TYPE_STORY, Task=$TYPE_TASK"
    fi
}

# ─── Create or detect project board ────────────────
CREATE_PROJECT="${CREATE_PROJECT:-}"

if [ "$HAS_PROJECT" = "y" ] || [ "$HAS_PROJECT" = "Y" ]; then
    # ── Existing board: auto-detect IDs ──
    GITHUB_PROJECT_NUMBER="${GITHUB_PROJECT_NUMBER:-$(prompt_with_default "Project number (from URL)" "")}"

    if [ "$HAS_GH" = true ] && [ "$HAS_JQ" = true ] && [ "$GITHUB_PROJECT_NUMBER" != "REPLACE_ME" ]; then
        echo ""
        echo "Fetching project IDs automatically..."

        PROJECT_ID=$(gh api graphql -f query="
        query {
          user(login: \"$GITHUB_OWNER\") {
            projectV2(number: $GITHUB_PROJECT_NUMBER) { id }
          }
        }" --jq '.data.user.projectV2.id' 2>/dev/null || echo "")

        if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "null" ]; then
            PROJECT_ID=$(gh api graphql -f query="
            query {
              organization(login: \"$GITHUB_OWNER\") {
                projectV2(number: $GITHUB_PROJECT_NUMBER) { id }
              }
            }" --jq '.data.organization.projectV2.id' 2>/dev/null || echo "")
        fi

        if [ -n "$PROJECT_ID" ] && [ "$PROJECT_ID" != "null" ]; then
            echo -e "  ${GREEN}Found project ID:${NC} $PROJECT_ID"
            fetch_project_ids "$PROJECT_ID"
        else
            echo -e "  ${YELLOW}Could not auto-detect project ID. IDs will be set to REPLACE_ME.${NC}"
        fi
    else
        echo -e "${YELLOW}Auto-detection skipped (missing gh or jq). IDs will be set to REPLACE_ME.${NC}"
    fi
else
    # ── No board: offer to create one ──
    if [ "$HAS_GH" = true ] && [ "$HAS_JQ" = true ]; then
        if [ "$NON_INTERACTIVE" = true ]; then
            CREATE_PROJECT="${CREATE_PROJECT:-y}"
        else
            echo ""
            read -p "Create a GitHub Project board with all required fields now? (y/n): " CREATE_PROJECT
        fi

        if [ "$CREATE_PROJECT" = "y" ] || [ "$CREATE_PROJECT" = "Y" ]; then
            echo ""
            echo "Creating GitHub Project board..."

            # Create the project
            GITHUB_PROJECT_NUMBER=$(gh project create --owner "$GITHUB_OWNER" --title "$PROJECT_NAME" --format json 2>/dev/null | jq -r '.number')
            if [ -z "$GITHUB_PROJECT_NUMBER" ] || [ "$GITHUB_PROJECT_NUMBER" = "null" ]; then
                echo -e "  ${RED}Failed to create project. IDs will be set to REPLACE_ME.${NC}"
            else
                echo -e "  ${GREEN}Created project #$GITHUB_PROJECT_NUMBER${NC}"

                # Get project ID
                PROJECT_ID=$(gh api graphql -f query="
                query {
                  user(login: \"$GITHUB_OWNER\") {
                    projectV2(number: $GITHUB_PROJECT_NUMBER) { id }
                  }
                }" --jq '.data.user.projectV2.id' 2>/dev/null || echo "")

                if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "null" ]; then
                    PROJECT_ID=$(gh api graphql -f query="
                    query {
                      organization(login: \"$GITHUB_OWNER\") {
                        projectV2(number: $GITHUB_PROJECT_NUMBER) { id }
                      }
                    }" --jq '.data.organization.projectV2.id' 2>/dev/null || echo "")
                fi

                if [ -n "$PROJECT_ID" ] && [ "$PROJECT_ID" != "null" ]; then
                    echo -e "  ${GREEN}Project ID:${NC} $PROJECT_ID"

                    # Get Status field ID (built-in, already exists)
                    STATUS_FIELD_ID=$(gh api graphql -f query="
                    query {
                      node(id: \"$PROJECT_ID\") {
                        ... on ProjectV2 {
                          fields(first: 20) {
                            nodes {
                              ... on ProjectV2SingleSelectField { name id }
                            }
                          }
                        }
                      }
                    }" --jq '.data.node.fields.nodes[] | select(.name == "Status") | .id' 2>/dev/null || echo "")

                    # Update Status field with all required options
                    if [ -n "$STATUS_FIELD_ID" ]; then
                        echo -e "  Adding Status options..."
                        gh api graphql -f query="mutation {
                          updateProjectV2Field(input: {
                            fieldId: \"$STATUS_FIELD_ID\"
                            singleSelectOptions: [
                              {name: \"Todo\", description: \"Issue created\", color: GRAY}
                              {name: \"Dev Started\", description: \"Development in progress\", color: YELLOW}
                              {name: \"Automated Tests\", description: \"Running automated test suites\", color: PINK}
                              {name: \"Ready for testing\", description: \"Dev complete, awaiting testing\", color: ORANGE}
                              {name: \"Being tested\", description: \"User actively testing\", color: BLUE}
                              {name: \"Ready for Prod\", description: \"Approved, ready to deploy\", color: GREEN}
                              {name: \"Done\", description: \"Deployed or closed\", color: PURPLE}
                            ]
                          }) { clientMutationId }
                        }" > /dev/null 2>&1
                        echo -e "  ${GREEN}Status:${NC} Todo, Dev Started, Automated Tests, Ready for testing, Being tested, Ready for Prod, Done"
                    fi

                    # Create Priority field
                    echo -e "  Adding Priority field..."
                    gh api graphql -f query="mutation {
                      createProjectV2Field(input: {
                        projectId: \"$PROJECT_ID\"
                        dataType: SINGLE_SELECT
                        name: \"Priority\"
                        singleSelectOptions: [
                          {name: \"P1 - Critical\", description: \"Blocking issues, security vulnerabilities\", color: RED}
                          {name: \"P2 - High\", description: \"Important features, significant bugs\", color: ORANGE}
                          {name: \"P3 - Medium\", description: \"Enhancements, minor bugs\", color: YELLOW}
                          {name: \"P4 - Low\", description: \"Polish, tech debt\", color: BLUE}
                        ]
                      }) { clientMutationId }
                    }" > /dev/null 2>&1
                    echo -e "  ${GREEN}Priority:${NC} P1-Critical, P2-High, P3-Medium, P4-Low"

                    # Create Story Points field
                    echo -e "  Adding Story Points field..."
                    gh api graphql -f query="mutation {
                      createProjectV2Field(input: {
                        projectId: \"$PROJECT_ID\"
                        dataType: NUMBER
                        name: \"Story Points\"
                      }) { clientMutationId }
                    }" > /dev/null 2>&1
                    echo -e "  ${GREEN}Story Points:${NC} number field"

                    # Create Type field
                    echo -e "  Adding Type field..."
                    gh api graphql -f query="mutation {
                      createProjectV2Field(input: {
                        projectId: \"$PROJECT_ID\"
                        dataType: SINGLE_SELECT
                        name: \"Type\"
                        singleSelectOptions: [
                          {name: \"Epic\", description: \"Large body of work, 13+ SP\", color: PURPLE}
                          {name: \"Story\", description: \"User-facing feature, 3-8 SP\", color: GREEN}
                          {name: \"Task\", description: \"Technical work, 1-3 SP\", color: BLUE}
                        ]
                      }) { clientMutationId }
                    }" > /dev/null 2>&1
                    echo -e "  ${GREEN}Type:${NC} Epic, Story, Task"

                    # Create Sprint field (using GraphQL — gh project field-create is unreliable)
                    echo -e "  Adding Sprint field..."
                    gh api graphql -f query="mutation {
                      createProjectV2Field(input: {
                        projectId: \"$PROJECT_ID\"
                        dataType: SINGLE_SELECT
                        name: \"Sprint\"
                        singleSelectOptions: [
                          {name: \"Backlog\", description: \"Not yet scheduled\", color: GRAY}
                          {name: \"Sprint 1\", description: \"First sprint\", color: BLUE}
                          {name: \"Sprint 2\", description: \"Second sprint\", color: GREEN}
                          {name: \"Sprint 3\", description: \"Third sprint\", color: ORANGE}
                        ]
                      }) { clientMutationId }
                    }" > /dev/null 2>&1
                    echo -e "  ${GREEN}Sprint:${NC} Backlog, Sprint 1-3"

                    # Link project to repo
                    echo -e "  Linking to repository..."
                    gh project link "$GITHUB_PROJECT_NUMBER" --owner "$GITHUB_OWNER" --repo "$GITHUB_OWNER/$GITHUB_REPO" 2>/dev/null || true
                    echo -e "  ${GREEN}Linked to${NC} $GITHUB_OWNER/$GITHUB_REPO"

                    # Create labels on repo
                    echo -e "  Creating labels..."
                    gh label create epic --repo "$GITHUB_OWNER/$GITHUB_REPO" --color 6f42c1 --description "13+ SP work items" 2>/dev/null || true
                    gh label create story --repo "$GITHUB_OWNER/$GITHUB_REPO" --color 0e8a16 --description "3-8 SP user-facing features" 2>/dev/null || true
                    gh label create task --repo "$GITHUB_OWNER/$GITHUB_REPO" --color 0075ca --description "1-3 SP technical work" 2>/dev/null || true
                    gh label create bug --repo "$GITHUB_OWNER/$GITHUB_REPO" --color d73a4a --description "Bugs and fixes" --force 2>/dev/null || true
                    echo -e "  ${GREEN}Labels:${NC} epic, story, task, bug"

                    # Now fetch all IDs
                    echo ""
                    echo "Fetching generated IDs..."
                    fetch_project_ids "$PROJECT_ID"
                fi
            fi
        fi
    else
        echo -e "${YELLOW}Skipping board creation (missing gh or jq). IDs will be set to REPLACE_ME.${NC}"
    fi
fi

GITHUB_PROJECT_URL="https://github.com/users/$GITHUB_OWNER/projects/$GITHUB_PROJECT_NUMBER"
echo ""

# ═══════════════════════════════════════════════════════════════
# SECTION 4: Documentation Target & Notion Integration
# ═══════════════════════════════════════════════════════════════

echo -e "${GREEN}--- Documentation Target ---${NC}"
if [ "$NON_INTERACTIVE" != true ]; then
    echo "Where should project documentation be generated during Phase 7 (Documentation & Delivery)?"
    echo "  1) local  — Markdown files in the repo (README.md, docs/developer-guide.md)"
    echo "  2) notion — Notion database (requires Notion MCP integration)"
    echo "  3) both   — Both local markdown AND Notion"
    echo ""
    read -p "Documentation target (1/2/3) [1]: " DOC_CHOICE
    case "$DOC_CHOICE" in
        2) DOC_TARGET="notion" ;;
        3) DOC_TARGET="both" ;;
        *) DOC_TARGET="local" ;;
    esac
else
    DOC_TARGET="${DOC_TARGET:-local}"
fi
echo -e "  Documentation target: ${GREEN}$DOC_TARGET${NC}"
echo ""

# Auto-derive USE_NOTION from DOC_TARGET
if [ "$DOC_TARGET" = "notion" ] || [ "$DOC_TARGET" = "both" ]; then
    USE_NOTION="y"
else
    USE_NOTION="n"
fi

NOTION_DATABASE_ID="${NOTION_DATABASE_ID:-NOT_CONFIGURED}"
if [ "$USE_NOTION" = "y" ]; then
    echo -e "${GREEN}--- Notion Integration ---${NC}"
    if [ "$NOTION_DATABASE_ID" = "NOT_CONFIGURED" ]; then
        if [ "$NON_INTERACTIVE" = true ]; then
            # No ID provided in config — defer to /setup-notion
            NOTION_DATABASE_ID="SETUP_PENDING"
        else
            echo ""
            echo "Do you already have a Notion Documentation database?"
            echo "  1) Yes — I have the data source ID"
            echo "  2) No — Claude will create one for me (run /setup-notion after setup)"
            read -p "Choice (1/2): " NOTION_CHOICE

            if [ "$NOTION_CHOICE" = "1" ]; then
                NOTION_DATABASE_ID=$(prompt_with_default "Notion Documentation data source ID" "")
            else
                NOTION_DATABASE_ID="SETUP_PENDING"
                echo -e "${YELLOW}Notion database will be created after setup. Run /setup-notion in Claude Code.${NC}"
            fi
        fi
    fi
    echo -e "  Notion: ${GREEN}Enabled${NC} (ID: $NOTION_DATABASE_ID)"
    echo ""
fi

# ═══════════════════════════════════════════════════════════════
# SECTION 5: Tech Stack
# ═══════════════════════════════════════════════════════════════

echo -e "${GREEN}--- Tech Stack & Commands ---${NC}"
if [ "$NON_INTERACTIVE" != true ]; then
    echo "Enter commands for your desktop application's test, dev, build and package setup."
    echo "Leave blank to use the placeholder 'REPLACE_ME' (configure later)."
    echo ""
fi

TEST_COMMAND_CORE="${TEST_COMMAND_CORE:-$(prompt_with_default "Core/main process test command" "REPLACE_ME")}"
TEST_COMMAND_UI="${TEST_COMMAND_UI:-$(prompt_with_default "UI layer test/check command" "REPLACE_ME")}"
E2E_TEST_COMMAND="${E2E_TEST_COMMAND:-$(prompt_with_default "Desktop E2E test command" "REPLACE_ME")}"
DEV_APP_COMMAND="${DEV_APP_COMMAND:-$(prompt_with_default "App dev mode launch command (e.g. npm run dev, cargo tauri dev)" "REPLACE_ME")}"
BUILD_COMMAND="${BUILD_COMMAND:-$(prompt_with_default "App build command (compile/bundle)" "REPLACE_ME")}"
PACKAGE_COMMAND="${PACKAGE_COMMAND:-$(prompt_with_default "App package command (create installer)" "REPLACE_ME")}"
UI_DIR="${UI_DIR:-$(prompt_with_default "UI directory name" "ui")}"
echo ""

LOCAL_URL="${LOCAL_URL:-REPLACE_ME}"
PROD_URL="${PROD_URL:-REPLACE_ME}"
DEV_PORT_BACKEND="UNUSED"
DEV_PORT_FRONTEND="UNUSED"
DEV_SERVER_BACKEND="UNUSED"
DEV_SERVER_FRONTEND="UNUSED"
FRONTEND_DIR="${UI_DIR}"
echo ""

# ═══════════════════════════════════════════════════════════════
# SECTION 5b: Agent Teams (Build Pipeline)
# ═══════════════════════════════════════════════════════════════

echo -e "${GREEN}--- Agent Teams (Build Pipeline) ---${NC}"
if [ "$NON_INTERACTIVE" != true ]; then
    echo "Agent Teams enables parallel implementation in Phase 4 (core + UI + integration"
    echo "agents work simultaneously). Requires CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1."
    echo ""
fi

if [ "$NON_INTERACTIVE" = true ]; then
    USE_AGENT_TEAMS="${USE_AGENT_TEAMS:-y}"
else
    read -p "Enable Agent Teams for parallel implementation? (y/n) [y]: " USE_AGENT_TEAMS
    USE_AGENT_TEAMS="${USE_AGENT_TEAMS:-y}"
fi
echo -e "  Agent Teams: ${GREEN}$USE_AGENT_TEAMS${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════
# SECTION 6: Release & Distribution
# ═══════════════════════════════════════════════════════════════

echo -e "${GREEN}--- Release & Distribution ---${NC}"
DEPLOY_COMMAND="${DEPLOY_COMMAND:-$(prompt_with_default "Release/publish command (or 'none')" "REPLACE_ME")}"
HEALTH_CHECK_COMMAND="${HEALTH_CHECK_COMMAND:-none}"
DOCKER_CHECK_COMMAND="${DOCKER_CHECK_COMMAND:-none}"
echo ""

# ═══════════════════════════════════════════════════════════════
# SECTION 7: Data Protection
# ═══════════════════════════════════════════════════════════════

echo -e "${GREEN}--- Data Protection ---${NC}"
if [ "$NON_INTERACTIVE" != true ]; then
    echo "The safety hooks protect a data directory from destructive git operations."
    echo ""
fi
PROTECTED_DATA_DIR="${PROTECTED_DATA_DIR:-$(prompt_with_default "Protected data directory" "data/")}"
PROTECTED_DATA_PATTERNS="${PROTECTED_DATA_PATTERNS:-$(prompt_with_default "Protected data grep pattern (for git hooks)" "$PROTECTED_DATA_DIR")}"
echo ""

# ═══════════════════════════════════════════════════════════════
# APPLY CONFIGURATION
# ═══════════════════════════════════════════════════════════════

echo -e "${BLUE}Applying configuration...${NC}"
echo ""

# Rename .template files
for tpl in "$SCRIPT_DIR/CLAUDE.md.template" \
           "$SCRIPT_DIR/.claude/settings.json.template" \
           "$SCRIPT_DIR/.claude/settings.local.json.template" \
           "$SCRIPT_DIR/.gitignore.template" \
           "$SCRIPT_DIR/.github/workflows/desktop-e2e.yml.template" \
           "$SCRIPT_DIR/docs/product-brief.md.template" \
           "$SCRIPT_DIR/docs/build-state.json.template" \
           "$SCRIPT_DIR/start-app.sh.template"; do
    if [ -f "$tpl" ]; then
        mv "$tpl" "${tpl%.template}"
    fi
done

# Find all files to process
FILES=$(find "$SCRIPT_DIR" -type f \
    \( -name "*.md" -o -name "*.sh" -o -name "*.json" -o -name "*.ts" -o -name "*.yml" -o -name ".gitignore" \) \
    ! -path "*/.git/*" \
    ! -path "*/node_modules/*" \
    ! -name "setup.sh" \
    ! -name ".gitkeep")

# Apply sed replacements (using | as delimiter to avoid URL conflicts)
for file in $FILES; do
    sed_inplace \
        -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
        -e "s|{{PROJECT_SLUG}}|$PROJECT_SLUG|g" \
        -e "s|{{GITHUB_OWNER}}|$GITHUB_OWNER|g" \
        -e "s|{{GITHUB_REPO}}|$GITHUB_REPO|g" \
        -e "s|{{GITHUB_PROJECT_NUMBER}}|$GITHUB_PROJECT_NUMBER|g" \
        -e "s|{{GITHUB_PROJECT_ID}}|$GITHUB_PROJECT_ID|g" \
        -e "s|{{GITHUB_PROJECT_URL}}|$GITHUB_PROJECT_URL|g" \
        -e "s|{{STATUS_FIELD_ID}}|$STATUS_FIELD_ID|g" \
        -e "s|{{PRIORITY_FIELD_ID}}|$PRIORITY_FIELD_ID|g" \
        -e "s|{{SP_FIELD_ID}}|$SP_FIELD_ID|g" \
        -e "s|{{SPRINT_FIELD_ID}}|$SPRINT_FIELD_ID|g" \
        -e "s|{{TYPE_FIELD_ID}}|$TYPE_FIELD_ID|g" \
        -e "s|{{STATUS_TODO}}|$STATUS_TODO|g" \
        -e "s|{{STATUS_IN_PROGRESS}}|$STATUS_IN_PROGRESS|g" \
        -e "s|{{STATUS_DEV_STARTED}}|$STATUS_DEV_STARTED|g" \
        -e "s|{{STATUS_AUTO_TESTS}}|$STATUS_AUTO_TESTS|g" \
        -e "s|{{STATUS_READY_TEST}}|$STATUS_READY_TEST|g" \
        -e "s|{{STATUS_BEING_TESTED}}|$STATUS_BEING_TESTED|g" \
        -e "s|{{STATUS_READY_PROD}}|$STATUS_READY_PROD|g" \
        -e "s|{{STATUS_DONE}}|$STATUS_DONE|g" \
        -e "s|{{PRIORITY_P1}}|$PRIORITY_P1|g" \
        -e "s|{{PRIORITY_P2}}|$PRIORITY_P2|g" \
        -e "s|{{PRIORITY_P3}}|$PRIORITY_P3|g" \
        -e "s|{{PRIORITY_P4}}|$PRIORITY_P4|g" \
        -e "s|{{SPRINT_BACKLOG}}|$SPRINT_BACKLOG|g" \
        -e "s|{{SPRINT_1}}|$SPRINT_1|g" \
        -e "s|{{SPRINT_2}}|$SPRINT_2|g" \
        -e "s|{{SPRINT_3}}|$SPRINT_3|g" \
        -e "s|{{TYPE_EPIC}}|$TYPE_EPIC|g" \
        -e "s|{{TYPE_STORY}}|$TYPE_STORY|g" \
        -e "s|{{TYPE_TASK}}|$TYPE_TASK|g" \
        -e "s|{{NOTION_DATABASE_ID}}|$NOTION_DATABASE_ID|g" \
        -e "s|{{PROTECTED_DATA_DIR}}|$PROTECTED_DATA_DIR|g" \
        -e "s|{{PROTECTED_DATA_PATTERNS}}|$PROTECTED_DATA_PATTERNS|g" \
        -e "s|{{TEST_COMMAND_CORE}}|$TEST_COMMAND_CORE|g" \
        -e "s|{{TEST_COMMAND_UI}}|$TEST_COMMAND_UI|g" \
        -e "s|{{TEST_COMMAND_BACKEND}}|$TEST_COMMAND_CORE|g" \
        -e "s|{{TEST_COMMAND_FRONTEND}}|$TEST_COMMAND_UI|g" \
        -e "s|{{E2E_TEST_COMMAND}}|$E2E_TEST_COMMAND|g" \
        -e "s|{{DEV_APP_COMMAND}}|$DEV_APP_COMMAND|g" \
        -e "s|{{BUILD_COMMAND}}|$BUILD_COMMAND|g" \
        -e "s|{{PACKAGE_COMMAND}}|$PACKAGE_COMMAND|g" \
        -e "s|{{DEV_SERVER_BACKEND}}|$DEV_APP_COMMAND|g" \
        -e "s|{{DEV_SERVER_FRONTEND}}||g" \
        -e "s|{{DEV_PORT_BACKEND}}|UNUSED|g" \
        -e "s|{{DEV_PORT_FRONTEND}}|UNUSED|g" \
        -e "s|{{LOCAL_URL}}|$LOCAL_URL|g" \
        -e "s|{{PROD_URL}}|$PROD_URL|g" \
        -e "s|{{HEALTH_CHECK_COMMAND}}|$HEALTH_CHECK_COMMAND|g" \
        -e "s|{{DEPLOY_COMMAND}}|$DEPLOY_COMMAND|g" \
        -e "s|{{DOCKER_CHECK_COMMAND}}|$DOCKER_CHECK_COMMAND|g" \
        -e "s|{{FRONTEND_DIR}}|$UI_DIR|g" \
        -e "s|{{UI_DIR}}|$UI_DIR|g" \
        -e "s|{{DOC_TARGET}}|$DOC_TARGET|g" \
        -e "s|{{DATE}}|$(date +%Y-%m-%d)|g" \
        "$file"
done

# ─── Remove doc target sections based on DOC_TARGET ──────────
if [ "$DOC_TARGET" = "notion" ]; then
    # Notion only: remove local-only doc sections, keep Notion sections
    echo "Removing local-only documentation sections..."
    for file in $FILES; do
        sed_inplace '/<!-- LOCAL_DOCS_START -->/,/<!-- LOCAL_DOCS_END -->/d' "$file"
    done
    # Clean up Notion markers (keep content)
    for file in $FILES; do
        sed_inplace '/<!-- NOTION_START -->/d; /<!-- NOTION_END -->/d' "$file"
    done
elif [ "$DOC_TARGET" = "local" ]; then
    # Local only: remove Notion sections, keep local sections
    echo "Removing Notion integration sections..."
    for file in $FILES; do
        sed_inplace '/<!-- NOTION_START -->/,/<!-- NOTION_END -->/d' "$file"
    done
    # Clean up local doc markers (keep content)
    for file in $FILES; do
        sed_inplace '/<!-- LOCAL_DOCS_START -->/d; /<!-- LOCAL_DOCS_END -->/d' "$file"
    done
elif [ "$DOC_TARGET" = "both" ]; then
    # Both: keep all content, just remove markers
    echo "Keeping both local and Notion documentation sections..."
    for file in $FILES; do
        sed_inplace '/<!-- NOTION_START -->/d; /<!-- NOTION_END -->/d' "$file"
        sed_inplace '/<!-- LOCAL_DOCS_START -->/d; /<!-- LOCAL_DOCS_END -->/d' "$file"
    done
fi

# ─── Remove Agent Teams Sections (based on config) ───────────
if [ "$USE_AGENT_TEAMS" = "y" ] || [ "$USE_AGENT_TEAMS" = "Y" ]; then
    echo "Removing non-Agent-Teams sections..."
    for file in $FILES; do
        sed_inplace '/<!-- NO_AGENT_TEAMS_START -->/,/<!-- NO_AGENT_TEAMS_END -->/d' "$file"
    done
    # Clean up remaining Agent Teams markers (keep content)
    for file in $FILES; do
        sed_inplace '/<!-- AGENT_TEAMS_START -->/d; /<!-- AGENT_TEAMS_END -->/d' "$file"
    done
else
    echo "Removing Agent Teams sections..."
    for file in $FILES; do
        sed_inplace '/<!-- AGENT_TEAMS_START -->/,/<!-- AGENT_TEAMS_END -->/d' "$file"
    done
    # Clean up remaining non-Agent-Teams markers (keep content)
    for file in $FILES; do
        sed_inplace '/<!-- NO_AGENT_TEAMS_START -->/d; /<!-- NO_AGENT_TEAMS_END -->/d' "$file"
    done
fi

# ─── Inject Agent Teams env var into settings.json ────────────
if [ "$USE_AGENT_TEAMS" = "y" ] || [ "$USE_AGENT_TEAMS" = "Y" ]; then
    SETTINGS_FILE="$SCRIPT_DIR/.claude/settings.json"
    if [ -f "$SETTINGS_FILE" ] && [ "$HAS_JQ" = true ]; then
        echo "Adding Agent Teams env var to settings.json..."
        jq '.env = (.env // {}) + {"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"}' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    fi
fi

# ─── Handle "none" deployment commands ──────────────────────
if [ "$DOCKER_CHECK_COMMAND" = "none" ]; then
    for file in $FILES; do
        # Remove lines containing the docker check placeholder
        sed_inplace '/docker.*check\|DOCKER_CHECK/Id' "$file" 2>/dev/null || true
    done
fi

# ─── Make scripts executable ─────────────────────────────────
chmod +x "$SCRIPT_DIR/.claude/hooks/"*.sh
[ -f "$SCRIPT_DIR/start-app.sh" ] && chmod +x "$SCRIPT_DIR/start-app.sh"

# ═══════════════════════════════════════════════════════════════
# VERIFICATION
# ═══════════════════════════════════════════════════════════════

echo ""
echo -e "${BLUE}Running verification checks...${NC}"

ERRORS=0

# Check for leftover template placeholders (not REPLACE_ME which is intentional)
LEFTOVER=$(grep -r '{{[A-Z_]*}}' "$SCRIPT_DIR" --include='*.md' --include='*.sh' --include='*.json' --include='*.ts' --include='*.yml' -l 2>/dev/null | grep -v setup.sh || true)
if [ -n "$LEFTOVER" ]; then
    echo -e "${RED}ERROR: Unresolved {{PLACEHOLDER}} values in:${NC}"
    echo "$LEFTOVER"
    ERRORS=$((ERRORS + 1))
fi

# Check hooks are executable
for hook in "$SCRIPT_DIR/.claude/hooks/"*.sh; do
    if [ ! -x "$hook" ]; then
        echo -e "${RED}ERROR: $hook is not executable${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check JSON validity
if [ "$HAS_JQ" = true ]; then
    for json in "$SCRIPT_DIR/.claude/settings.json" "$SCRIPT_DIR/.claude/settings.local.json"; do
        if [ -f "$json" ]; then
            if ! jq . "$json" > /dev/null 2>&1; then
                echo -e "${RED}ERROR: $json is invalid JSON${NC}"
                ERRORS=$((ERRORS + 1))
            fi
        fi
    done
fi

# Check skill frontmatter
for skill in "$SCRIPT_DIR/.claude/skills/"*/SKILL.md; do
    if [ -f "$skill" ]; then
        if ! head -1 "$skill" | grep -q "^---$"; then
            echo -e "${RED}ERROR: $skill missing YAML frontmatter${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

# Check required directories
for dir in docs/claude/issues docs/claude/context docs/claude/operations docs/claude/diagrams docs/architecture/ADR docs/database docs/design/screen-specs docs/qa docs/security docs/devops; do
    if [ ! -d "$SCRIPT_DIR/$dir" ]; then
        echo -e "${RED}ERROR: Missing directory: $dir${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done

if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}All checks passed.${NC}"
else
    echo -e "${YELLOW}$ERRORS issue(s) found. Review and fix before using.${NC}"
fi

# ═══════════════════════════════════════════════════════════════
# CLEANUP & GIT INIT
# ═══════════════════════════════════════════════════════════════

echo ""

# Remove setup.sh itself
rm "$SCRIPT_DIR/setup.sh"

# Initialize git if not already a repo
if [ ! -d "$SCRIPT_DIR/.git" ]; then
    INIT_GIT="${INIT_GIT:-}"
    if [ "$NON_INTERACTIVE" = true ]; then
        INIT_GIT="${INIT_GIT:-y}"
    else
        read -p "Initialize git repository? (y/n): " INIT_GIT
    fi
    if [ "$INIT_GIT" = "y" ] || [ "$INIT_GIT" = "Y" ]; then
        cd "$SCRIPT_DIR"
        git init
        git add -A
        git commit -m "chore: initialize project from claude-code-agents-orchestration-template

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
        echo -e "${GREEN}Git repository initialized with initial commit.${NC}"
    fi
fi

# ═══════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE} Setup Complete!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "  Project:  ${GREEN}$PROJECT_NAME${NC}"
echo -e "  GitHub:   ${GREEN}$GITHUB_OWNER/$GITHUB_REPO${NC}"
echo -e "  Board:    ${GREEN}$GITHUB_PROJECT_URL${NC}"
if [ "$USE_AGENT_TEAMS" = "y" ] || [ "$USE_AGENT_TEAMS" = "Y" ]; then
    echo -e "  Agent Teams: ${GREEN}Enabled${NC}"
else
    echo -e "  Agent Teams: ${YELLOW}Disabled (sequential Phase 4)${NC}"
fi
echo -e "  Docs:     ${GREEN}$DOC_TARGET${NC}"
if [ "$NOTION_DATABASE_ID" = "SETUP_PENDING" ]; then
    echo -e "  Notion:   ${YELLOW}Enabled (pending — run /setup-notion)${NC}"
elif [ "$USE_NOTION" = "y" ]; then
    echo -e "  Notion:   ${GREEN}Enabled ($NOTION_DATABASE_ID)${NC}"
fi
echo ""

# Check for REPLACE_ME values
REPLACE_COUNT=$(grep -rl "REPLACE_ME" "$SCRIPT_DIR" --include="*.md" --include="*.json" --include="*.sh" 2>/dev/null | wc -l | tr -d ' ')
if [ "$REPLACE_COUNT" -gt "0" ]; then
    echo -e "${YELLOW}NOTE: $REPLACE_COUNT file(s) still contain REPLACE_ME placeholders.${NC}"
    echo "These need manual configuration. Find them with:"
    echo "  grep -rl 'REPLACE_ME' . --include='*.md' --include='*.json' --include='*.sh'"
fi

STEP=1
echo ""
echo "Next steps:"
if [ "$NOTION_DATABASE_ID" = "SETUP_PENDING" ]; then
    echo "  $STEP. Run /setup-notion in Claude Code to create the Notion database"
    STEP=$((STEP + 1))
fi
echo "  $STEP. Review CLAUDE.md and customize rules for your project"
STEP=$((STEP + 1))
echo "  $STEP. Fill in docs/product-brief.md with your product description"
STEP=$((STEP + 1))
echo "  $STEP. Run /build-phase 1 to start the build pipeline"
STEP=$((STEP + 1))
echo "  $STEP. Update GITHUB_CONFIG.md if project board IDs are missing"
STEP=$((STEP + 1))
echo "  $STEP. After build completes, use /create-issue for ongoing desktop development"
echo ""
