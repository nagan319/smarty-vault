#!/bin/bash

# ==============================================================================
# package.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Creates a compressed archive (tar.gz) of the entire active 
#              Smarty Vault structure (template-root/), excluding temporary 
#              files and operating system clutter.
#
# USAGE: smarty package [filename]
#
# EXAMPLE: smarty package "Academic-Backup-2025-Q3"
# ==============================================================================

# --- Configuration ---
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: The SMARTY_ROOT environment variable is not set. Did you restart your terminal after running init.sh?" >&2
    exit 1
fi

# Define the directory where the final package will be saved (e.g., the user's home directory)
OUTPUT_DIR="$HOME"

# Define files/directories to exclude from the backup for a clean package
EXCLUSIONS=(
    # Operating system files
    --exclude '**/Thumbs.db'
    --exclude '**/.DS_Store'
    # Git-specific metadata (not needed in the archive)
    --exclude '**.git'
    --exclude '**.gitignore'
    # Optional: exclude large, downloaded files if they can be easily re-acquired
    # --exclude '**/textbooks/*'
)

# --- Functions ---

error_exit() {
    echo -e "\nERROR: $1" >&2
    echo "Usage: smarty package [filename]" >&2
    exit 1
}

# --- Main Execution ---

# 1. Determine Output Filename
if [ -z "$1" ]; then
    DEFAULT_NAME="SmartyVault-Package-$(date +%Y%m%d-%H%M%S)"
    read -rp "Enter filename for the archive (default: $DEFAULT_NAME): " ARCHIVE_NAME
    if [ -z "$ARCHIVE_NAME" ]; then
        ARCHIVE_NAME="$DEFAULT_NAME"
    fi
else
    ARCHIVE_NAME="$1"
fi

FINAL_ARCHIVE_PATH="$OUTPUT_DIR/$ARCHIVE_NAME.tar.gz"

# Check for existing file
if [ -f "$FINAL_ARCHIVE_PATH" ]; then
    error_exit "Archive file '$FINAL_ARCHIVE_PATH' already exists. Aborting to prevent overwrite."
fi

# 2. Package Creation
echo "--- Starting Vault Packaging ---"
echo "Source Directory: $SMARTY_ROOT"
echo "Target Archive: $FINAL_ARCHIVE_PATH"
echo "Please wait, this may take a moment..."

# Navigate to the parent directory of SMARTY_ROOT to correctly name the archive root folder
VAULT_PARENT_DIR=$(dirname "$SMARTY_ROOT")
VAULT_ROOT_NAME=$(basename "$SMARTY_ROOT")

cd "$VAULT_PARENT_DIR" || error_exit "Could not navigate to parent directory: $VAULT_PARENT_DIR"

# Execute the tar command with exclusions
tar -czvf "$FINAL_ARCHIVE_PATH" "${EXCLUSIONS[@]}" "$VAULT_ROOT_NAME"

if [ $? -ne 0 ]; then
    error_exit "Packaging failed. Check permissions or disk space."
fi

# 3. Success Message
echo "---"
echo "✅ SUCCESS: Smarty Vault package created!"
echo "Size: $(du -h "$FINAL_ARCHIVE_PATH" | awk '{print $1}')"
echo "Location: $FINAL_ARCHIVE_PATH"
echo "---"

exit 0
