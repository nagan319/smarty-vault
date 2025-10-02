#!/bin/bash

# ==============================================================================
# new-course.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Creates a new course directory structure in both the main
#              01.courses/ folder (for compiled files) and the 04.vault/
#              (for raw Obsidian source files) using the global SMARTY_ROOT.
#
# USAGE: smarty new-course <course-name> [--code]
#
# EXAMPLE: smarty new-course "CS-201-Algorithms" --code
# ==============================================================================

# --- CRITICAL CHANGE: Use the globally defined SMARTY_ROOT ---
# This variable was set permanently by init.sh, making this script location-independent.
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: The SMARTY_ROOT environment variable is not set." >&2
    echo "Did you restart your terminal after running init.sh?" >&2
    exit 1
fi

# Base paths are now defined using the absolute SMARTY_ROOT
BASE_COURSES_DIR="$SMARTY_ROOT/01.courses"
VAULT_COURSES_DIR="$SMARTY_ROOT/04.vault/01.courses"

# --- Functions ---

# Function to display error messages and exit
error_exit() {
    echo -e "\n\033[0;31mERROR:\033[0m $1" >&2
    echo "Usage: smarty new-course <course-name> [--code]" >&2
    exit 1
}

# Function to create the core course structure
create_course_structure() {
    local base_dir="$1"
    local course_name="$2"
    local include_code="$3"

    COURSE_PATH="$base_dir/$course_name"

    # Define the core structure common to both main and vault directories
    local core_dirs=(
        "assignments/raw"
        "assignments/submissions"
        "notes/lecture"
        "notes/misc"
        "textbooks"
    )

    echo "Creating core structure in $COURSE_PATH..."
    for dir in "${core_dirs[@]}"; do
        mkdir -p "$COURSE_PATH/$dir" || error_exit "Failed to create directory $COURSE_PATH/$dir."
    done

    # Add the optional code directory
    if [ "$include_code" = true ]; then
        echo "Including optional 'code/' directory."
        mkdir -p "$COURSE_PATH/code" || error_exit "Failed to create directory $COURSE_PATH/code."
    fi
}

# --- Main Execution ---

# 1. Validate and Parse Input
COURSE_NAME="$1"
INCLUDE_CODE=false

if [ -z "$COURSE_NAME" ]; then
    error_exit "Missing course name."
fi

# Check for optional flags
if [ "$2" == "--code" ]; then
    INCLUDE_CODE=true
elif [ ! -z "$2" ]; then
    error_exit "Unrecognized flag: $2"
fi

# Sanitize course name to be safe for directory names (replaces spaces with hyphens)
COURSE_NAME=$(echo "$COURSE_NAME" | tr ' ' '-')

# Check if the course directory already exists
if [ -d "$BASE_COURSES_DIR/$COURSE_NAME" ]; then
    error_exit "Course directory '$COURSE_NAME' already exists in $BASE_COURSES_DIR."
fi


# 2. Create Directory Structures

echo "Starting Smarty Vault course creation for: $COURSE_NAME"

# A. Create structure in the main compiled/reference directory (01.courses/)
echo "---"
create_course_structure "$BASE_COURSES_DIR" "$COURSE_NAME" "$INCLUDE_CODE"
echo "Main course structure created successfully."

# B. Create structure in the raw Obsidian vault directory (04.vault/01.courses/)
echo "---"
# Ensure the parent vault course dir exists first
mkdir -p "$VAULT_COURSES_DIR" || error_exit "Failed to create parent vault directory $VAULT_COURSES_DIR."

# The create_course_structure function creates the assignment/raw folder for notes
create_course_structure "$VAULT_COURSES_DIR" "$COURSE_NAME" "$INCLUDE_CODE"
echo "Obsidian vault structure created successfully."

# 3. Success Message
echo "---"
echo -e "✅ SUCCESS: New course '\033[1;37m$COURSE_NAME\033[0m' is ready!"
echo "   - Compiled files will go into: $BASE_COURSES_DIR/$COURSE_NAME/"
echo "   - Raw Obsidian source notes go into: $VAULT_COURSES_DIR/$COURSE_NAME/"
echo "---"

exit 0
