#!/bin/bash

# ==============================================================================
# archive-project.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Archives a project by moving its active folder structure from
#              02.engagements-projects/ to 02.engagements-projects/00.archived/
#              in both the main and vault directories.
#
# USAGE: smarty archive-project <project-name>
#
# EXAMPLE: smarty archive-project "Marketing-Internship-Q3"
# ==============================================================================

# --- Configuration ---
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: The SMARTY_ROOT environment variable is not set. Did you restart your terminal after running init.sh?" >&2
    exit 1
fi

BASE_ACTIVE_DIR="$SMARTY_ROOT/02.engagements-projects"
BASE_ARCHIVE_DIR="$BASE_ACTIVE_DIR/00.archived"
VAULT_ACTIVE_DIR="$SMARTY_ROOT/04.vault/02.engagements-projects"
VAULT_ARCHIVE_DIR="$VAULT_ACTIVE_DIR/00.archived"

# --- Functions ---

error_exit() {
    echo -e "\nERROR: $1" >&2
    echo "Usage: smarty archive-project <project-name>" >&2
    exit 1
}

# --- Main Execution ---

# 1. Validate Input
PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
    error_exit "Missing project name."
fi
if [ ! -z "$2" ]; then
    error_exit "Unrecognized argument or flag: $2. The archive-project script does not support flags."
fi

# Sanitize project name
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr ' ' '-')

PROJECT_PATH_MAIN="$BASE_ACTIVE_DIR/$PROJECT_NAME"
PROJECT_PATH_VAULT="$VAULT_ACTIVE_DIR/$PROJECT_NAME"

# Check if the project exists and is not already archived
if [ ! -d "$PROJECT_PATH_MAIN" ]; then
    if [ -d "$BASE_ARCHIVE_DIR/$PROJECT_NAME" ]; then
        error_exit "Project '$PROJECT_NAME' is already located in the archive folder."
    fi
    if [ ! -d "$PROJECT_PATH_VAULT" ]; then
        error_exit "Project directory '$PROJECT_NAME' not found in active folders. Nothing to archive."
    fi
fi

# 2. Archiving Logic
echo "Starting Smarty Vault project archiving for: $PROJECT_NAME"

# Archive Main Compiled Folder (02.engagements-projects/)
echo "---"
if [ -d "$PROJECT_PATH_MAIN" ]; then
    mv "$PROJECT_PATH_MAIN" "$BASE_ARCHIVE_DIR/"
    if [ $? -eq 0 ]; then
        echo "✅ Archived main folder: $PROJECT_PATH_MAIN -> $BASE_ARCHIVE_DIR/$PROJECT_NAME"
    else
        echo "❌ Failed to archive main folder: $PROJECT_PATH_MAIN" >&2
    fi
fi

# Archive Obsidian Vault Folder (04.vault/02.engagements-projects/)
if [ -d "$PROJECT_PATH_VAULT" ]; then
    mv "$PROJECT_PATH_VAULT" "$VAULT_ARCHIVE_DIR/"
    if [ $? -eq 0 ]; then
        echo "✅ Archived vault folder: $PROJECT_PATH_VAULT -> $VAULT_ARCHIVE_DIR/$PROJECT_NAME"
    else
        echo "❌ Failed to archive vault folder: $PROJECT_PATH_VAULT" >&2
    fi
fi

# 3. Success Message
echo "---"
echo "✅ SUCCESS: Project '$PROJECT_NAME' has been moved to the archived state."
echo "---"

exit 0
