#!/bin/bash

# ==============================================================================
# init.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: The one-time setup script for Smarty Vault. It handles:
#              1. Getting the desired installation path from the user.
#              2. Moving the repository to the permanent location.
#              3. Setting the SMARTY_ROOT environment variable permanently.
#              4. Setting executable permissions on all core scripts.
#              5. Creating the global 'smarty' command shortcut.
# ==============================================================================

# --- Configuration ---
# Target directory for global commands
GLOBAL_BIN_DIR="/usr/local/bin"
# Check the user's current shell and determine the configuration file path
# Default to Bash/Zsh, but check for Fish config presence
PROFILE_FILE="$HOME/.bashrc"
if [ -f "$HOME/.zshrc" ]; then
    PROFILE_FILE="$HOME/.zshrc"
fi
FISH_CONFIG_FILE="$HOME/.config/fish/config.fish"
SHELL_TYPE="bash"

if [ -f "$FISH_CONFIG_FILE" ]; then
    PROFILE_FILE="$FISH_CONFIG_FILE"
    SHELL_TYPE="fish"
fi

# Directory containing all helper scripts
SCRIPTS_DIR=".scripts"

# --- Functions ---

# Function to display error messages and exit
error_exit() {
    echo -e "\n\033[1;31mERROR:\033[0m $1" >&2
    exit 1
}

# 1. Get the final installation path from the user
get_install_path() {
    echo -e "\n\033[1;37m-- Smarty Vault Setup ---\033[0m"
    echo "Welcome! We need to choose the permanent home for Smarty Vault."
    echo "Recommended path: $HOME/SmartyVault"
    
    # Check if the repository is running from $HOME/SmartyVault
    CURRENT_REPO_DIR=$(dirname "$(pwd)")
    INSTALL_PATH_DEFAULT="$HOME/SmartyVault"

    # Use the current directory as the path if it's external to the home directory
    if [[ "$CURRENT_REPO_DIR" != "$HOME"* ]]; then
        INSTALL_PATH_DEFAULT="$CURRENT_REPO_DIR"
    fi

    read -rp "Enter the absolute path for the Smarty Vault folder [$INSTALL_PATH_DEFAULT]: " INSTALL_PATH
    
    # Use default if user pressed Enter
    INSTALL_PATH="${INSTALL_PATH:-$INSTALL_PATH_DEFAULT}"
    
    # Remove trailing slash for consistency
    INSTALL_PATH="${INSTALL_PATH%/}"

    # Basic validation
    if [ -z "$INSTALL_PATH" ]; then
        error_exit "Installation path cannot be empty."
    fi

    # Check if the target directory already exists and is not empty
    if [ -d "$INSTALL_PATH" ] && [ "$(ls -A "$INSTALL_PATH")" ]; then
        error_exit "The target directory '$INSTALL_PATH' already exists and is not empty. Please choose an empty or non-existent path."
    fi

    # Create the parent directory if it doesn't exist
    INSTALL_PARENT_DIR=$(dirname "$INSTALL_PATH")
    if [ ! -d "$INSTALL_PARENT_DIR" ]; then
        mkdir -p "$INSTALL_PARENT_DIR" || error_exit "Failed to create parent directory $INSTALL_PARENT_DIR."
    fi

    # The actual working root is inside the template folder
    export SMARTY_ROOT="$INSTALL_PATH/template-root"
}

# 2. Relocate the repository files
relocate_repo() {
    echo -e "\n\033[0;33mPhase 1: Relocating Files...\033[0m"
    
    # Get the current directory of the script (the downloaded repo folder)
    CURRENT_DIR=$(pwd)
    
    # Check if the target path is a sub-directory of the current path
    if [[ "$INSTALL_PATH" == "$CURRENT_DIR"* ]]; then
        error_exit "Cannot install into a subdirectory of the current location. Please choose an external path."
    fi

    # Move all contents to the final location
    echo "Moving contents from $CURRENT_DIR to $INSTALL_PATH..."
    
    # Note: Use 'mv' to rename the current directory to the new INSTALL_PATH
    mv "$CURRENT_DIR" "$INSTALL_PATH" || error_exit "Failed to move the repository files to $INSTALL_PATH."
    cd "$INSTALL_PATH"
    
    echo "File relocation complete. Current working directory is now $INSTALL_PATH."
}

# 3. Permanently set the SMARTY_ROOT environment variable
set_environment_variable() {
    echo -e "\n\033[0;33mPhase 2: Setting Environment Variable...\033[0m"
    
    # --- TEMPORARY EXPORT (For the rest of this init.sh script) ---
    # This ensures Phase 3 and 4 work immediately without a restart.
    export SMARTY_ROOT="$INSTALL_PATH/template-root"
    echo "SMARTY_ROOT temporarily set to $SMARTY_ROOT for script execution."
    
    # --- PERMANENT INSTALLATION ---
    
    TAG="# Smarty Vault Root Path"
    
    if [ "$SHELL_TYPE" = "fish" ]; then
        # Fish uses 'set -gx' and config.fish
        EXPORT_LINE="set -gx SMARTY_ROOT \"$SMARTY_ROOT\""
        
        # Check and update/append to the Fish config file
        if grep -q "SMARTY_ROOT" "$PROFILE_FILE"; then
            echo "Updating existing SMARTY_ROOT definition in $PROFILE_FILE..."
            # Use sed to replace the existing definition if it exists
            sed -i '' -e "/SMARTY_ROOT/s|^.*|$EXPORT_LINE|" "$PROFILE_FILE"
        else
            echo "Adding SMARTY_ROOT definition to $PROFILE_FILE..."
            echo -e "\n$TAG (Fish)\n$EXPORT_LINE" >> "$PROFILE_FILE"
        fi

    else
        # Bash/Zsh uses 'export' and the determined profile file
        EXPORT_LINE="export SMARTY_ROOT=\"$SMARTY_ROOT\""
        
        if grep -q "SMARTY_ROOT" "$PROFILE_FILE"; then
            # Use sed to replace the existing definition if it exists
            sed -i '' -e "/SMARTY_ROOT/ { N; s|.*|# Smarty Vault Root Path\n$EXPORT_LINE|; }" "$PROFILE_FILE"
        else
            echo "Adding SMARTY_ROOT definition to $PROFILE_FILE..."
            echo -e "\n$TAG (Bash/Zsh)\n$EXPORT_LINE" >> "$PROFILE_FILE"
        fi
    fi
    
    echo "SMARTY_ROOT permanently defined in $PROFILE_FILE."
}

# 4. Set executable permissions for all management scripts
set_permissions() {
    echo -e "\n\033[0;33mPhase 3: Setting Script Permissions...\033[0m"
    
    # Path to the .scripts folder within the new location
    local SCRIPT_PATH="$SMARTY_ROOT/$SCRIPTS_DIR"
    
    if [ ! -d "$SCRIPT_PATH" ]; then
        error_exit "Script directory '$SCRIPT_PATH' not found."
    fi

    # Use 'find' to recursively locate all .sh files in subdirectories and apply permissions.
    find "$SCRIPT_PATH" -type f -name "*.sh" -exec chmod +x {} \;
    
    if [ $? -ne 0 ]; then
        error_exit "Failed to set executable permissions on scripts."
    fi
    
    echo "All helper scripts are now executable."
}

# 5. Create the global 'smarty' wrapper command
create_global_command() {
    echo -e "\n\033[0;33mPhase 4: Creating Global 'smarty' Command...\033[0m"
    
    # A simple wrapper function placed in the global bin directory
    WRAPPER_SCRIPT="$GLOBAL_BIN_DIR/smarty"

    # --- CRITICAL FIX: Wrapper content now uses 'find' to locate script ---
    WRAPPER_CONTENT=$(cat << EOF
#!/bin/bash

# Smarty Vault Global Wrapper
# Finds and executes any script within the \$SMARTY_ROOT/.scripts/ directory structure.

SCRIPT_COMMAND="\$1"
shift

# 1. Define the base script directory
SMARTY_SCRIPT_BASE="\$SMARTY_ROOT/$SCRIPTS_DIR"

# 2. Find the script with the exact name (case-sensitive) recursively
# Note: Escaping the '*' is critical to prevent shell expansion here.
# Use the file extension in the search pattern
SCRIPT_PATH=\$(find "\$SMARTY_SCRIPT_BASE" -type f -name "\$SCRIPT_COMMAND.sh" 2>/dev/null)

if [ -z "\$SCRIPT_PATH" ]; then
    echo -e "\033[1;31mERROR:\033[0m Smarty command '\$SCRIPT_COMMAND' not found." >&2
    echo "Check available scripts in: \$SMARTY_ROOT/$SCRIPTS_DIR/" >&2
    exit 1
fi

# 3. Execute the found script with all remaining arguments
# Note: Use exec to replace the current shell process with the script
exec "\$SCRIPT_PATH" "\$@"
EOF
)

    # Check and warn if /usr/local/bin doesn't exist or isn't writable
    if [ ! -w "$GLOBAL_BIN_DIR" ]; then
        echo "Warning: Cannot write to $GLOBAL_BIN_DIR (Need sudo/root access)."
        echo "Attempting to create global command using 'sudo'..."
        echo -e "$WRAPPER_CONTENT" | sudo tee "$WRAPPER_SCRIPT" > /dev/null
        sudo chmod +x "$WRAPPER_SCRIPT"
    else
        echo "Creating wrapper at $WRAPPER_SCRIPT..."
        echo -e "$WRAPPER_CONTENT" > "$WRAPPER_SCRIPT"
        chmod +x "$WRAPPER_SCRIPT"
    fi
    
    if [ $? -ne 0 ]; then
        error_exit "Failed to create or set permissions on the global 'smarty' wrapper script."
    fi
    
    echo "Global 'smarty' command created successfully!"
}

# --- Main Execution Flow ---

# 1. The user must set execution permission before running.
# The script relies on the user running 'chmod +x init.sh' first.

get_install_path
relocate_repo
set_environment_variable
set_permissions
create_global_command

# 6. Final success message and instructions
echo -e "\n\n\033[1;32m🎉 Smarty Vault Installation Complete!\033[0m"
echo "--------------------------------------------------------------------------------"
echo "1. RESTART YOUR TERMINAL (or run 'source $PROFILE_FILE') to load the new SMARTY_ROOT variable."
echo "2. Your configuration is now located at: $INSTALL_PATH"
echo "3. Open Obsidian and create a new vault pointing to: $SMARTY_ROOT/04.vault/"
echo -e "4. Test your new command (from any directory):\n"
echo -e "\033[1;37msmarty new-course \"CHEM-101-Intro\"\033[0m"
echo -e "\033[1;37msmarty new-project \"Thesis-Manuscript\"\033[0m"
echo "--------------------------------------------------------------------------------"

exit 0
