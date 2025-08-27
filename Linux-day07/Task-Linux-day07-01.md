# Linux Fundamentals - Day 07: Command Line Mastery and File Operations

This guide covers essential Linux command line operations, file manipulation, text processing, and system navigation techniques based on practical hands-on exercises.

## Learning Objectives

By the end of this session, you will be able to:
- Navigate the Linux file system efficiently
- Use essential command line utilities
- Perform file operations and text processing
- Understand input/output redirection and pipes
- Work with file patterns and wildcards
- Use find and locate commands for file searching

## Prerequisites

- Basic understanding of Linux operating system
- Access to a Linux terminal or command line interface
- Familiarity with basic file system concepts

---

## Session Overview

### Topics Covered
1. **Environment Variables and PATH**
2. **Command Location and Manual Pages**
3. **Date and Calendar Commands**
4. **Input/Output Redirection**
5. **Pipes and Text Processing**
6. **File Operations and Navigation**
7. **Pattern Matching and Wildcards**
8. **File Searching with find and locate**
9. **Bash Aliases and Customization**

---

## 1. Environment Variables and PATH

### Understanding PATH Variable

The PATH environment variable contains directories where the shell looks for executable commands.

```bash
# Display current PATH
echo $PATH

# Find location of commands
which cal
which cat
which echo
which which
```

**Output Example:**
```
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
```

### Key Commands Covered:
- `echo $PATH` - Display PATH variable
- `which <command>` - Show command location

---

## 2. Calendar and Date Operations

### Calendar Commands

```bash
# Display current month calendar
cal

# Display specific year calendar
cal 2025

# Display specific month and year
cal 10 2025

# Display calendar with context (before/after months)
cal -A 1 12 2025    # Show 1 month after December 2025
cal -A 1 -B 1 2025  # Show 1 month before and after current month
```

### Date Commands

```bash
# Display current date and time
date

# Display UTC time
date -u
```

---

## 3. Manual Pages and Help System

### Using Manual Pages

```bash
# Search for commands related to a topic
man -k which
man -k "list directory content"

# View manual page for a command
man ls
man pwd
man which
```

### Getting Help

```bash
# Most commands support --help option
pwd --help
```

---

## 4. Input/Output Redirection

### Standard Output Redirection

```bash
# Redirect output to file (overwrite)
cat > abc.txt
# Type content and press Ctrl+D to save

# Append output to file
cat >> abc.txt

# Redirect output using explicit file descriptor
cat 1> abc.txt
cat 1>> abc.txt
```

### Standard Error Redirection

```bash
# Redirect error output to file
cat -k blah 2> error.txt

# Append error output to file
cat -k blah 2>> error.txt

# Redirect both stdout and stderr
cat -k blah 1>> abc.txt 2>> error.txt
```

### Standard Input Redirection

```bash
# Create input file
cat > input.txt
# Type content and press Ctrl+D

# Use file as input
cat < input.txt
cat 0< input.txt

# Redirect input and append to another file
cat < input.txt >> abc.txt
```

---

## 5. Pipes and Text Processing

### Basic Pipe Operations

```bash
# Save date to file
date > date.txt

# Extract specific fields using cut
cut < date.txt -d " " -f 1    # Extract first field
date | cut -d " " -f 1        # Extract day of week
date | cut -d " " -f 2        # Extract month
date | cut -d " " -f 5        # Extract time
date | cut -d " " -f 5 > time.txt
```

### Using tee Command

```bash
# Save output to file and display on screen
date | tee fulldate.txt | cut -d " " -f 5
date | tee fulldate.txt | cut -d " " -f 2 > date.txt
```

### Using xargs Command

```bash
# Process command output as arguments
date | xargs echo
date | xargs echo "hello"
date | xargs echo "hello today is "
```

---

## 6. File Operations and Navigation

### Directory Listing

```bash
# List files in home directory
ls -l ~
ls -la ~

# List with file type indicators
ls -F
ls -F /
ls -F / > list.txt

# List with human-readable sizes
ls -lh
```

### File Information

```bash
# Determine file type
file file1.txt
file Section+2+Command+Cheat+Sheet.pdf
```

---

## 7. Pattern Matching and Wildcards

### Basic Wildcards

```bash
# List all files
ls *

# List files with specific extension
ls *.txt

# List files starting with specific pattern
ls file*.txt

# Single character wildcard
ls file?.txt
```

### Character Classes

```bash
# Create test files
touch file[123].txt
touch fileA.txt fileB.txt fileC.txt

# Match character ranges
ls file[0-9ABC].txt
```

### Brace Expansion

```bash
# Create directory structure
mkdir -p linux-practice/{jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec}_{2020,2021,2024,2025}

# Create files with patterns
touch linux-practice/{jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec}_{2020,2021,2024,2025}/file{1..5}.txt

# List created structure
ls linux-practice/jan_2025
```

---

## 8. File and Directory Management

### Copying and Moving Files

```bash
# Copy files to directory
cp file*.txt linux-practice/

# Move files
mv linux-practice/file?.txt .

# Rename files
mv linux-practice/file_dir.txt linux-practice/file_directory.txt
```

### Directory Operations

```bash
# Create directories
mkdir linux-practice

# Remove empty directories
rmdir linux-practice/{jan,feb,mar,apr,may,jun,jul,aug,sep,oct,dec}_{2020,2021,2024,2025}

# Remove directories and contents (interactive)
rm -ri linux-practice/*
```

---

## 9. File Searching

### Using locate Command

```bash
# Update locate database
sudo updatedb

# Search for files
locate file_directory.txt
locate nginx*
locate hostname

# Case-insensitive search with limit
locate -i *.CONF -l 10

# Search existing files only
locate -e *.conf -l 20

# Display locate database statistics
locate -S
```

### Using find Command

#### Basic find Operations

```bash
# Find in current directory
find .

# Find in specific directory
find /var
find /home/einfochips/Desktop/
find linux-practice/

# Find with depth limit
find /etc/ -maxdepth 1
find /etc/ -maxdepth 2
```

#### Find by Type

```bash
# Find files only
find /etc/ -maxdepth 2 -type f

# Find directories only
find /etc/ -maxdepth 2 -type d
```

#### Find by Name

```bash
# Find by exact name
find . -name "file*.txt"

# Case-insensitive name search
find . -iname "file*.txt"
```

#### Find by Size

```bash
# Find large files
find / -type f -size +100M

# Count large files
sudo find / -type f -size +100M | wc -l

# Find files in size range
sudo find / -type f -size +100M -size -5M
```

#### Advanced find with exec

```bash
# Create complex directory structure for testing
mkdir -p linux-practice/haystack/folder{1..300}
touch linux-practice/haystack/folder{1..300}/file{1..100}

# Create a needle file in random location
touch linux-practice/haystack/folder$(shuf -i 1-300 -n 1)/needle.txt

# Find and move the needle file
find linux-practice/haystack/ -type f -name "needle.txt" -exec mv {} ~/Desktop \;
```

---

## 10. Bash Aliases and Customization

### Creating Aliases

```bash
# Edit bash aliases file
nano ~/.bash_aliases

# Example alias content:
# alias ll='ls -la'
# alias getdates='date'
# alias vpn='echo "globalprotect launch-ui"'

# Test aliases after creating
ll
getdates
vpn
```

---

## Practical Exercises

### Exercise 1: File Organization
Create a directory structure for organizing files by year and month, then populate it with sample files.

```bash
mkdir -p practice/{2023,2024,2025}/{jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec}
touch practice/2024/jan/report{1..5}.txt
touch practice/2024/feb/data{A..E}.csv
```

### Exercise 2: Text Processing Pipeline
Create a pipeline that processes system information and saves it to organized files.

```bash
# Create system info files
ls /etc/ > system_etc.txt
ls /var/ > system_var.txt

# Combine and process
cat system_etc.txt system_var.txt | sort | uniq > combined_system.txt
```

### Exercise 3: File Search Challenge
Find all configuration files in the system and create a report.

```bash
# Find all .conf files
find /etc -name "*.conf" -type f 2>/dev/null > config_files.txt

# Count configuration files
wc -l config_files.txt
```

---

## Command Reference Summary

### Essential Commands Used

| Command | Purpose | Example |
|---------|---------|---------|
| `echo $PATH` | Display PATH variable | `echo $PATH` |
| `which` | Find command location | `which ls` |
| `cal` | Display calendar | `cal 2025` |
| `date` | Display date/time | `date` |
| `man` | Manual pages | `man ls` |
| `cat` | Display/create files | `cat file.txt` |
| `cut` | Extract fields | `cut -d" " -f1` |
| `tee` | Split output | `date \| tee file.txt` |
| `find` | Search files | `find . -name "*.txt"` |
| `locate` | Quick file search | `locate filename` |
| `ls` | List directory contents | `ls -la` |
| `cp` | Copy files | `cp file1 file2` |
| `mv` | Move/rename files | `mv old new` |
| `mkdir` | Create directories | `mkdir dirname` |
| `rmdir` | Remove empty directories | `rmdir dirname` |

### Redirection Operators

| Operator | Purpose | Example |
|----------|---------|---------|
| `>` | Redirect stdout (overwrite) | `ls > file.txt` |
| `>>` | Redirect stdout (append) | `ls >> file.txt` |
| `2>` | Redirect stderr | `cmd 2> error.txt` |
| `2>>` | Redirect stderr (append) | `cmd 2>> error.txt` |
| `<` | Redirect stdin | `cmd < input.txt` |
| `\|` | Pipe output | `cmd1 \| cmd2` |

### Wildcards and Patterns

| Pattern | Matches | Example |
|---------|---------|---------|
| `*` | Any characters | `*.txt` |
| `?` | Single character | `file?.txt` |
| `[abc]` | Any of a, b, c | `file[123].txt` |
| `[a-z]` | Range a to z | `file[a-z].txt` |
| `{a,b,c}` | Brace expansion | `file{1,2,3}.txt` |

---

## Best Practices

1. **Use Tab Completion**: Press Tab to auto-complete commands and file names
2. **Read Manual Pages**: Use `man command` to understand command options
3. **Test Commands Safely**: Use `echo` to preview commands before execution
4. **Organize Files**: Create logical directory structures
5. **Use Descriptive Names**: Choose clear, meaningful file and directory names
6. **Regular Backups**: Always backup important files before major operations
7. **Learn Keyboard Shortcuts**: Master Ctrl+C, Ctrl+D, Ctrl+Z for process control

---

## Troubleshooting Common Issues

### Permission Denied Errors
```bash
# Use sudo for system directories
sudo find /var -name "*.log"

# Check file permissions
ls -la filename
```

### Command Not Found
```bash
# Check if command exists
which commandname

# Update PATH if needed
export PATH=$PATH:/new/directory
```

### File Not Found
```bash
# Use absolute paths
find /full/path/to/directory -name "filename"

# Check current directory
pwd
```

---

## Next Steps

After mastering these fundamentals, you should explore:
- Advanced text processing with `sed` and `awk`
- Shell scripting and automation
- Process management and system monitoring
- Network commands and troubleshooting
- Package management and software installation

---

## Summary

This session covered essential Linux command line skills including:
- Environment variables and command location
- File operations and navigation
- Input/output redirection and pipes
- Pattern matching and wildcards
- File searching techniques
- Basic system customization

These skills form the foundation for effective Linux system administration and daily command line usage.