#!/bin/bash

# ==============================================================================
# new-course.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Creates a new course directory structure in both the full
#              compiled structure (01.courses/) and the minimal Obsidian
#              source vault structure (04.vault/01.courses/).
#
# USAGE: smarty new-course <course-name> [--code]
#
# EXAMPLE: smarty new-course "CS-201-Algorithms" --code
# ==============================================================================

# --- Configuration ---
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: The SMARTY_ROOT environment variable is not set." >&2
    echo "Did you restart your terminal after running init.sh?" >&2
    exit 1
fi

BASE_COURSES_DIR="$SMARTY_ROOT/01.courses"
VAULT_COURSES_DIR="$SMARTY_ROOT/04.vault/01.courses"

# --- Functions ---

# Function to display error messages and exit (ANSI codes removed)
error_exit() {
    echo -e "\nERROR: $1" >&2
    echo "Usage: smarty new-course <course-name> [--code]" >&2
    exit 1
}

# Function to create the core course structure
# $1: base_dir, $2: course_name, $3: include_code (true/false), $4: structure_type ('main' or 'vault')
create_course_structure() {
    local base_dir="$1"
    local course_name="$2"
    local include_code="$3"
    local structure_type="$4"

    COURSE_PATH="$base_dir/$course_name"
    local core_dirs=()

    # Define directory lists based on type
    if [ "$structure_type" == "main" ]; then
        # Full compiled structure (includes all output and reference folders)
        local core_dirs=(
            "assignments/raw"         # Editable source files
            "assignments/submissions" # Final compiled PDFs (submissions)
            "notes/lecture"           # Compiled lecture notes
            "notes/misc"              # Compiled auxiliary materials
            "textbooks"               # Large reference files (PDFs, eBooks)
        )
    elif [ "$structure_type" == "vault" ]; then
        # Minimal source structure (includes only editable folders for Markdown source)
        local core_dirs=(
            "assignments/submissions" # Editable assignment files
            "notes/lecture"           # Editable lecture notes source
            "notes/misc"              # Editable auxiliary notes source
        )
    fi

    echo "Creating $structure_type structure in $COURSE_PATH..."
    for dir in "${core_dirs[@]}"; do
        mkdir -p "$COURSE_PATH/$dir" || error_exit "Failed to create directory $COURSE_PATH/$dir."
    done

    # Add the optional 'code/' directory (only if requested AND only in the main structure)
    if [ "$include_code" = true ] && [ "$structure_type" == "main" ]; then
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

# Sanitize course name
COURSE_NAME=$(echo "$COURSE_NAME" | tr ' ' '-')

# Check if the course directory already exists
if [ -d "$BASE_COURSES_DIR/$COURSE_NAME" ]; then
    error_exit "Course directory '$COURSE_NAME' already exists in $BASE_COURSES_DIR."
fi


# 2. Create Directory Structures

echo "Starting Smarty Vault course creation for: $COURSE_NAME"

# A. Create structure in the main compiled/reference directory (01.courses/)
echo "---"
create_course_structure "$BASE_COURSES_DIR" "$COURSE_NAME" "$INCLUDE_CODE" "main"
echo "Main course structure created successfully."

# B. Create structure in the raw Obsidian vault directory (04.vault/01.courses/)
echo "---"
mkdir -p "$VAULT_COURSES_DIR" || error_exit "Failed to create parent vault directory $VAULT_COURSES_DIR."

# Note: The code and textbook directories are excluded by passing "vault" as the type.
create_course_structure "$VAULT_COURSES_DIR" "$COURSE_NAME" "$INCLUDE_CODE" "vault"
echo "Obsidian vault structure created successfully."

# 3. Success Message (ANSI codes removed)
echo "---"
echo "✅ SUCCESS: New course '$COURSE_NAME' is ready!"
echo "   - Compiled files will go into: $BASE_COURSES_DIR/$COURSE_NAME/"
echo "   - Raw Obsidian source notes go into: $VAULT_COURSES_DIR/$COURSE_NAME/"
echo "---"

exit 0
