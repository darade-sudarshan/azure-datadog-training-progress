# Linux Advanced Topics - Day 07-02: Text Processing, Process Management & Network Commands

This guide covers advanced Linux system administration topics including text processing with sed/awk, process management, and network troubleshooting.

## Learning Objectives

- Master advanced text processing with `sed` and `awk`
- Understand process management and system monitoring
- Learn network commands and troubleshooting techniques
- Apply practical examples for real-world scenarios

---

## 1. Advanced Text Processing with sed

### Basic sed Operations

```bash
# Substitute text (first occurrence)
echo "hello world hello" | sed 's/hello/hi/'

# Substitute all occurrences
echo "hello world hello" | sed 's/hello/hi/g'

# Delete lines containing pattern
sed '/pattern/d' file.txt

# Print specific lines
sed -n '1,5p' file.txt    # Print lines 1-5
sed -n '10p' file.txt     # Print line 10
```

### Practical sed Examples

```bash
# Remove empty lines
sed '/^$/d' file.txt

# Replace IP addresses
sed 's/192\.168\.1\./10.0.0./g' config.txt

# Add text at beginning of each line
sed 's/^/PREFIX: /' file.txt

# Remove comments from config files
sed '/^#/d' /etc/ssh/sshd_config

# In-place editing
sed -i 's/old/new/g' file.txt
```

---

## 2. Text Processing with cut

### Basic cut Operations

```bash
# Extract specific fields by delimiter
echo "name:age:city" | cut -d':' -f2    # Extract age field
date | cut -d' ' -f1                     # Extract day of week
date | cut -d' ' -f5                     # Extract time

# Extract character positions
echo "hello world" | cut -c1-5          # Extract first 5 characters
echo "hello world" | cut -c7-           # Extract from 7th character to end

# Extract multiple fields
ps aux | cut -d' ' -f1,2,11              # Extract user, PID, command
```

### Practical cut Examples

```bash
# Extract IP addresses from logs
cut -d' ' -f1 access.log | sort | uniq

# Extract usernames from /etc/passwd
cut -d':' -f1 /etc/passwd

# Extract file permissions
ls -l | cut -c1-10

# Process CSV files
cut -d',' -f2,4 data.csv                 # Extract columns 2 and 4
```

---

## 3. Advanced Text Processing with awk

### Basic awk Operations

```bash
# Print specific columns
ps aux | awk '{print $1, $2, $11}'    # User, PID, Command

# Print lines with conditions
awk '$3 > 50' file.txt    # Print lines where 3rd field > 50

# Calculate sum of column
awk '{sum += $3} END {print sum}' numbers.txt

# Count lines
awk 'END {print NR}' file.txt
```

### Practical awk Examples

```bash
# Process log files
awk '$9 == 404 {print $1, $7}' access.log    # Find 404 errors

# Memory usage analysis
free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2}'

# Disk usage summary
df -h | awk '$5+0 > 80 {print $0}'    # Show filesystems >80% full

# Process CPU usage
ps aux | awk '$3 > 5.0 {print $1, $2, $3, $11}' | sort -k3 -nr
```

---

## 4. Process Management

### Viewing Processes

```bash
# List all processes
ps aux
ps -ef

# Process tree
pstree
pstree -p    # Show PIDs

# Real-time process monitoring
top
htop    # Enhanced version

# Process by user
ps -u username
```

### Process Control

```bash
# Run process in background
command &

# List background jobs
jobs

# Bring job to foreground
fg %1

# Send job to background
bg %1

# Kill processes
kill PID
kill -9 PID    # Force kill
killall process_name
pkill -f pattern
```

### Practical Process Examples

```bash
# Find memory-intensive processes
ps aux --sort=-%mem | head -10

# Find CPU-intensive processes
ps aux --sort=-%cpu | head -10

# Monitor specific process
watch -n 1 'ps aux | grep nginx'

# Process resource usage
pidstat -p PID 1    # Monitor specific PID every second
```

---

## 5. System Monitoring

### System Resource Monitoring

```bash
# CPU information
lscpu
cat /proc/cpuinfo

# Memory information
free -h
cat /proc/meminfo

# Disk usage
df -h
du -sh /var/log/*

# System load
uptime
w
```

### Performance Monitoring Tools

```bash
# I/O statistics
iostat -x 1

# Network statistics
netstat -i
ss -tuln

# System activity
sar -u 1 5    # CPU usage every second, 5 times
sar -r 1 5    # Memory usage

# Real-time monitoring
vmstat 1
iotop
```

### Log Monitoring

```bash
# Follow log files
tail -f /var/log/syslog
tail -f /var/log/auth.log

# Search logs
grep "error" /var/log/syslog
journalctl -f    # Follow systemd logs
journalctl -u service_name
```

---

## 6. Network Commands and Troubleshooting

### Network Configuration

```bash
# Show network interfaces
ip addr show
ifconfig

# Show routing table
ip route show
route -n

# Show ARP table
ip neigh show
arp -a
```

### Network Connectivity Testing

```bash
# Ping connectivity
ping -c 4 google.com
ping6 -c 4 ipv6.google.com

# Trace route
traceroute google.com
tracepath google.com

# Port connectivity
telnet hostname 80
nc -zv hostname 80-443    # Port range scan
```

### Network Troubleshooting

```bash
# DNS lookup
nslookup google.com
dig google.com
host google.com

# Network connections
netstat -tuln    # Listening ports
ss -tuln         # Modern alternative
lsof -i :80      # What's using port 80

# Bandwidth testing
wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test100.zip
curl -o /dev/null -s -w "%{speed_download}\n" http://example.com/file
```

### Firewall and Security

```bash
# UFW firewall
sudo ufw status
sudo ufw enable
sudo ufw allow 22/tcp

# iptables
sudo iptables -L
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Check open ports
nmap localhost
nmap -sT -O localhost
```

---

## 7. Practical Examples and Use Cases

### Log Analysis Pipeline

```bash
# Analyze Apache access logs
cat access.log | \
awk '{print $1}' | \
sort | uniq -c | \
sort -nr | \
head -10 > top_ips.txt

# Find failed login attempts
grep "Failed password" /var/log/auth.log | \
awk '{print $11}' | \
sort | uniq -c | \
sort -nr
```

### System Health Check Script

```bash
#!/bin/bash
# System health check

echo "=== System Health Report ==="
echo "Date: $(date)"
echo

# CPU Load
echo "CPU Load:"
uptime

# Memory Usage
echo -e "\nMemory Usage:"
free -h

# Disk Usage
echo -e "\nDisk Usage:"
df -h | awk '$5+0 > 80 {print $0}'

# Top processes
echo -e "\nTop CPU Processes:"
ps aux --sort=-%cpu | head -5
```

### Network Monitoring Script

```bash
#!/bin/bash
# Network connectivity monitor

HOSTS="google.com github.com"
LOG_FILE="/var/log/network_monitor.log"

for host in $HOSTS; do
    if ping -c 1 $host > /dev/null 2>&1; then
        echo "$(date): $host - OK" >> $LOG_FILE
    else
        echo "$(date): $host - FAILED" >> $LOG_FILE
    fi
done
```

### Process Cleanup Script

```bash
#!/bin/bash
# Clean up old processes

# Kill processes older than 1 hour
ps -eo pid,etime,comm | \
awk '$2 ~ /^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]$/ && $3 == "target_process" {print $1}' | \
xargs -r kill

# Clean up zombie processes
ps aux | awk '$8 ~ /^Z/ {print $2}' | xargs -r kill -9
```

---

## 8. Command Reference

### Text Processing Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `sed 's/old/new/'` | Stream editor - substitute text | `sed 's/foo/bar/' file.txt` |
| `sed '/pattern/d'` | Delete lines matching pattern | `sed '/error/d' log.txt` |
| `sed -n 'Np'` | Print specific line number | `sed -n '5p' file.txt` |
| `sed -i` | Edit file in-place | `sed -i 's/old/new/g' file.txt` |
| `awk '{print $1}'` | Print specific field/column | `awk '{print $1}' file.txt` |
| `awk '$1 > 10'` | Filter lines by condition | `awk '$1 > 10' numbers.txt` |
| `awk 'END {print NR}'` | Count total lines | `awk 'END {print NR}' file.txt` |
| `cut -d':' -f1` | Extract field by delimiter | `cut -d':' -f1 /etc/passwd` |
| `cut -c1-5` | Extract character positions | `cut -c1-5 file.txt` |
| `cut -f2,4` | Extract multiple fields | `cut -f2,4 data.tsv` |

### Process Management Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `ps aux` | List all running processes | `ps aux \| grep nginx` |
| `ps -ef` | List processes with full format | `ps -ef \| head -10` |
| `pstree` | Display process tree | `pstree -p` |
| `top` | Real-time process monitor | `top` |
| `htop` | Enhanced process monitor | `htop` |
| `kill PID` | Terminate process by PID | `kill 1234` |
| `kill -9 PID` | Force kill process | `kill -9 1234` |
| `killall name` | Kill processes by name | `killall firefox` |
| `pkill pattern` | Kill processes by pattern | `pkill -f python` |
| `jobs` | List background jobs | `jobs` |
| `fg %1` | Bring job to foreground | `fg %1` |
| `bg %1` | Send job to background | `bg %1` |
| `nohup command &` | Run command detached | `nohup ./script.sh &` |

### System Monitoring Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `uptime` | Show system uptime and load | `uptime` |
| `w` | Show logged in users | `w` |
| `free -h` | Display memory usage | `free -h` |
| `df -h` | Show disk space usage | `df -h` |
| `du -sh` | Show directory size | `du -sh /var/log/*` |
| `lscpu` | Display CPU information | `lscpu` |
| `iostat` | I/O statistics | `iostat -x 1` |
| `vmstat` | Virtual memory statistics | `vmstat 1` |
| `iotop` | I/O usage by process | `iotop` |
| `sar` | System activity reporter | `sar -u 1 5` |
| `pidstat` | Process statistics | `pidstat -p 1234 1` |

### Network Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `ping` | Test network connectivity | `ping -c 4 google.com` |
| `ping6` | Test IPv6 connectivity | `ping6 -c 4 ipv6.google.com` |
| `traceroute` | Trace network path | `traceroute google.com` |
| `tracepath` | Trace network path (no root) | `tracepath google.com` |
| `netstat -tuln` | Show listening ports | `netstat -tuln` |
| `ss -tuln` | Modern netstat alternative | `ss -tuln` |
| `lsof -i :80` | Show what's using port 80 | `lsof -i :80` |
| `nslookup` | DNS lookup tool | `nslookup google.com` |
| `dig` | Advanced DNS lookup | `dig google.com` |
| `host` | Simple DNS lookup | `host google.com` |
| `ip addr show` | Show network interfaces | `ip addr show` |
| `ip route show` | Show routing table | `ip route show` |
| `ifconfig` | Configure network interface | `ifconfig eth0` |
| `route -n` | Show routing table | `route -n` |
| `arp -a` | Show ARP table | `arp -a` |
| `nc -zv host port` | Test port connectivity | `nc -zv google.com 80` |
| `telnet host port` | Connect to port | `telnet google.com 80` |
| `wget` | Download files | `wget http://example.com/file` |
| `curl` | Transfer data from servers | `curl -I http://example.com` |
| `nmap` | Network port scanner | `nmap localhost` |

---

## 9. Best Practices

### Text Processing
- Use `sed` for simple substitutions
- Use `awk` for complex field processing
- Combine tools in pipelines for powerful processing
- Test regex patterns before applying to important files

### Process Management
- Monitor system resources regularly
- Use appropriate signals when killing processes
- Implement proper logging for long-running processes
- Set up process monitoring and alerting

### Network Troubleshooting
- Start with basic connectivity (ping)
- Check DNS resolution
- Verify port accessibility
- Monitor network performance trends
- Document network topology and configurations

---

## 10. Troubleshooting Common Issues

### Text Processing Issues
```bash
# Escape special characters in sed
sed 's/\$/DOLLAR/g' file.txt

# Handle spaces in awk
awk -F',' '{print $1}' file.csv    # Use comma delimiter
```

### Process Issues
```bash
# Find processes using files
lsof /path/to/file

# Check process limits
ulimit -a
cat /proc/PID/limits
```

### Network Issues
```bash
# Check if service is listening
ss -tuln | grep :80

# Verify DNS resolution
dig +trace google.com

# Check routing
ip route get 8.8.8.8
```

---

## Summary

This advanced session covered:
- **Text Processing**: sed for stream editing, awk for field processing
- **Process Management**: Monitoring, controlling, and troubleshooting processes
- **Network Commands**: Connectivity testing, troubleshooting, and monitoring
- **Practical Applications**: Real-world scripts and use cases

These advanced skills enable effective system administration, automation, and troubleshooting in Linux environments.