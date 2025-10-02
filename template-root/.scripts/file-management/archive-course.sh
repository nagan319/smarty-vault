#!/bin/bash

# ==============================================================================
# archive-course.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Archives a course by moving its active folder structure from
#              01.courses/ to 01.courses/00.archived/ in both the main
#              and vault directories.
#
# USAGE: smarty archive-course <course-name>
#
# EXAMPLE: smarty archive-course "PHIL-101-Logic"
# ==============================================================================

# --- Configuration ---
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: The SMARTY_ROOT environment variable is not set. Did you restart your terminal after running init.sh?" >&2
    exit 1
fi

BASE_ACTIVE_DIR="$SMARTY_ROOT/01.courses"
BASE_ARCHIVE_DIR="$BASE_ACTIVE_DIR/00.archived"
VAULT_ACTIVE_DIR="$SMARTY_ROOT/04.vault/01.courses"
VAULT_ARCHIVE_DIR="$VAULT_ACTIVE_DIR/00.archived"

# --- Functions ---

error_exit() {
    echo -e "\nERROR: $1" >&2
    echo "Usage: smarty archive-course <course-name>" >&2
    exit 1
}

# --- Main Execution ---

# 1. Validate Input
COURSE_NAME="$1"

if [ -z "$COURSE_NAME" ]; then
    error_exit "Missing course name."
fi
if [ ! -z "$2" ]; then
    error_exit "Unrecognized argument or flag: $2. The archive-course script does not support flags."
fi

# Sanitize course name
COURSE_NAME=$(echo "$COURSE_NAME" | tr ' ' '-')

COURSE_PATH_MAIN="$BASE_ACTIVE_DIR/$COURSE_NAME"
COURSE_PATH_VAULT="$VAULT_ACTIVE_DIR/$COURSE_NAME"

# Check if the course exists and is not already archived
if [ ! -d "$COURSE_PATH_MAIN" ]; then
    if [ -d "$BASE_ARCHIVE_DIR/$COURSE_NAME" ]; then
        error_exit "Course '$COURSE_NAME' is already located in the archive folder."
    fi
    # If the main folder is missing, but the vault folder is not, that's an issue.
    if [ ! -d "$COURSE_PATH_VAULT" ]; then
        error_exit "Course directory '$COURSE_NAME' not found in active folders. Nothing to archive."
    fi
fi

# 2. Archiving Logic
echo "Starting Smarty Vault course archiving for: $COURSE_NAME"

# Archive Main Compiled Folder (01.courses/)
echo "---"
if [ -d "$COURSE_PATH_MAIN" ]; then
    mv "$COURSE_PATH_MAIN" "$BASE_ARCHIVE_DIR/"
    if [ $? -eq 0 ]; then
        echo "✅ Archived main folder: $COURSE_PATH_MAIN -> $BASE_ARCHIVE_DIR/$COURSE_NAME"
    else
        echo "❌ Failed to archive main folder: $COURSE_PATH_MAIN" >&2
    fi
fi

# Archive Obsidian Vault Folder (04.vault/01.courses/)
if [ -d "$COURSE_PATH_VAULT" ]; then
    mv "$COURSE_PATH_VAULT" "$VAULT_ARCHIVE_DIR/"
    if [ $? -eq 0 ]; then
        echo "✅ Archived vault folder: $COURSE_PATH_VAULT -> $VAULT_ARCHIVE_DIR/$COURSE_NAME"
    else
        echo "❌ Failed to archive vault folder: $COURSE_PATH_VAULT" >&2
    fi
fi

# 3. Success Message
echo "---"
echo "✅ SUCCESS: Course '$COURSE_NAME' has been moved to the archived state."
echo "---"

exit 0
