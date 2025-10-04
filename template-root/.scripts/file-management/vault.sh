#!/bin/bash

# ==============================================================================
# vault.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Opens the Obsidian Vault folder (04.vault/) using the OS's 
#              default file handler. This launches Obsidian directly to the 
#              vault location, provided the SMARTY_ROOT variable is set.
# ==============================================================================

# --- Prerequisites ---
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: The SMARTY_ROOT environment variable is not set." >&2
    echo "Please run the global command 'smarty' or source your shell profile." >&2
    exit 1
fi

# --- Execution ---

VAULT_PATH="$SMARTY_ROOT/04.vault"

if [ ! -d "$VAULT_PATH" ]; then
    echo "ERROR: Obsidian vault path not found at $VAULT_PATH." >&2
    exit 1
fi

echo "Launching Obsidian vault at: $VAULT_PATH"

# Use the appropriate command for the operating system to open the path
# 'xdg-open' for Linux (Wayland/X11), 'open' for macOS, 'start' for Windows (WSL).
# Note: For many Linux/Wayland setups, this will launch Obsidian directly.

case "$(uname -s)" in
    Linux*)
        # Uses the Linux standard way to open a file/directory (xdg-open is Wayland/X11 compatible)
        nohup xdg-open "$VAULT_PATH" > /dev/null 2>&1 &
        ;;
    Darwin*)
        # macOS standard command
        open "$VAULT_PATH"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        # Windows/Git Bash/MSYS standard (requires 'start' to run in background)
        start "" "$VAULT_PATH"
        ;;
    *)
        echo "Warning: Using generic 'xdg-open' on unknown OS." >&2
        xdg-open "$VAULT_PATH"
        ;;
esac

exit 0
