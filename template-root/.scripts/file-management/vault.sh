#!/bin/bash

# ==============================================================================
# vault.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Launches the Obsidian Vault using the Obsidian URI scheme.
# ==============================================================================

# --- Configuration ---
# 1. Name of the Vault (Must match the name Obsidian registered for the 04.vault folder)
#    Since the folder is '04.vault', we assume the name is the same.
VAULT_NAME="04.vault"

# 2. Base URI for the vault (Path will be added below)
OBS_URI_BASE="obsidian://open?vault="

# --- Prerequisites ---
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: The SMARTY_ROOT environment variable is not set." >&2
    echo "Please source your shell profile." >&2
    exit 1
fi

# --- Execution ---

# 1. Build the full Obsidian URI. Note: Spaces must be URL-encoded (%20), but we
#    assume your structured folder name "04.vault" doesn't have spaces.
FULL_URI="${OBS_URI_BASE}${VAULT_NAME}"

echo "Launching vault via URI: $FULL_URI"

# 2. Use xdg-open to handle the custom URI protocol.
#    This command is generally compatible with Wayland/X11.
nohup xdg-open "$FULL_URI" > /dev/null 2>&1 &

exit 0
