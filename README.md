# File/Directory Analysis Tool

A powerful Bash script for comprehensive analysis of files and directories.

## Features

- **Directory Analysis:**
  - File/subdirectory counts
  - Disk usage
  - Largest files
  - File type statistics
  - Recently modified files
  - Empty files/directories

- **File Analysis:**
  - Metadata (size, permissions, timestamps)
  - Content analysis (text files)
  - File type detection
  - Encoding detection

** Options **
Flag	Description
-d	Analyze directory
-f	Analyze file
-h	Show help

** Usage **

Usage: ./analyze.sh [OPTION] [PATH]

Options:
  -d, --directory PATH  Analyze directory at PATH (prints to console)
  -f, --file PATH       Analyze file at PATH (prints to console)
  -h, --help            Show this help message

Examples:
  ./analyze.sh -d /path/to/directory
  ./analyze.sh -f /path/to/file.txt
