#!/bin/bash

line_separator() {
    echo "******************************************************"
}

analyze_directory() {
    local dirpath="$1"
    if [[ -d "$dirpath" ]]; then
        {
            echo "**** Directory Analysis Report *****"
            line_separator
            echo "Directory: $dirpath"
            echo "Analysis time: $(date)"
            line_separator
            
            echo "Number of files:"
            find "$dirpath" -type f | wc -l
            find "$dirpath" -type f
            
            line_separator

            echo "Number of subdirectories:"
            find "$dirpath" -type d | wc -l
            find "$dirpath" -type d

            line_separator

            echo "Disk usage:"
            du -sh "$dirpath"
            
            line_separator
            
            echo "Top Largest Files:"
            find "$dirpath" -type f -exec du -h {} + | sort -hr | head -n 5
            
            echo "File Type Statistics:"
            find "$dirpath" -type f | sed -n 's/..*\.//p' | sort | uniq -c | sort -nr
            
            echo "Recently Modified Files:"
            find "$dirpath" -type f -printf '%TY-%Tm-%Td %TH:%TM %p\n' | sort -r | head -n 5
            
            echo "Empty files:"
            find "$dirpath" -type f -empty

            echo "Empty directories:"
            find "$dirpath" -type d -empty

        }  # Removed all file output redirections
    else
        echo "Error: '$dirpath' is NOT a valid directory."
        echo "(It either does not exist or is not a directory)."
        return 1
    fi
}

analyze_file() {
    local filepath="$1"
    if [[ ! -e "$filepath" ]]; then
        echo "Error: File '$filepath' does not exist"
        return 1
    fi
    
    if [[ ! -f "$filepath" ]]; then
        echo "Error: '$filepath' is not a regular file"
        return 1
    fi
    
    {
        echo "**** File Analysis Report *****"
        line_separator
        echo "File: $filepath"
        echo "Analysis time: $(date)"
        line_separator
        
        # Basic metadata
        echo "BASIC METADATA:"
        line_separator
        echo "File name: $(basename "$filepath")"
        echo "Directory: $(dirname "$filepath")"
        echo "Size:      $(du -h "$filepath" | awk '{print $1}')"
        echo "File type: $(file -b "$filepath")"
        echo "MIME type: $(file --mime-type -b "$filepath")"
        echo "Permissions: $(stat -c "%A" "$filepath")"
        echo "Owner:      $(stat -c "%U" "$filepath")"
        echo "Group:      $(stat -c "%G" "$filepath")"
        echo "Modified:   $(stat -c "%y" "$filepath")"
        echo "Accessed:   $(stat -c "%x" "$filepath")"
        echo "Changed:    $(stat -c "%z" "$filepath")"
        
        line_separator

        # File extension
        filename=$(basename "$filepath")
        extension="${filename##*.}"
        if [[ "$extension" == "$filename" ]]; then
            echo "File extension: None"
        else
            echo "File extension: .$extension"
        fi

        # File format
        if file -i "$filepath" | grep -q 'charset=binary'; then
            echo "File encoding: Binary"
            is_binary=true
        else
            echo "File encoding: Text"
            is_binary=false
        fi

        line_separator

        # Content analysis for text files
        if ! $is_binary; then
            echo "CONTENT ANALYSIS:"
            line_separator
            echo "Lines:    $(wc -l < "$filepath")"
            echo "Words:    $(wc -w < "$filepath")"
            echo "Chars:    $(wc -m < "$filepath")"
            
            echo -e "\nFirst 5 lines:"
            head -n 5 "$filepath"
            
            echo -e "\nLast 5 lines:"
            tail -n 5 "$filepath"
            
            echo -e "\nWord Occurrence Count (all words):"
            tr '[:space:]' '[\n*]' < "$filepath" | grep -v "^\s*$" | sort | uniq -c | sort -nr
            
            line_separator
        else
            echo "Skipping content analysis for binary file"
        fi

        file_output=$(file -b "$filepath")
        case "$file_output" in
            *executable*) echo "- Executable binary" ;;
            *script*) echo "- Script file" ;;
            *Bourne-Again*) echo "- Bash script" ;;
            *Python*) echo "- Python script" ;;
            *Perl*) echo "- Perl script" ;;
            *Ruby*) echo "- Ruby script" ;;
            *gzip*|*zip*|*bzip2*|*compress*|*archive*) echo "- Compressed/archive file" ;;
            *image*|*bitmap*|*JPEG*|*PNG*|*GIF*) echo "- Image file" ;;
            *PDF*) echo "- PDF document" ;;
            *ASCII*|*UTF-8*) echo "- Plain text file" ;;
            *JSON*) echo "- JSON file" ;;
            *XML*) echo "- XML file" ;;
            *CSV*) echo "- CSV file" ;;
            *HTML*) echo "- HTML file" ;;
            *empty*) echo "- Empty file" ;;
            *) echo "- $file_output" ;;
        esac
    }  
}

show_help() {
    echo "Usage: $0 [OPTION] [PATH]"
    echo
    echo "Options:"
    echo "  -d, --directory PATH  Analyze directory at PATH (prints to console)"
    echo "  -f, --file PATH       Analyze file at PATH (prints to console)"
    echo "  -h, --help            Show this help message"
    echo
    echo "Examples:"
    echo "  $0 -d /path/to/directory"
    echo "  $0 -f /path/to/file.txt"
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--directory)
            if [[ -z "$2" ]]; then
                echo "Error: No directory path specified"
                exit 1
            fi
            analyze_directory "$2"
            exit 0
            ;;
        -f|--file)
            if [[ -z "$2" ]]; then
                echo "Error: No file path specified"
                exit 1
            fi
            analyze_file "$2"
            exit 0
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unknown option '$1'"
            show_help
            exit 1
            ;;
    esac
done

if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi
