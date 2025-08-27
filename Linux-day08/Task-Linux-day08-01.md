# Linux Advanced Operations - Day 08-01: File Operations, Text Processing & Archive Management

This guide covers advanced Linux file operations, text processing commands, and archive management based on practical command-line exercises.

## Learning Objectives

- Master file creation and manipulation techniques
- Understand text processing and viewing commands
- Learn sorting and filtering operations
- Practice archive creation and compression
- Apply real-world file management scenarios

---

## 1. Directory and File Creation

### Basic Directory Operations

```bash
# Create directory
mkdir linux_practice

# Rename directory
mv linux_practice/ linux_practise

# Create multiple files with brace expansion
touch linux_practise/file{1..5}.txt
```

**Purpose**: Organize files systematically using pattern-based creation.

---

## 2. File Content Operations

### Writing Content to Files

```bash
# Write content to files
echo hello > linux_practise/file1.txt
echo there > linux_practise/file2.txt
echo we > linux_practise/file3.txt
echo "are learning" > linux_practise/file4.txt

# View file content
cat linux_practise/file1.txt
cat linux_practise/file4.txt
```

### Combining Files

```bash
# Combine multiple files using pattern matching
cat linux_practise/file[1-5].txt > combined.txt

# View combined content
cat combined.txt
```

**Output**:
```
hello
there
we
are learning
```

---

## 3. Text Processing Commands

### Reverse Operations

```bash
# Reverse line order (last line first)
tac combined.txt

# Reverse character order in each line
rev combined.txt
```

**tac Output**:
```
are learning
we
there
hello
```

**rev Output**:
```
olleh
ereht
ew
gninrael era
```

---

## 4. File Viewing Commands

### Pager Commands

```bash
# View file with less (interactive)
less /etc/cups/cups-browsed.conf

# View file with more (page by page)
more /etc/cups/cups-browsed.conf

# Pipe find output to less
find /etc/ | less
```

### Head and Tail Operations

```bash
# View first lines (default 10)
head combined.txt

# View first 2 lines
head -n 2 combined.txt

# View last 2 lines
tail -n 2 combined.txt

# Combine with other commands
find /etc/ | head -n 20
```

---

## 5. Sorting Operations

### Basic Sorting

```bash
# Sort text file alphabetically
sort linux_practise/words.txt

# Reverse sort
sort -r linux_practise/words.txt

# Sort and reverse with tac
sort linux_practise/words.txt | tac
```

### Numerical Sorting

```bash
# Default sort (lexicographic)
sort linux_practise/numbers.txt

# Numerical sort
sort -n linux_practise/numbers.txt

# Reverse numerical sort
sort -nr linux_practise/numbers.txt
```

### Unique Sorting

```bash
# Sort and remove duplicates
sort -u linux_practise/numbers0-9.txt

# Reverse unique sort
sort -ur linux_practise/numbers0-9.txt
```

---

## 6. Advanced Sorting with ls

### Sort by File Size

```bash
# Sort by size (5th column, numerical)
ls -l /etc/ | head -n 20 | sort -k 5n

# Sort by size (reverse)
ls -l /etc/ | head -n 20 | sort -k 5nr

# Sort human-readable sizes
ls -lh /etc/ | head -n 20 | sort -k 5h
```

### Sort by Date

```bash
# Sort by month (6th column)
ls -lh /etc/ | head -n 20 | sort -k 6M

# Sort by number of links (2nd column)
ls -lh /etc/ | head -n 20 | sort -k 2n
```

---

## 7. Archive Management

### TAR Operations

```bash
# Create tar archive
tar -cvf archive.tar linux_practise/file[1-5].txt

# List archive contents
tar -tf archive.tar

# Extract archive
tar -xvf archive.tar

# Check file type
file archive.tar
```

### Compression Operations

#### GZIP Compression

```bash
# Compress with gzip
gzip archive.tar

# Check compressed file
file archive.tar.gz

# Decompress
gunzip archive.tar.gz
```

#### BZIP2 Compression

```bash
# Compress with bzip2
bzip2 archive.tar

# Check compressed file
file archive.tar.bz2

# Decompress
bunzip2 archive.tar.bz2
```

#### ZIP Operations

```bash
# Create zip archive
zip archive.zip linux_practise/file*.txt

# Extract zip archive
unzip archive.zip
```

### Combined TAR and Compression

```bash
# Create gzipped tar archive
tar -czvf archive.tar.gz linux_practise/file[1-5].txt

# Create bzip2 tar archive
tar -cjvf archive.tar.bz2 linux_practise/file[1-5].txt

# Extract gzipped tar
tar -xvzf archive.tar.gz
```

---

## 8. Command Reference

### File Operations

| Command | Purpose | Example |
|---------|---------|---------|
| `mkdir` | Create directory | `mkdir dirname` |
| `mv` | Move/rename files | `mv old new` |
| `touch` | Create empty files | `touch file{1..5}.txt` |
| `echo >` | Write to file | `echo "text" > file.txt` |
| `cat` | Display/combine files | `cat file1 file2 > combined` |

### Text Processing

| Command | Purpose | Example |
|---------|---------|---------|
| `tac` | Reverse line order | `tac file.txt` |
| `rev` | Reverse characters | `rev file.txt` |
| `head` | Show first lines | `head -n 5 file.txt` |
| `tail` | Show last lines | `tail -n 5 file.txt` |
| `less` | Interactive file viewer | `less file.txt` |
| `more` | Page-by-page viewer | `more file.txt` |

### Sorting Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `sort` | Sort lines alphabetically | `sort file.txt` |
| `sort -n` | Numerical sort | `sort -n numbers.txt` |
| `sort -r` | Reverse sort | `sort -r file.txt` |
| `sort -u` | Unique sort | `sort -u file.txt` |
| `sort -k` | Sort by column | `sort -k 2n file.txt` |
| `sort -h` | Human-readable sort | `sort -k 5h` |
| `sort -M` | Month sort | `sort -k 6M` |

### Archive Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `tar -cvf` | Create tar archive | `tar -cvf archive.tar files` |
| `tar -tf` | List archive contents | `tar -tf archive.tar` |
| `tar -xvf` | Extract archive | `tar -xvf archive.tar` |
| `tar -czvf` | Create gzipped tar | `tar -czvf archive.tar.gz files` |
| `tar -cjvf` | Create bzip2 tar | `tar -cjvf archive.tar.bz2 files` |
| `gzip` | Compress file | `gzip file.tar` |
| `gunzip` | Decompress gzip | `gunzip file.tar.gz` |
| `bzip2` | Compress with bzip2 | `bzip2 file.tar` |
| `bunzip2` | Decompress bzip2 | `bunzip2 file.tar.bz2` |
| `zip` | Create zip archive | `zip archive.zip files` |
| `unzip` | Extract zip archive | `unzip archive.zip` |

---

## 9. Practical Examples

### File Organization Workflow

```bash
# Create project structure
mkdir project/{docs,src,tests}
touch project/src/main.{py,sh,c}
touch project/docs/readme.txt
touch project/tests/test_{1..3}.py

# List structure
find project -type f | sort
```

### Log Analysis Pipeline

```bash
# Create sample log data
echo "2024-01-15 ERROR: Database connection failed" > app.log
echo "2024-01-15 INFO: Application started" >> app.log
echo "2024-01-15 WARN: Memory usage high" >> app.log

# Sort by severity
sort app.log | grep -E "(ERROR|WARN)" | head -5
```

### Archive Management Workflow

```bash
# Create backup archive
tar -czvf backup_$(date +%Y%m%d).tar.gz project/

# List archive contents
tar -tzf backup_*.tar.gz

# Verify archive integrity
tar -tzf backup_*.tar.gz > /dev/null && echo "Archive OK"
```

---

## 10. Best Practices

### File Operations
- Use descriptive names for files and directories
- Test commands with `echo` before execution
- Use brace expansion for efficient file creation
- Always verify file operations with `ls` or `cat`

### Text Processing
- Use `less` for large files instead of `cat`
- Combine commands with pipes for powerful processing
- Use `head` and `tail` to preview large datasets
- Sort data before processing for better performance

### Archive Management
- Choose appropriate compression based on file types
- Use `.tar.gz` for general purpose archives
- Use `.tar.bz2` for better compression ratios
- Always test archive extraction before deleting originals
- Include timestamps in archive names for versioning

---

## 11. Common Issues and Solutions

### File Creation Issues
```bash
# Wrong: Pattern not expanded
touch file[1-5].txt  # Creates literal filename

# Correct: Use brace expansion
touch file{1..5}.txt  # Creates 5 separate files
```

### Sorting Issues
```bash
# Wrong: Lexicographic sort on numbers
sort numbers.txt  # 10 comes before 2

# Correct: Numerical sort
sort -n numbers.txt  # Proper numerical order
```

### Archive Issues
```bash
# Wrong: Overwriting existing archive
tar -czvf archive.tar.gz files  # May overwrite

# Correct: Check if archive exists
[ ! -f archive.tar.gz ] && tar -czvf archive.tar.gz files
```

---

## Summary

This session covered essential Linux file operations including:
- **File Creation**: Directory management and pattern-based file creation
- **Text Processing**: Content manipulation with cat, tac, rev, head, tail
- **Sorting**: Alphabetical, numerical, and column-based sorting
- **Archive Management**: TAR, GZIP, BZIP2, and ZIP operations
- **Best Practices**: Efficient workflows and error prevention

These skills form the foundation for effective file management and data processing in Linux environments.