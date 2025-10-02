#!/bin/bash

# ==============================================================================
# new-project.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Creates a new project directory structure in both the main
#              02.engagements-projects/ folder and the 04.vault/ structure.
#              The structure differentiates between compiled/raw files (Main)
#              and minimal organization (Vault).
#
# USAGE: smarty new-project <project-name>
#
# EXAMPLE: smarty new-project "Startup-Incubator-2026"
# ==============================================================================

# --- Configuration ---
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: The SMARTY_ROOT environment variable is not set. Did you restart your terminal after running init.sh?" >&2
    exit 1
fi

BASE_PROJECTS_DIR="$SMARTY_ROOT/02.engagements-projects"
VAULT_PROJECTS_DIR="$SMARTY_ROOT/04.vault/02.engagements-projects"

# --- Functions ---

# Function to display error messages and exit
error_exit() {
    echo -e "\nERROR: $1" >&2
    echo "Usage: smarty new-project <project-name>" >&2
    exit 1
}

# Function to create the core project structure
# $1: base_dir, $2: project_name, $3: structure_type ('main' or 'vault')
create_project_structure() {
    local base_dir="$1"
    local project_name="$2"
    local structure_type="$3"

    PROJECT_PATH="$base_dir/$project_name"
    local core_dirs=()

    # Define directory lists based on type
    if [ "$structure_type" == "main" ]; then
        # Main directory structure: raw source files (code, data) and final submissions
        local core_dirs=(
            "raw"
            "notes"
        )
    elif [ "$structure_type" == "vault" ]; then
        # Vault structure: A place to compile *from* and final submission mirror
        local core_dirs=(
            "notes"
        )
    fi

    echo "Creating $structure_type structure in $PROJECT_PATH..."
    for dir in "${core_dirs[@]}"; do
        mkdir -p "$PROJECT_PATH/$dir" || error_exit "Failed to create directory $PROJECT_PATH/$dir."
    done
}

# --- Main Execution ---

# 1. Validate and Parse Input (Only one argument expected)
PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
    error_exit "Missing project name."
fi
if [ ! -z "$2" ]; then
    error_exit "Unrecognized argument or flag: $2. The new-project script does not support flags."
fi

# Sanitize project name
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr ' ' '-')

# Check if the project directory already exists
if [ -d "$BASE_PROJECTS_DIR/$PROJECT_NAME" ]; then
    error_exit "Project directory '$PROJECT_NAME' already exists in $BASE_PROJECTS_DIR."
fi


# 2. Create Directory Structures

echo "Starting Smarty Vault project creation for: $PROJECT_NAME"

# A. Create structure in the main compiled/reference directory (02.engagements-projects/)
echo "---"
create_project_structure "$BASE_PROJECTS_DIR" "$PROJECT_NAME" "main"
echo "Main project structure created successfully."

# B. Create structure in the raw Obsidian vault directory (04.vault/02.engagements-projects/)
echo "---"
# Ensure the parent vault project dir exists first
mkdir -p "$VAULT_PROJECTS_DIR" || error_exit "Failed to create parent vault directory $VAULT_PROJECTS_DIR."

create_project_structure "$VAULT_PROJECTS_DIR" "$PROJECT_NAME" "vault"
echo "Obsidian vault structure created successfully."

# 3. Success Message (Updated to reflect new structure)
echo "---"
echo "✅ SUCCESS: New project '$PROJECT_NAME' is ready!"
echo "   - Main project directory: $BASE_PROJECTS_DIR/$PROJECT_NAME/"
echo "   - Raw Obsidian notes go into: $VAULT_PROJECTS_DIR/$PROJECT_NAME/ (Manually create notes here)"
echo "---"

exit 0
