#!/bin/bash

# ==============================================================================
# unarchive-course.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Unarchives a course by moving its folder structure from
#              01.courses/00.archived/ back to 01.courses/ in both the main
#              and vault directories.
#
# USAGE: smarty unarchive-course <course-name>
#
# EXAMPLE: smarty unarchive-course "PHIL-101-Logic"
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
    echo "Usage: smarty unarchive-course <course-name>" >&2
    exit 1
}

# --- Main Execution ---

# 1. Validate Input
COURSE_NAME="$1"

if [ -z "$COURSE_NAME" ]; then
    error_exit "Missing course name."
fi
if [ ! -z "$2" ]; then
    error_exit "Unrecognized argument or flag: $2. The unarchive-course script does not support flags."
fi

# Sanitize course name
COURSE_NAME=$(echo "$COURSE_NAME" | tr ' ' '-')

COURSE_ARCHIVE_PATH_MAIN="$BASE_ARCHIVE_DIR/$COURSE_NAME"
COURSE_ARCHIVE_PATH_VAULT="$VAULT_ARCHIVE_DIR/$COURSE_NAME"

# Check if the course is in the archive location
if [ ! -d "$COURSE_ARCHIVE_PATH_MAIN" ] && [ ! -d "$COURSE_ARCHIVE_PATH_VAULT" ]; then
    error_exit "Course directory '$COURSE_NAME' not found in archive folders. Nothing to unarchive."
fi

# Check if the course already exists in the active location
if [ -d "$BASE_ACTIVE_DIR/$COURSE_NAME" ] || [ -d "$VAULT_ACTIVE_DIR/$COURSE_NAME" ]; then
    error_exit "Course directory '$COURSE_NAME' already exists in active folders. Cannot unarchive."
fi

# 2. Unarchiving Logic
echo "Starting Smarty Vault course unarchiving for: $COURSE_NAME"

# Unarchive Main Compiled Folder (from 00.archived/ to 01.courses/)
echo "---"
if [ -d "$COURSE_ARCHIVE_PATH_MAIN" ]; then
    mv "$COURSE_ARCHIVE_PATH_MAIN" "$BASE_ACTIVE_DIR/"
    if [ $? -eq 0 ]; then
        echo "✅ Unarchived main folder: $COURSE_ARCHIVE_PATH_MAIN -> $BASE_ACTIVE_DIR/$COURSE_NAME"
    else
        echo "❌ Failed to unarchive main folder: $COURSE_ARCHIVE_PATH_MAIN" >&2
    fi
fi

# Unarchive Obsidian Vault Folder (from 00.archived/ to 04.vault/01.courses/)
if [ -d "$COURSE_ARCHIVE_PATH_VAULT" ]; then
    mv "$COURSE_ARCHIVE_PATH_VAULT" "$VAULT_ACTIVE_DIR/"
    if [ $? -eq 0 ]; then
        echo "✅ Unarchived vault folder: $COURSE_ARCHIVE_PATH_VAULT -> $VAULT_ACTIVE_DIR/$COURSE_NAME"
    else
        echo "❌ Failed to unarchive vault folder: $COURSE_ARCHIVE_PATH_VAULT" >&2
    fi
fi

# 3. Success Message
echo "---"
echo "✅ SUCCESS: Course '$COURSE_NAME' has been moved back to the active state."
echo "---"

exit 0
