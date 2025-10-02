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
# File that defines user's shell environment (Zsh/Bash compatible)
PROFILE_FILE="$HOME/.bashrc"
if [ -f "$HOME/.zshrc" ]; then
    PROFILE_FILE="$HOME/.zshrc"
fi
# Directory containing all helper scripts
SCRIPTS_DIR=".scripts"

# --- Functions ---

# Function to display error messages and exit
error_exit() {
    echo -e "\nERROR: $1" >&2
    exit 1
}

# 1. Get the final installation path from the user
get_install_path() {
    echo -e "\n\033[1;37m-- Smarty Vault Setup ---\033[0m"
    echo "Welcome! We need to choose the permanent home for Smarty Vault."
    echo "Recommended path: $HOME/SmartyVault"
    read -rp "Enter the absolute path for the Smarty Vault folder: " INSTALL_PATH
    
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

    # Absolute path to the template-root, which contains 01.courses, 04.vault, etc.
    export SMARTY_ROOT="$INSTALL_PATH/template-root"
}

# 2. Relocate the repository files
relocate_repo() {
    echo -e "\n\033[0;33mPhase 1: Relocating Files...\033[0m"
    
    # Get the current directory of the script (the downloaded repo folder)
    CURRENT_DIR=$(pwd)
    
    # Move all contents to the final location
    echo "Moving contents from $CURRENT_DIR to $INSTALL_PATH..."
    
    # Check if the target path is a sub-directory of the current path
    if [[ "$INSTALL_PATH" == "$CURRENT_DIR"* ]]; then
        error_exit "Cannot install into a subdirectory of the current location. Please choose an external path."
    fi

    mv "$CURRENT_DIR" "$INSTALL_PATH" || error_exit "Failed to move the repository files to $INSTALL_PATH."
    cd "$INSTALL_PATH"
    
    echo "File relocation complete. Current working directory is now $INSTALL_PATH."
}

# 3. Permanently set the SMARTY_ROOT environment variable
set_environment_variable() {
    echo -e "\n\033[0;33mPhase 2: Setting Environment Variable...\033[0m"
    
    # Variable line to inject
    EXPORT_LINE="# Smarty Vault Root Path (Set by init.sh)\nexport SMARTY_ROOT=\"$SMARTY_ROOT\""
    
    # Check if the variable is already set by looking for the Smarty Vault tag
    if grep -q "Smarty Vault Root Path" "$PROFILE_FILE"; then
        echo "Updating existing SMARTY_ROOT definition in $PROFILE_FILE..."
        # Use sed to safely replace the existing entry
        sed -i '' -e '/# Smarty Vault Root Path/ { N; s|.*|'"$EXPORT_LINE"'|; }' "$PROFILE_FILE"
    else
        echo "Adding SMARTY_ROOT definition to $PROFILE_FILE..."
        echo -e "\n$EXPORT_LINE" >> "$PROFILE_FILE"
    fi
    
    # Source the profile file immediately so the variable is available for the rest of the script
    source "$PROFILE_FILE"
    
    echo "SMARTY_ROOT is set to $SMARTY_ROOT and updated in $PROFILE_FILE."
}

# 4. Set executable permissions for all management scripts
set_permissions() {
    echo -e "\nPhase 3: Setting Script Permissions..."
    
    # Path to the .scripts folder within the new location
    local SCRIPT_PATH="$SMARTY_ROOT/.scripts"
    
    # Use 'find' to recursively locate all .sh files in subdirectories and apply permissions.
    find "$SCRIPT_PATH" -type f -name "*.sh" -exec chmod +x {} \;
    
    if [ $? -ne 0 ]; then
        error_exit "Failed to set executable permissions on scripts."
    fi
    
    echo "All helper scripts in subdirectories are now executable."
}

# 5. Create the global 'smarty' wrapper command
create_global_command() {
    echo -e "\n\033[0;33mPhase 4: Creating Global 'smarty' Command...\033[0m"
    
    # A simple wrapper function placed in the global bin directory
    WRAPPER_SCRIPT="$GLOBAL_BIN_DIR/smarty"

    # The content of the wrapper script
    WRAPPER_CONTENT="#!/bin/bash\n\n# Smarty Vault Global Wrapper\n# Executable location (e.g., new-course.sh) relative to \$SMARTY_ROOT\n\nSCRIPT_NAME=\"\$1\"\nshift\n\n\$SMARTY_ROOT/.scripts/file-management/\$SCRIPT_NAME.sh \"\$@\""

    # Check and warn if /usr/local/bin doesn't exist or isn't writable
    if [ ! -w "$GLOBAL_BIN_DIR" ]; then
        echo "Warning: Cannot write to $GLOBAL_BIN_DIR (Need sudo/root access)."
        echo "Attempting to create global command using 'sudo'..."
        echo -e "$WRAPPER_CONTENT" | sudo tee "$WRAPPER_SCRIPT" > /dev/null
        sudo chmod +x "$WRAPPER_SCRIPT"
        echo "Please note: If a password prompt appears, it's for creating the global command."
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
echo "1. RESTART YOUR TERMINAL to load the new SMARTY_ROOT variable."
echo "2. Open Obsidian and create a new vault pointing to: $SMARTY_ROOT/04.vault/"
echo -e "3. Test your new command (from any directory):\n"
echo -e "\033[1;37msmarty new-course \"CHEM-101-Intro\"\033[0m"
echo -e "\033[1;37msmarty new-project \"Thesis-Manuscript\"\033[0m"
echo "--------------------------------------------------------------------------------"

exit 0
