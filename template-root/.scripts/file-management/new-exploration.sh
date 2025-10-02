#!/bin/bash

# ==============================================================================
# new-exploration.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Creates a new long-term research/exploration directory structure.
#              It enforces a minimal structure: a notes folder.
#
# USAGE: smarty new-exploration <exploration-name>
#
# EXAMPLE: smarty new-exploration "Fusion-Reactor-Modeling"
# ==============================================================================

# --- Configuration ---
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: The SMARTY_ROOT environment variable is not set. Did you restart your terminal after running init.sh?" >&2
    exit 1
fi

# Note: Research/Exploration notes are often kept directly under 03.research-exploration
BASE_EXPLORATION_DIR="$SMARTY_ROOT/03.research-exploration"
# The vault side typically mirrors this directly
VAULT_EXPLORATION_DIR="$SMARTY_ROOT/04.vault/03.research-exploration"

# --- Functions ---

# Function to display error messages and exit
error_exit() {
    echo -e "\nERROR: $1" >&2
    echo "Usage: smarty new-exploration <exploration-name>" >&2
    exit 1
}

# Function to create the core exploration structure
create_exploration_structure() {
    local base_dir="$1"
    local exploration_name="$2"

    EXPLORATION_PATH="$base_dir/$exploration_name"

    # Minimal structure: only a notes folder
    local core_dirs=(
        "notes"
    )

    echo "Creating core structure in $EXPLORATION_PATH..."
    for dir in "${core_dirs[@]}"; do
        mkdir -p "$EXPLORATION_PATH/$dir" || error_exit "Failed to create directory $EXPLORATION_PATH/$dir."
    done
}

# --- Main Execution ---

# 1. Validate and Parse Input
EXPLORATION_NAME="$1"

if [ -z "$EXPLORATION_NAME" ]; then
    error_exit "Missing exploration name."
fi
if [ ! -z "$2" ]; then
    error_exit "Unrecognized argument or flag: $2. The new-exploration script does not support flags."
fi

# Sanitize exploration name
EXPLORATION_NAME=$(echo "$EXPLORATION_NAME" | tr ' ' '-')

# Check if the directory already exists
if [ -d "$BASE_EXPLORATION_DIR/$EXPLORATION_NAME" ]; then
    error_exit "Exploration directory '$EXPLORATION_NAME' already exists in $BASE_EXPLORATION_DIR."
fi


# 2. Create Directory Structures

echo "Starting Smarty Vault exploration creation for: $EXPLORATION_NAME"

# A. Create structure in the main compiled/reference directory (03.research-exploration/)
echo "---"
create_exploration_structure "$BASE_EXPLORATION_DIR" "$EXPLORATION_NAME"
echo "Main exploration structure created successfully."

# B. Create structure in the raw Obsidian vault directory (04.vault/03.research-exploration/)
echo "---"
create_exploration_structure "$VAULT_EXPLORATION_DIR" "$EXPLORATION_NAME"
echo "Obsidian vault structure created successfully."

# 3. Success Message
echo "---"
echo "✅ SUCCESS: New exploration '$EXPLORATION_NAME' is ready!"
echo "   - Main files and data go into: $BASE_EXPLORATION_DIR/$EXPLORATION_NAME/"
echo "   - Raw Obsidian source notes go into: $VAULT_EXPLORATION_DIR/$EXPLORATION_NAME/01.notes/"
echo "---"

exit 0
