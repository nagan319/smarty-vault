#!/bin/bash

# ==============================================================================
# pandoc-compile.sh
# ------------------------------------------------------------------------------
# DESCRIPTION: Compiles a Markdown (.md) or LaTeX (.tex) file located anywhere
#              within the SMARTY_ROOT structure and places the compiled PDF in
#              the *corresponding* location, outside the 04.vault folder.
# USAGE: smarty pandoc-compile <path/to/source_file>
# ==============================================================================

# --- Configuration ---
if [ -z "$SMARTY_ROOT" ]; then
    echo "ERROR: SMARTY_ROOT variable is not set. Please run init.sh." >&2
    exit 1
fi

LATEX_ENGINE="latexmk"
VAULT_SOURCE_DIR="$SMARTY_ROOT/04.vault"

# --- Functions ---

error_exit() {
    echo -e "\n\033[1;31mERROR:\033[0m $1" >&2
    exit 1
}

# --- Main Logic ---

# 1. Input Validation
if [ -z "$1" ]; then
    error_exit "Usage: smarty pandoc-compile <path/to/source_file>"
fi

INPUT_FILE="$1"

if [ ! -f "$INPUT_FILE" ]; then
    error_exit "Input file not found at: $INPUT_FILE"
fi

# 2. Determine File Type and Base Name
FILE_EXT="${INPUT_FILE##*.}"
BASE_NAME="$(basename "$INPUT_FILE" ."$FILE_EXT")"

if [[ "$FILE_EXT" != "md" ]] && [[ "$FILE_EXT" != "tex" ]]; then
    error_exit "Unsupported file type: .$FILE_EXT. Only .md or .tex files are supported."
fi

# 3. Determine Output Path (The Correct 1:1 Mapping Logic)

# A. Get the part of the path *after* the SMARTY_ROOT/04.vault/ prefix
if [[ "$INPUT_FILE" == "$VAULT_SOURCE_DIR"* ]]; then
    # Calculate the path relative to the VAULT_SOURCE_DIR
    RELATIVE_PATH_IN_VAULT="${INPUT_FILE#$VAULT_SOURCE_DIR/}"
    
    # B. Construct the OUTPUT path by stripping '04.vault/' from the $SMARTY_ROOT path.
    #    Example: If source is .../04.vault/01.courses/CourseA/file.md
    #    We strip '04.vault/' and prepended it back to $SMARTY_ROOT
    OUTPUT_PATH="$SMARTY_ROOT/$RELATIVE_PATH_IN_VAULT"
    
    # C. Replace the file extension (.md or .tex) with .pdf
    OUTPUT_FILE="${OUTPUT_PATH%.*}.pdf"
    
    # D. Define the directory where the PDF will be saved
    OUTPUT_DIR="$(dirname "$OUTPUT_FILE")"

else
    # If the file is already outside the vault, just output the PDF next to the source
    OUTPUT_DIR="$(dirname "$INPUT_FILE")"
    OUTPUT_FILE="$OUTPUT_DIR/$BASE_NAME.pdf"
fi

# 4. Preparation and Directory Creation
mkdir -p "$OUTPUT_DIR" || error_exit "Failed to create output directory: $OUTPUT_DIR"

echo -e "\033[0;34m--- Pandoc Compilation Initiated ---\033[0m"
echo "Source File:  $INPUT_FILE"
echo "Output File:  $OUTPUT_FILE"

# 5. Pandoc Execution (Academic Formatting)
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

# 6. Result Reporting
if [ $? -eq 0 ]; then
    echo -e "\n\033[1;32mCompilation successful! PDF saved.\033[0m"
else
    error_exit "Pandoc compilation failed. Check Pandoc/LaTeX installation and file syntax."
fi
