#!/bin/bash

# ==============================================================================
# unarchive-project.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Unarchives a project by moving its folder structure from
#              02.engagements-projects/00.archived/ back to 02.engagements-projects/
#              in both the main and vault directories.
#
# USAGE: smarty unarchive-project <project-name>
#
# EXAMPLE: smarty unarchive-project "Marketing-Internship-Q3"
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
    echo "Usage: smarty unarchive-project <project-name>" >&2
    exit 1
}

# --- Main Execution ---

# 1. Validate Input
PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
    error_exit "Missing project name."
fi
if [ ! -z "$2" ]; then
    error_exit "Unrecognized argument or flag: $2. The unarchive-project script does not support flags."
fi

# Sanitize project name
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr ' ' '-')

PROJECT_ARCHIVE_PATH_MAIN="$BASE_ARCHIVE_DIR/$PROJECT_NAME"
PROJECT_ARCHIVE_PATH_VAULT="$VAULT_ARCHIVE_DIR/$PROJECT_NAME"

# Check if the project is in the archive location
if [ ! -d "$PROJECT_ARCHIVE_PATH_MAIN" ] && [ ! -d "$PROJECT_ARCHIVE_PATH_VAULT" ]; then
    error_exit "Project directory '$PROJECT_NAME' not found in archive folders. Nothing to unarchive."
fi

# Check if the project already exists in the active location
if [ -d "$BASE_ACTIVE_DIR/$PROJECT_NAME" ] || [ -d "$VAULT_ACTIVE_DIR/$PROJECT_NAME" ]; then
    error_exit "Project directory '$PROJECT_NAME' already exists in active folders. Cannot unarchive."
fi

# 2. Unarchiving Logic
echo "Starting Smarty Vault project unarchiving for: $PROJECT_NAME"

# Unarchive Main Compiled Folder (from 00.archived/ to 02.engagements-projects/)
echo "---"
if [ -d "$PROJECT_ARCHIVE_PATH_MAIN" ]; then
    mv "$PROJECT_ARCHIVE_PATH_MAIN" "$BASE_ACTIVE_DIR/"
    if [ $? -eq 0 ]; then
        echo "✅ Unarchived main folder: $PROJECT_ARCHIVE_PATH_MAIN -> $BASE_ACTIVE_DIR/$PROJECT_NAME"
    else
        echo "❌ Failed to unarchive main folder: $PROJECT_ARCHIVE_PATH_MAIN" >&2
    fi
fi

# Unarchive Obsidian Vault Folder (from 00.archived/ to 04.vault/02.engagements-projects/)
if [ -d "$PROJECT_ARCHIVE_PATH_VAULT" ]; then
    mv "$PROJECT_ARCHIVE_PATH_VAULT" "$VAULT_ACTIVE_DIR/"
    if [ $? -eq 0 ]; then
        echo "✅ Unarchived vault folder: $PROJECT_ARCHIVE_PATH_VAULT -> $VAULT_ACTIVE_DIR/$PROJECT_NAME"
    else
        echo "❌ Failed to unarchive vault folder: $PROJECT_ARCHIVE_PATH_VAULT" >&2
    fi
fi

# 3. Success Message
echo "---"
echo "✅ SUCCESS: Project '$PROJECT_NAME' has been moved back to the active state."
echo "---"

exit 0
