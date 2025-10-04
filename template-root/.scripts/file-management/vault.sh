#!/bin/bash

# ==============================================================================
# vault.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Launches the Obsidian Vault folder (04.vault/) directly 
#              using the explicit Obsidian executable path.
# ==============================================================================

# --- Configuration: CHANGE THIS LINE ---
# Find the command that works for your system (e.g., 'obsidian' if in PATH, or the full Flatpak command)
OBSIDIAN_CMD="flatpak run md.obsidian.Obsidian"
# ----------------------------------------

# --- Prerequisites ---
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: The SMARTY_ROOT environment variable is not set." >&2
    echo "Please source your shell profile." >&2
    exit 1
fi

# --- Execution ---

VAULT_PATH="$SMARTY_ROOT/04.vault"

if [ ! -d "$VAULT_PATH" ]; then
    echo "ERROR: Obsidian vault path not found at $VAULT_PATH." >&2
    exit 1
fi

echo "Launching Obsidian vault at: $VAULT_PATH"

# Execute Obsidian, passing the vault path as an argument.
# 'nohup' and '&' run the command in the background, detaching it from the terminal.
nohup $OBSIDIAN_CMD "$VAULT_PATH" > /dev/null 2>&1 &

exit 0
