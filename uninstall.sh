#!/bin/bash

# ==============================================================================
# uninstall.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Permanently removes the Smarty Vault installation. This script
#              removes the global 'smarty' command, cleans the environment 
#              variable from the profile file, and deletes the entire 
#              Smarty Vault folder. REQUIRES CONFIRMATION.
#
# USAGE: ./uninstall.sh
# ==============================================================================

# --- Configuration ---
GLOBAL_BIN_DIR="/usr/local/bin" 
WRAPPER_SCRIPT="$GLOBAL_BIN_DIR/smarty"

# File that defines user's shell environment (Zsh/Bash compatible)
PROFILE_FILE="$HOME/.bashrc"
if [ -f "$HOME/.zshrc" ]; then
    PROFILE_FILE="$HOME/.zshrc"
fi

# --- Functions ---

error_exit() {
    echo -e "\nERROR: $1" >&2
    exit 1
}

# --- Main Execution ---

echo "--- Smarty Vault Uninstaller ---"

# 1. Determine the Root Installation Path
# This is tricky because SMARTY_ROOT might not be loaded, so we look for it in the profile file first.
SMARTY_ROOT=$(grep "export SMARTY_ROOT=" "$PROFILE_FILE" | awk -F'"' '{print $2}')
INSTALL_PATH=$(dirname "$SMARTY_ROOT")
INSTALL_PATH=$(dirname "$INSTALL_PATH")

if [ -z "$INSTALL_PATH" ]; then
    echo "Note: SMARTY_ROOT variable not found in profile file. Assuming current directory's parent."
    # Fallback: Assume the script is being run from the top-level installed directory
    INSTALL_PATH=$(pwd)
    # Re-derive SMARTY_ROOT for deletion checks
    SMARTY_ROOT="$INSTALL_PATH/template-root"
fi


# 2. Confirmation Prompt (CRITICAL)
echo -e "\n\033[1;33m⚠️ WARNING: DANGER ZONE ⚠️\033[0m"
echo "You are about to PERMANENTLY DELETE Smarty Vault."
echo "The following directory and ALL its contents will be erased:"
echo "-> $INSTALL_PATH"
echo -e "\nType 'YES' to confirm permanent uninstallation:"

read -r CONFIRMATION

if [ "$CONFIRMATION" != "YES" ]; then
    echo -e "\nAborting operation. Smarty Vault was NOT deleted."
    exit 0
fi


# 3. Cleanup Global Command (smarty)
echo -e "\nPhase 1: Removing Global Command..."

if [ -f "$WRAPPER_SCRIPT" ]; then
    # Attempt to remove the global command, requiring sudo if installed in /usr/local/bin
    if [ -w "$GLOBAL_BIN_DIR" ]; then
        rm "$WRAPPER_SCRIPT"
    else
        echo "Attempting to remove wrapper with 'sudo'..."
        sudo rm "$WRAPPER_SCRIPT"
    fi

    if [ $? -eq 0 ]; then
        echo "✅ Successfully removed global command: $WRAPPER_SCRIPT"
    else
        echo "❌ Failed to remove global command. Check permissions or remove manually." >&2
    fi
fi


# 4. Cleanup Environment Variable (SMARTY_ROOT)
echo -e "\nPhase 2: Removing SMARTY_ROOT from Profile..."

# Use sed to remove the two lines defining the variable (tag + export line)
sed -i '' -e '/# Smarty Vault Root Path (Set by init.sh)/d' "$PROFILE_FILE"
sed -i '' -e '/export SMARTY_ROOT=/d' "$PROFILE_FILE"

echo "✅ SMARTY_ROOT definition removed from $PROFILE_FILE."


# 5. Delete the entire Installation Folder
echo -e "\nPhase 3: Deleting Installation Directory..."

if [ -d "$INSTALL_PATH" ]; then
    rm -rf "$INSTALL_PATH"
    if [ $? -eq 0 ]; then
        echo "✅ Successfully deleted: $INSTALL_PATH"
    else
        echo "❌ Failed to delete installation directory. Check permissions." >&2
    fi
fi


# 6. Final Status Report
echo "---"
echo "✅ UNINSTALL COMPLETE."
echo "Note: You must RESTART YOUR TERMINAL to fully unload the SMARTY_ROOT variable."
echo "---"

exit 0
