#!/bin/bash

# ==============================================================================
# remove-exploration.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Permanently deletes a research exploration folder and ALL its 
#              contents from the main directory (03.research-exploration/) and 
#              the Obsidian vault (04.vault/03.research-exploration/). 
#              Requires confirmation.
#
# USAGE: smarty remove-exploration <exploration-name>
#
# EXAMPLE: smarty remove-exploration "Fusion-Reactor-Modeling"
# ==============================================================================

# --- Configuration ---
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: The SMARTY_ROOT environment variable is not set. Did you restart your terminal after running init.sh?" >&2
    exit 1
fi

BASE_EXPLORATION_DIR="$SMARTY_ROOT/03.research-exploration"
VAULT_EXPLORATION_DIR="$SMARTY_ROOT/04.vault/03.research-exploration"

# --- Functions ---

# Function to display error messages and exit
error_exit() {
    echo -e "\nERROR: $1" >&2
    echo "Usage: smarty remove-exploration <exploration-name>" >&2
    exit 1
}

# --- Main Execution ---

# 1. Validate Input
EXPLORATION_NAME="$1"

if [ -z "$EXPLORATION_NAME" ]; then
    error_exit "Missing exploration name."
fi
if [ ! -z "$2" ]; then
    error_exit "Unrecognized argument or flag: $2. The remove-exploration script does not support flags."
fi

# Sanitize exploration name
EXPLORATION_NAME=$(echo "$EXPLORATION_NAME" | tr ' ' '-')

EXPLORATION_PATH_MAIN="$BASE_EXPLORATION_DIR/$EXPLORATION_NAME"
EXPLORATION_PATH_VAULT="$VAULT_EXPLORATION_DIR/$EXPLORATION_NAME"

# Check if the directory exists at all
if [ ! -d "$EXPLORATION_PATH_MAIN" ] && [ ! -d "$EXPLORATION_PATH_VAULT" ]; then
    error_exit "Exploration directory '$EXPLORATION_NAME' not found in either location. Nothing to remove."
fi

# 2. Confirmation Prompt (CRITICAL)
echo -e "\n\033[1;33m⚠️ WARNING: DANGER ZONE ⚠️\033[0m"
echo "You are about to PERMANENTLY DELETE the exploration '$EXPLORATION_NAME' and ALL its contents from:"
echo "1. Main Research Folder: $EXPLORATION_PATH_MAIN"
echo "2. Obsidian Vault Folder: $EXPLORATION_PATH_VAULT"
echo -e "\nType 'YES' to confirm permanent deletion:"

read -r CONFIRMATION

if [ "$CONFIRMATION" != "YES" ]; then
    echo -e "\nAborting operation. Exploration '$EXPLORATION_NAME' was NOT deleted."
    exit 0
fi

# 3. Deletion Logic
echo -e "\nConfirmed. Deleting exploration contents..."

# Delete from Main Research Folder (03.research-exploration/)
if [ -d "$EXPLORATION_PATH_MAIN" ]; then
    rm -rf "$EXPLORATION_PATH_MAIN"
    if [ $? -eq 0 ]; then
        echo "✅ Successfully removed: $EXPLORATION_PATH_MAIN"
    else
        echo "❌ Failed to remove: $EXPLORATION_PATH_MAIN" >&2
    fi
else
    echo "Note: Main research directory not found. Skipping main folder deletion."
fi

# Delete from Obsidian Vault Folder (04.vault/03.research-exploration/)
if [ -d "$EXPLORATION_PATH_VAULT" ]; then
    rm -rf "$EXPLORATION_PATH_VAULT"
    if [ $? -eq 0 ]; then
        echo "✅ Successfully removed: $EXPLORATION_PATH_VAULT"
    else
        echo "❌ Failed to remove: $EXPLORATION_PATH_VAULT" >&2
    fi
else
    echo "Note: Vault research directory not found. Skipping vault folder deletion."
fi

# 4. Success Message
echo "---"
echo "✅ SUCCESS: Exploration '$EXPLORATION_NAME' has been permanently erased."
echo "---"

exit 0
