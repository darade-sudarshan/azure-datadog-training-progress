# Linux Shell Scripting - Day 08-02: Bash Programming & Automation

This guide covers essential shell scripting concepts including variables, loops, functions, conditionals, and cron scheduling for automation.

## Learning Objectives

- Master bash scripting fundamentals
- Understand variables, loops, and functions
- Learn conditional statements and error handling
- Practice cron scheduling and automation
- Apply real-world scripting scenarios

---

## 1. Shell Script Basics

### Creating and Running Scripts

```bash
#!/bin/bash
# Basic script structure
echo "Hello World"
echo "Current date: $(date)"
echo "Current user: $USER"
```

```bash
# Make executable and run
chmod +x script.sh
./script.sh
```

### Shebang Lines

```bash
#!/bin/bash          # Bash shell
#!/bin/sh            # POSIX shell
#!/usr/bin/env bash  # Portable bash
```

---

## 2. Variables

### Variable Declaration and Usage

```bash
#!/bin/bash
# Variable examples
NAME="John"
AGE=25
TODAY=$(date +%Y-%m-%d)

echo "Name: $NAME"
echo "Age: ${AGE}"
echo "Today: $TODAY"
```

### Special Variables

```bash
#!/bin/bash
echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@"
echo "Number of arguments: $#"
echo "Exit status: $?"
echo "Process ID: $$"
```

### Environment Variables

```bash
#!/bin/bash
export MY_VAR="Global Variable"
echo "PATH: $PATH"
echo "HOME: $HOME"
echo "USER: $USER"
echo "Custom: $MY_VAR"
```

---

## 3. Conditional Statements

### If-Else Statements

```bash
#!/bin/bash
read -p "Enter a number: " num

if [ $num -gt 10 ]; then
    echo "Number is greater than 10"
elif [ $num -eq 10 ]; then
    echo "Number is equal to 10"
else
    echo "Number is less than 10"
fi
```

### File Testing

```bash
#!/bin/bash
FILE="/etc/passwd"

if [ -f "$FILE" ]; then
    echo "File exists"
    if [ -r "$FILE" ]; then
        echo "File is readable"
    fi
    if [ -w "$FILE" ]; then
        echo "File is writable"
    fi
fi
```

### String Comparisons

```bash
#!/bin/bash
read -p "Enter your name: " name

if [ -z "$name" ]; then
    echo "Name is empty"
elif [ "$name" = "admin" ]; then
    echo "Welcome admin"
else
    echo "Hello $name"
fi
```

---

## 4. Loops

### For Loops

```bash
#!/bin/bash
# Simple for loop
for i in 1 2 3 4 5; do
    echo "Number: $i"
done

# Range for loop
for i in {1..10}; do
    echo "Count: $i"
done

# File iteration
for file in *.txt; do
    echo "Processing: $file"
done

# Array iteration
FRUITS=("apple" "banana" "orange")
for fruit in "${FRUITS[@]}"; do
    echo "Fruit: $fruit"
done
```

### While Loops

```bash
#!/bin/bash
# Counter while loop
counter=1
while [ $counter -le 5 ]; do
    echo "Counter: $counter"
    ((counter++))
done

# Reading file line by line
while IFS= read -r line; do
    echo "Line: $line"
done < input.txt

# Infinite loop with break
while true; do
    read -p "Enter 'quit' to exit: " input
    if [ "$input" = "quit" ]; then
        break
    fi
    echo "You entered: $input"
done
```

### Until Loops

```bash
#!/bin/bash
# Until loop example
num=1
until [ $num -gt 5 ]; do
    echo "Number: $num"
    ((num++))
done
```

---

## 5. Functions

### Basic Functions

```bash
#!/bin/bash
# Function definition
greet() {
    echo "Hello $1!"
}

# Function call
greet "World"
greet "Linux"
```

### Functions with Return Values

```bash
#!/bin/bash
# Function with return value
add_numbers() {
    local num1=$1
    local num2=$2
    local result=$((num1 + num2))
    echo $result
}

# Using function
result=$(add_numbers 5 3)
echo "5 + 3 = $result"
```

### Advanced Function Example

```bash
#!/bin/bash
# File backup function
backup_file() {
    local source_file=$1
    local backup_dir=${2:-"/tmp/backup"}
    
    if [ ! -f "$source_file" ]; then
        echo "Error: Source file does not exist"
        return 1
    fi
    
    mkdir -p "$backup_dir"
    cp "$source_file" "$backup_dir/$(basename $source_file).$(date +%Y%m%d_%H%M%S)"
    echo "Backup created successfully"
    return 0
}

# Usage
backup_file "/etc/passwd" "/home/user/backups"
```

---

## 6. Arrays

### Indexed Arrays

```bash
#!/bin/bash
# Array declaration
COLORS=("red" "green" "blue")
NUMBERS=(1 2 3 4 5)

# Array access
echo "First color: ${COLORS[0]}"
echo "All colors: ${COLORS[@]}"
echo "Array length: ${#COLORS[@]}"

# Adding elements
COLORS+=("yellow")
echo "Updated colors: ${COLORS[@]}"
```

### Associative Arrays

```bash
#!/bin/bash
# Declare associative array
declare -A PERSON
PERSON[name]="John"
PERSON[age]=30
PERSON[city]="New York"

# Access elements
echo "Name: ${PERSON[name]}"
echo "Age: ${PERSON[age]}"

# Iterate over keys
for key in "${!PERSON[@]}"; do
    echo "$key: ${PERSON[$key]}"
done
```

---

## 7. Input/Output and File Operations

### Reading User Input

```bash
#!/bin/bash
# Simple input
read -p "Enter your name: " name
echo "Hello $name"

# Silent input (passwords)
read -s -p "Enter password: " password
echo -e "\nPassword entered"

# Input with timeout
if read -t 5 -p "Enter something (5 sec timeout): " input; then
    echo "You entered: $input"
else
    echo "Timeout reached"
fi
```

### File Operations

```bash
#!/bin/bash
# Writing to files
echo "Log entry: $(date)" >> logfile.txt

# Reading from files
while IFS= read -r line; do
    echo "Processing: $line"
done < input.txt

# File existence check
if [ -f "config.txt" ]; then
    source config.txt
else
    echo "Config file not found"
fi
```

---

## 8. Error Handling

### Exit Codes and Error Checking

```bash
#!/bin/bash
# Function with error handling
safe_copy() {
    local source=$1
    local dest=$2
    
    if [ $# -ne 2 ]; then
        echo "Usage: safe_copy <source> <destination>"
        return 1
    fi
    
    if [ ! -f "$source" ]; then
        echo "Error: Source file '$source' not found"
        return 2
    fi
    
    if cp "$source" "$dest"; then
        echo "File copied successfully"
        return 0
    else
        echo "Error: Failed to copy file"
        return 3
    fi
}

# Usage with error checking
if safe_copy "file1.txt" "file2.txt"; then
    echo "Operation successful"
else
    echo "Operation failed with code: $?"
fi
```

### Trap for Cleanup

```bash
#!/bin/bash
# Cleanup function
cleanup() {
    echo "Cleaning up temporary files..."
    rm -f /tmp/script_temp_*
    exit
}

# Set trap
trap cleanup EXIT INT TERM

# Script logic
echo "Creating temporary files..."
touch /tmp/script_temp_$$
sleep 10
```

---

## 9. Practical Script Examples

### System Information Script

```bash
#!/bin/bash
# System information gathering
echo "=== System Information ==="
echo "Hostname: $(hostname)"
echo "OS: $(uname -s)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Memory: $(free -h | awk 'NR==2{print $3"/"$2}')"
echo "Disk Usage: $(df -h / | awk 'NR==2{print $5}')"
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
```

### Log Rotation Script

```bash
#!/bin/bash
# Log rotation script
LOG_DIR="/var/log/myapp"
MAX_SIZE=10485760  # 10MB in bytes
BACKUP_COUNT=5

rotate_log() {
    local logfile=$1
    
    if [ ! -f "$logfile" ]; then
        return 0
    fi
    
    local size=$(stat -f%z "$logfile" 2>/dev/null || stat -c%s "$logfile")
    
    if [ $size -gt $MAX_SIZE ]; then
        echo "Rotating $logfile (size: $size bytes)"
        
        # Rotate existing backups
        for i in $(seq $((BACKUP_COUNT-1)) -1 1); do
            if [ -f "${logfile}.$i" ]; then
                mv "${logfile}.$i" "${logfile}.$((i+1))"
            fi
        done
        
        # Create new backup
        mv "$logfile" "${logfile}.1"
        touch "$logfile"
        echo "Log rotated successfully"
    fi
}

# Rotate all log files
for logfile in "$LOG_DIR"/*.log; do
    rotate_log "$logfile"
done
```

### Backup Script

```bash
#!/bin/bash
# Automated backup script
SOURCE_DIR="/home/user/documents"
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_$DATE.tar.gz"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Create backup
echo "Starting backup of $SOURCE_DIR..."
if tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$(dirname $SOURCE_DIR)" "$(basename $SOURCE_DIR)"; then
    echo "Backup created: $BACKUP_DIR/$BACKUP_NAME"
    
    # Remove old backups (keep last 7)
    cd "$BACKUP_DIR"
    ls -t backup_*.tar.gz | tail -n +8 | xargs -r rm
    echo "Old backups cleaned up"
else
    echo "Backup failed!"
    exit 1
fi
```

---

## 10. Cron Scheduling

### Cron Syntax

```
# Minute Hour Day Month DayOfWeek Command
# (0-59) (0-23) (1-31) (1-12) (0-7)

# Examples:
0 2 * * *           # Daily at 2:00 AM
30 14 * * 1-5       # Weekdays at 2:30 PM
0 0 1 * *           # First day of every month
*/15 * * * *        # Every 15 minutes
0 */6 * * *         # Every 6 hours
```

### Cron Management

```bash
# View current crontab
crontab -l

# Edit crontab
crontab -e

# Remove crontab
crontab -r

# Install crontab from file
crontab mycron.txt
```

### Cron Examples

```bash
# Example crontab entries
# Backup daily at 2 AM
0 2 * * * /home/user/scripts/backup.sh >> /var/log/backup.log 2>&1

# System cleanup weekly
0 3 * * 0 /home/user/scripts/cleanup.sh

# Check disk space every hour
0 * * * * df -h | mail -s "Disk Space Report" admin@example.com

# Log rotation daily
0 1 * * * /home/user/scripts/rotate_logs.sh

# Database backup every 6 hours
0 */6 * * * /home/user/scripts/db_backup.sh
```

### Cron Script Template

```bash
#!/bin/bash
# Cron-friendly script template

# Set PATH for cron environment
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /var/log/myscript.log
}

# Main script logic
main() {
    log "Script started"
    
    # Your script logic here
    if command_that_might_fail; then
        log "Command succeeded"
    else
        log "Command failed with exit code $?"
        exit 1
    fi
    
    log "Script completed successfully"
}

# Run main function
main "$@"
```

---

## 11. Command Reference

### Script Execution

| Command | Purpose | Example |
|---------|---------|---------|
| `chmod +x` | Make script executable | `chmod +x script.sh` |
| `./script.sh` | Run script | `./script.sh arg1 arg2` |
| `bash script.sh` | Run with bash | `bash -x script.sh` |
| `source script.sh` | Execute in current shell | `source config.sh` |

### Variable Operations

| Operation | Purpose | Example |
|-----------|---------|---------|
| `VAR=value` | Assign variable | `NAME="John"` |
| `$VAR` | Access variable | `echo $NAME` |
| `${VAR}` | Variable expansion | `echo ${NAME}` |
| `export VAR` | Environment variable | `export PATH=$PATH:/new/path` |

### Conditional Tests

| Test | Purpose | Example |
|------|---------|---------|
| `-f file` | File exists | `[ -f "/etc/passwd" ]` |
| `-d dir` | Directory exists | `[ -d "/tmp" ]` |
| `-r file` | File readable | `[ -r "file.txt" ]` |
| `-w file` | File writable | `[ -w "file.txt" ]` |
| `-z string` | String empty | `[ -z "$var" ]` |
| `-n string` | String not empty | `[ -n "$var" ]` |

### Cron Time Fields

| Field | Values | Special |
|-------|--------|---------|
| Minute | 0-59 | `*/5` (every 5 min) |
| Hour | 0-23 | `*/2` (every 2 hours) |
| Day | 1-31 | `1,15` (1st and 15th) |
| Month | 1-12 | `1-6` (Jan to Jun) |
| DayOfWeek | 0-7 | `1-5` (Mon to Fri) |

---

## 12. Best Practices

### Script Structure
- Always use `#!/bin/bash` shebang
- Use meaningful variable names
- Quote variables to prevent word splitting
- Check command exit codes
- Use functions for repeated code

### Error Handling
- Use `set -e` to exit on errors
- Use `set -u` to catch undefined variables
- Implement proper logging
- Use trap for cleanup
- Validate input parameters

### Cron Best Practices
- Use absolute paths in cron scripts
- Set PATH variable in scripts
- Redirect output to log files
- Test scripts before scheduling
- Use locking to prevent overlapping runs

---

## 13. Debugging

### Debug Options

```bash
#!/bin/bash
set -x          # Print commands before execution
set -e          # Exit on error
set -u          # Exit on undefined variable
set -o pipefail # Exit on pipe failure

# Or combine: set -euxo pipefail
```

### Debug Techniques

```bash
#!/bin/bash
# Debug function
debug() {
    if [ "$DEBUG" = "1" ]; then
        echo "DEBUG: $1" >&2
    fi
}

# Usage
DEBUG=1
debug "Starting process"
```

---

## Summary

This session covered comprehensive shell scripting including:
- **Script Basics**: Structure, variables, and execution
- **Control Flow**: Conditionals, loops, and functions
- **Advanced Features**: Arrays, error handling, and I/O
- **Automation**: Cron scheduling and practical examples
- **Best Practices**: Debugging, error handling, and maintenance

These skills enable powerful automation and system administration through shell scripting.