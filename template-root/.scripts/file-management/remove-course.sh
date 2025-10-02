#!/bin/bash

# ==============================================================================
# remove-course.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Permanently deletes a course and its entire structure from both 
#              the main directory and the Obsidian vault. Requires confirmation.
#
# USAGE: smarty remove-course <course-name>
#
# EXAMPLE: smarty remove-course "CS-201-Algorithms"
# ==============================================================================

# --- Configuration ---
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: The SMARTY_ROOT environment variable is not set. Did you restart your terminal after running init.sh?" >&2
    exit 1
fi

BASE_COURSES_DIR="$SMARTY_ROOT/01.courses"
VAULT_COURSES_DIR="$SMARTY_ROOT/04.vault/01.courses"

# --- Functions ---

# Function to display error messages and exit
error_exit() {
    echo -e "\nERROR: $1" >&2
    echo "Usage: smarty remove-course <course-name>" >&2
    exit 1
}

# --- Main Execution ---

# 1. Validate Input
COURSE_NAME="$1"

if [ -z "$COURSE_NAME" ]; then
    error_exit "Missing course name."
fi
if [ ! -z "$2" ]; then
    error_exit "Unrecognized argument or flag: $2. The remove-course script does not support flags."
fi

# Sanitize course name
COURSE_NAME=$(echo "$COURSE_NAME" | tr ' ' '-')

COURSE_PATH_MAIN="$BASE_COURSES_DIR/$COURSE_NAME"
COURSE_PATH_VAULT="$VAULT_COURSES_DIR/$COURSE_NAME"

# Check if the course directory exists at all
if [ ! -d "$COURSE_PATH_MAIN" ] && [ ! -d "$COURSE_PATH_VAULT" ]; then
    error_exit "Course directory '$COURSE_NAME' not found in either the main or vault locations. Nothing to remove."
fi

# 2. Confirmation Prompt (CRITICAL)
echo -e "\n\033[1;33m⚠️ WARNING: DANGER ZONE ⚠️\033[0m"
echo "You are about to PERMANENTLY DELETE the course '$COURSE_NAME' and ALL its contents from:"
echo "1. Main Compiled Folder: $COURSE_PATH_MAIN"
echo "2. Obsidian Vault Folder: $COURSE_PATH_VAULT"
echo -e "\nType 'YES' to confirm permanent deletion:"

read -r CONFIRMATION

if [ "$CONFIRMATION" != "YES" ]; then
    echo -e "\nAborting operation. Course '$COURSE_NAME' was NOT deleted."
    exit 0
fi

# 3. Deletion Logic
echo -e "\nConfirmed. Deleting course contents..."

# Delete from Main Compiled Folder (01.courses/)
if [ -d "$COURSE_PATH_MAIN" ]; then
    rm -rf "$COURSE_PATH_MAIN"
    if [ $? -eq 0 ]; then
        echo "✅ Successfully removed: $COURSE_PATH_MAIN"
    else
        echo "❌ Failed to remove: $COURSE_PATH_MAIN" >&2
    fi
else
    echo "Note: Main course directory not found (already gone or not created). Skipping main folder deletion."
fi

# Delete from Obsidian Vault Folder (04.vault/01.courses/)
if [ -d "$COURSE_PATH_VAULT" ]; then
    rm -rf "$COURSE_PATH_VAULT"
    if [ $? -eq 0 ]; then
        echo "✅ Successfully removed: $COURSE_PATH_VAULT"
    else
        echo "❌ Failed to remove: $COURSE_PATH_VAULT" >&2
    fi
else
    echo "Note: Vault course directory not found (already gone or not created). Skipping vault folder deletion."
fi

# 4. Success Message
echo "---"
echo "✅ SUCCESS: Course '$COURSE_NAME' has been permanently erased."
echo "---"

exit 0
