#!/bin/bash

# ==============================================================================
# view.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Uses fzf to interactively find and open a compiled PDF file 
#              (assignments, notes, papers) in the Zathura viewer.
# USAGE: smarty view [optional-search-term]
# ==============================================================================

# --- Configuration ---
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: The SMARTY_ROOT environment variable is not set. Please run init.sh." >&2
    exit 1
fi

# Define the primary directories to search for compiled files (PDFs)
SEARCH_DIRS=(
    "$SMARTY_ROOT/01.courses"
    "$SMARTY_ROOT/02.engagements-projects"
    "$SMARTY_ROOT/03.research-exploration"
    "$SMARTY_ROOT/00.academic-network"
)

# --- Functions ---

error_exit() {
    echo -e "\n\033[1;31mERROR:\033[0m $1" >&2
    exit 1
}

# --- Main Logic ---

SEARCH_TERM="$1"

echo -e "\033[0;34mSearching compiled documents for: '$SEARCH_TERM'...\033[0m"

# 1. Search for PDF files and pipe the relative paths to fzf
# find command: Search the defined directories for '.pdf' files.
# sed command: Clean the paths so fzf displays paths relative to $SMARTY_ROOT.
# fzf options: 
#   --query "$SEARCH_TERM": starts the fuzzy search with the argument provided.
#   --preview 'zathura "{}"': Previews the PDF directly in a simple terminal window (if fzf supports it).
#   --header: provides instructions.
SELECTED_RELATIVE_PATH=$(
    find "${SEARCH_DIRS[@]}" -type f -name "*.pdf" 2>/dev/null |
    sed "s|^$SMARTY_ROOT/||" |
    fzf --height 40% --ansi -i --query "$SEARCH_TERM" \
        --prompt="VIEW PDF > " \
        --header="Select document to open in Zathura (ESC to cancel):" \
        --bind "ctrl-c:execute(exit 1)"
)

if [ -z "$SELECTED_RELATIVE_PATH" ]; then
    echo -e "\033[0;33mViewing cancelled or no PDF selected.\033[0m"
    exit 0
fi

# 2. Reconstruct the full absolute path for execution
FULL_PATH="$SMARTY_ROOT/$SELECTED_RELATIVE_PATH"

if [ ! -f "$FULL_PATH" ]; then
    error_exit "Resolved file path not found: $FULL_PATH"
fi

# 3. Launch Zathura in the background
echo "Opening Zathura: $FULL_PATH"

# Use exec to launch Zathura directly, replacing the current shell process,
# or use 'nohup' and '&' if your environment doesn't correctly detach exec.
# Since you used 'zathura ... & disown' previously, we'll use that reliable method:
zathura "$FULL_PATH" > /dev/null 2>&1 &
disown

echo -e "\033[1;32mDocument opened successfully in Zathura.\033[0m"
