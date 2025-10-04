#!/bin/bash

# ==============================================================================
# pandoc-compile.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Compiles a Markdown (.md) or LaTeX (.tex) file. If only a 
#              filename is provided, it uses fzf to search the 04.vault folder 
#              and prompt the user to select the correct file.
# USAGE: smarty pandoc-compile [full/path/to/file.md | short-filename]
# ==============================================================================

# --- Configuration ---
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: SMARTY_ROOT variable is not set. Please run init.sh." >&2
    exit 1
fi

LATEX_ENGINE="mklatex"
VAULT_SOURCE_DIR="$SMARTY_ROOT/04.vault"
ACCEPTED_EXTENSIONS="md,tex" # For FZF filtering

# --- Functions ---

error_exit() {
    echo -e "\n\033[1;31mERROR:\033[0m $1" >&2
    exit 1
}

# --- Main Logic ---

# 1. Input Handling and File Resolution
if [ -z "$1" ]; then
    error_exit "Usage: smarty pandoc-compile <filename or path>"
fi

INPUT_ARG="$1"

# Case A: Argument is a valid file path (absolute or relative)
if [ -f "$INPUT_ARG" ]; then
    INPUT_FILE="$INPUT_ARG"

# Case B: Argument is a short name/pattern, requires fuzzy search
else
    echo -e "\033[0;34mSearching vault for files matching: '$INPUT_ARG'...\033[0m"
    
    # Use find to list all MD and TeX files in the vault and pipe to fzf.
    # fzf is initialized with the user's input as the starting query.
    # -i: case-insensitive search
    # -e: use exact matching on the initial query
    # --bind: allows user to press CTRL-C to cancel without error
    
    # The 'find' command strips the vault path for cleaner display in fzf
    # The 'sed' part filters file extensions
    
    SELECTED_FILE=$(
        find "$VAULT_SOURCE_DIR" -type f \( -name "*.md" -o -name "*.tex" \) 2>/dev/null | 
        sed "s|$VAULT_SOURCE_DIR/||g" |
        fzf --height 10 --ansi -e -i --query "$INPUT_ARG" \
            --prompt="COMPILE > " \
            --header="Select the file to compile (or ESC to cancel):" \
            --bind "ctrl-c:execute(exit 1)"
    )

    if [ -z "$SELECTED_FILE" ]; then
        echo -e "\033[0;33mCompilation cancelled or no file selected.\033[0m"
        exit 0
    fi
    
    # Reconstruct the full absolute path
    INPUT_FILE="$VAULT_SOURCE_DIR/$SELECTED_FILE"

fi

# 2. Final Validation
if [ ! -f "$INPUT_FILE" ]; then
    error_exit "Final file resolution failed for: $INPUT_FILE"
fi

FILE_EXT="${INPUT_FILE##*.}"
BASE_NAME="$(basename "$INPUT_FILE" ."$FILE_EXT")"

if [[ "$FILE_EXT" != "md" ]] && [[ "$FILE_EXT" != "tex" ]]; then
    error_exit "File extension .$FILE_EXT is not supported."
fi

# 3. Determine Output Path (The 1:1 Mapping Logic)

# Get the path relative to the vault source directory
RELATIVE_PATH_IN_VAULT="${INPUT_FILE#$VAULT_SOURCE_DIR/}"

# Construct the output path by stripping '04.vault/' from the SMARTY_ROOT path.
OUTPUT_PATH="$SMARTY_ROOT/$RELATIVE_PATH_IN_VAULT"

# Replace the file extension (.md or .tex) with .pdf
OUTPUT_FILE="${OUTPUT_PATH%.*}.pdf"
OUTPUT_DIR="$(dirname "$OUTPUT_FILE")"


# 4. Preparation and Execution
mkdir -p "$OUTPUT_DIR" || error_exit "Failed to create output directory: $OUTPUT_DIR"

echo -e "\033[0;34m--- Pandoc Compilation Initiated ---\033[0m"
echo "Source File:  $INPUT_FILE"
echo "Target File:  $OUTPUT_FILE"

PANDOC_CMD=(
    pandoc "$INPUT_FILE"
    --output="$OUTPUT_FILE"
    --pdf-engine="$LATEX_ENGINE"
    --toc
    -V geometry:margin=1in
    -V documentclass:article
    -V mainfont:"MesloLGS Nerd Font"
)

"${PANDOC_CMD[@]}"

# 5. Result Reporting
if [ $? -eq 0 ]; then
    echo -e "\n\033[1;32mCompilation successful! PDF saved.\033[0m"
else
    error_exit "Pandoc compilation failed. Check Pandoc/LaTeX installation and file syntax."
fi
