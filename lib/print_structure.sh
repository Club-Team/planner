#!/bin/bash

# Check if the 'tree' command is available
if ! command -v tree &> /dev/null
then
    echo "Error: 'tree' command not found. Please install it (e.g., 'brew install tree' on macOS)."
    exit 1
fi

# Define the folder to start from. 
# If an argument is provided, use it. Otherwise, use the current directory.
START_DIR="${1:-.}"

# Define the directories to ignore (bin and obj)
IGNORE_DIRS="bin|obj|.DS_Store|.git"

# Use the tree command to print the structure
# -a: All files are listed (though -I will handle exclusions)
# -I: Pattern for files/directories to ignore.
# -d: List directories only (optional, remove this if you want files too)
# The output is piped to 'less' for easy viewing if the structure is large.
echo "--- Folder Structure for '$START_DIR' (Ignoring 'bin' and 'obj') ---"
tree -a -I "$IGNORE_DIRS" "$START_DIR"
# You can use the following if you want to include files:
# tree -a -I "$IGNORE_DIRS" "$START_DIR"