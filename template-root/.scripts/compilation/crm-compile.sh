#!/bin/bash

# ==============================================================================
# crm-compile.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Compiles the CRM-DASHBOARD.md file (which contains Dataview 
#              report tables) into a formal PDF report for tracking professional 
#              networking and academic relationships.
# USAGE: smarty crm-compile [optional-report-name]
# ==============================================================================

# --- Configuration ---
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: SMARTY_ROOT variable is not set. Please run init.sh." >&2
    exit 1
fi

LATEX_ENGINE="latexmk"
VAULT_DIR="$SMARTY_ROOT/04.vault"
CRM_DASHBOARD_SOURCE="$VAULT_DIR/00.academic-network/CRM-DASHBOARD.md"
CRM_OUTPUT_DIR="$SMARTY_ROOT/00.academic-network"

# --- Functions ---

error_exit() {
    echo -e "\n\033[1;31mERROR:\033[0m $1" >&2
    exit 1
}

# --- Main Logic ---

# 1. Input and Pre-flight Check

# Set default report name or use argument
if [ -z "$1" ]; then
    REPORT_NAME="CRM-Report-$(date +%Y-%m-%d)"
else
    REPORT_NAME="$1"
fi

OUTPUT_FILE="$CRM_OUTPUT_DIR/$REPORT_NAME.pdf"

if [ ! -f "$CRM_DASHBOARD_SOURCE" ]; then
    error_exit "CRM Dashboard source file not found at: $CRM_DASHBOARD_SOURCE"
fi

# 2. Preparation
mkdir -p "$CRM_OUTPUT_DIR" || error_exit "Failed to create output directory: $CRM_OUTPUT_DIR"

echo -e "\033[0;34m--- CRM Report Compilation Initiated ---\033[0m"
echo "Source:     $CRM_DASHBOARD_SOURCE"
echo "Target:     $OUTPUT_FILE"

# 3. Execution Strategy (Simulating Data Compilation)
# CRITICAL: This workflow assumes the user opens Obsidian and triggers a Dataview
# refresh BEFORE running this script, as Pandoc only sees the static Markdown.
echo "NOTE: Ensure your Dataview plugin is active and the dashboard is up-to-date in Obsidian."

# 4. Pandoc Execution

# We use the raw Dashboard file as input. Pandoc processes the Markdown.
# Pandoc Settings: High quality, academic formatting using the custom font.
PANDOC_CMD=(
    pandoc "$CRM_DASHBOARD_SOURCE"
    --output="$OUTPUT_FILE"
    --pdf-engine="$LATEX_ENGINE"
    --toc
    -V geometry:margin=1in
    -V documentclass:article
    -V mainfont:"MesloLGS Nerd Font"
    --metadata title="Career Relationship Management Report"
)

"${PANDOC_CMD[@]}"

# 5. Result Reporting
if [ $? -eq 0 ]; then
    echo -e "\n\033[1;32mCRM Report compilation successful!\033[0m"
    echo "Report saved to: $OUTPUT_FILE"
else
    error_exit "Pandoc compilation failed. Check Pandoc/LaTeX installation and file syntax."
fi
