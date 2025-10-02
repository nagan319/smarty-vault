#!/bin/bash

# ==============================================================================
# remove-project.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Permanently deletes a project and its entire structure from both 
#              the main directory (02.engagements-projects/) and the Obsidian 
#              vault (04.vault/02.engagements-projects/). Requires confirmation.
#
# USAGE: smarty remove-project <project-name>
#
# EXAMPLE: smarty remove-project "Startup-Incubator-2026"
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
    echo "Usage: smarty remove-project <project-name>" >&2
    exit 1
}

# --- Main Execution ---

# 1. Validate Input
PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
    error_exit "Missing project name."
fi
if [ ! -z "$2" ]; then
    error_exit "Unrecognized argument or flag: $2. The remove-project script does not support flags."
fi

# Sanitize project name
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr ' ' '-')

PROJECT_PATH_MAIN="$BASE_PROJECTS_DIR/$PROJECT_NAME"
PROJECT_PATH_VAULT="$VAULT_PROJECTS_DIR/$PROJECT_NAME"

# Check if the project directory exists at all
if [ ! -d "$PROJECT_PATH_MAIN" ] && [ ! -d "$PROJECT_PATH_VAULT" ]; then
    error_exit "Project directory '$PROJECT_NAME' not found in either the main or vault locations. Nothing to remove."
fi

# 2. Confirmation Prompt (CRITICAL)
echo -e "\n\033[1;33m⚠️ WARNING: DANGER ZONE ⚠️\033[0m"
echo "You are about to PERMANENTLY DELETE the project '$PROJECT_NAME' and ALL its contents from:"
echo "1. Main Compiled/Raw Folder: $PROJECT_PATH_MAIN"
echo "2. Obsidian Vault Folder: $PROJECT_PATH_VAULT"
echo -e "\nType 'YES' to confirm permanent deletion:"

read -r CONFIRMATION

if [ "$CONFIRMATION" != "YES" ]; then
    echo -e "\nAborting operation. Project '$PROJECT_NAME' was NOT deleted."
    exit 0
fi

# 3. Deletion Logic
echo -e "\nConfirmed. Deleting project contents..."

# Delete from Main Compiled/Raw Folder (02.engagements-projects/)
if [ -d "$PROJECT_PATH_MAIN" ]; then
    rm -rf "$PROJECT_PATH_MAIN"
    if [ $? -eq 0 ]; then
        echo "✅ Successfully removed: $PROJECT_PATH_MAIN"
    else
        echo "❌ Failed to remove: $PROJECT_PATH_MAIN" >&2
    fi
else
    echo "Note: Main project directory not found (already gone or not created). Skipping main folder deletion."
fi

# Delete from Obsidian Vault Folder (04.vault/02.engagements-projects/)
if [ -d "$PROJECT_PATH_VAULT" ]; then
    rm -rf "$PROJECT_PATH_VAULT"
    if [ $? -eq 0 ]; then
        echo "✅ Successfully removed: $PROJECT_PATH_VAULT"
    else
        echo "❌ Failed to remove: $PROJECT_PATH_VAULT" >&2
    fi
else
    echo "Note: Vault project directory not found (already gone or not created). Skipping vault folder deletion."
fi

# 4. Success Message
echo "---"
echo "✅ SUCCESS: Project '$PROJECT_NAME' has been permanently erased."
echo "---"

exit 0
