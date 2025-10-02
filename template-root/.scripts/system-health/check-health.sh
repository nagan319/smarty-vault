#!/bin/bash

# ==============================================================================
# check-health.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Diagnoses the Smarty Vault system environment. Verifies the
#              SMARTY_ROOT variable, checks for Pandoc and Obsidian installation,
#              and confirms directory integrity.
#
# USAGE: smarty check-health
# ==============================================================================

# --- Configuration ---
# Define the required binaries and directory checks
REQUIRED_BINS=("pandoc" "git")
REQUIRED_DIRS=("01.courses" "04.vault/00.academic-network")

# --- Functions ---

# Function to display error messages and exit
error_exit() {
    echo -e "\nERROR: $1" >&2
    exit 1
}

# Function to check for required binary presence
check_binary() {
    if command -v "$1" &> /dev/null; then
        echo "✅ FOUND: $1 ($(command -v "$1"))"
        return 0
    else
        echo "❌ MISSING: $1 (Not found in system PATH)"
        return 1
    fi
}

# --- Main Execution ---

echo "--- Smarty Vault System Health Check ---"
OVERALL_STATUS=0

## 1. Environment Variable Check
echo -e "\n[1. Environment Variable (SMARTY_ROOT)]"
if [ -z "$SMARTY_ROOT" ]; then
    echo "❌ FAILED: SMARTY_ROOT is not set."
    echo "   Action: Ensure you ran 'init.sh' and restarted your terminal."
    OVERALL_STATUS=1
else
    echo "✅ SET: $SMARTY_ROOT"
    
    ## 2. Directory Integrity Check (only if SMARTY_ROOT is set)
    echo -e "\n[2. Core Directory Integrity]"
    for dir in "${REQUIRED_DIRS[@]}"; do
        FULL_PATH="$SMARTY_ROOT/$dir"
        if [ -d "$FULL_PATH" ]; then
            echo "✅ FOUND: $dir"
        else
            echo "❌ MISSING: $dir (Path: $FULL_PATH)"
            echo "   Action: The core structure is broken. Restore or reinstall the vault."
            OVERALL_STATUS=1
        fi
    done
fi

## 3. Dependency Check
echo -e "\n[3. External Dependencies]"
for bin in "${REQUIRED_BINS[@]}"; do
    check_binary "$bin" || OVERALL_STATUS=1
done

# Note: We check for Pandoc because it's required for compilation.
# Git is useful but optional for core operation. Obsidian is assumed to be installed 
# and running, as it often isn't in the system PATH.

## 4. Final Status Report
echo -e "\n--- Health Check Complete ---"
if [ $OVERALL_STATUS -eq 0 ]; then
    echo -e "✅ STATUS: All critical components are healthy and ready."
    echo "Run 'smarty new-course <name>' to continue your workflow."
else
    echo -e "❌ STATUS: One or more critical dependencies failed or paths are broken."
    echo "Please review the errors above and take corrective action."
fi

exit $OVERALL_STATUS
