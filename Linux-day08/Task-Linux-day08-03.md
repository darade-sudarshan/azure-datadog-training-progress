# Linux Package Management - Day 08-03: Software Installation & Management

This guide covers package management systems, software installation methods, and repository management across different Linux distributions.

## Learning Objectives

- Master package management with APT, YUM, and DNF
- Understand software installation from source
- Learn repository management and configuration
- Practice dependency resolution and troubleshooting
- Apply security updates and system maintenance

---

## 1. APT Package Manager (Debian/Ubuntu)

### Basic APT Commands

```bash
# Update package lists
sudo apt update

# Upgrade installed packages
sudo apt upgrade

# Full system upgrade
sudo apt full-upgrade

# Install package
sudo apt install package_name

# Remove package
sudo apt remove package_name

# Remove package and configuration
sudo apt purge package_name

# Remove unused packages
sudo apt autoremove
```

### Package Information

```bash
# Search for packages
apt search keyword
apt-cache search keyword

# Show package information
apt show package_name
apt-cache show package_name

# List installed packages
apt list --installed

# Check if package is installed
dpkg -l | grep package_name
```

### Advanced APT Operations

```bash
# Install specific version
sudo apt install package_name=version

# Hold package from updates
sudo apt-mark hold package_name

# Unhold package
sudo apt-mark unhold package_name

# Download package without installing
apt download package_name

# Install local .deb file
sudo dpkg -i package.deb
sudo apt install -f  # Fix dependencies
```

---

## 2. YUM Package Manager (RHEL/CentOS 7)

### Basic YUM Commands

```bash
# Update package lists
sudo yum check-update

# Update all packages
sudo yum update

# Install package
sudo yum install package_name

# Remove package
sudo yum remove package_name

# Search packages
yum search keyword

# Show package info
yum info package_name

# List installed packages
yum list installed
```

### YUM Groups

```bash
# List available groups
yum grouplist

# Install group
sudo yum groupinstall "Development Tools"

# Remove group
sudo yum groupremove "Development Tools"

# Show group info
yum groupinfo "Development Tools"
```

---

## 3. DNF Package Manager (RHEL/CentOS 8+/Fedora)

### Basic DNF Commands

```bash
# Update package cache
sudo dnf check-update

# Update system
sudo dnf update

# Install package
sudo dnf install package_name

# Remove package
sudo dnf remove package_name

# Search packages
dnf search keyword

# Show package info
dnf info package_name

# List installed packages
dnf list installed
```

### DNF History

```bash
# Show transaction history
dnf history

# Show specific transaction
dnf history info transaction_id

# Undo transaction
sudo dnf history undo transaction_id

# Redo transaction
sudo dnf history redo transaction_id
```

---

## 4. Snap Package Manager

### Basic Snap Commands

```bash
# Install snap
sudo apt install snapd  # Ubuntu/Debian
sudo dnf install snapd  # Fedora

# Search snaps
snap find keyword

# Install snap package
sudo snap install package_name

# List installed snaps
snap list

# Update snaps
sudo snap refresh

# Remove snap
sudo snap remove package_name

# Show snap info
snap info package_name
```

### Snap Channels

```bash
# Install from specific channel
sudo snap install package_name --channel=beta

# Switch channels
sudo snap refresh package_name --channel=stable

# List available channels
snap info package_name
```

---

## 5. Flatpak Package Manager

### Basic Flatpak Commands

```bash
# Install flatpak
sudo apt install flatpak  # Ubuntu/Debian
sudo dnf install flatpak  # Fedora

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Search applications
flatpak search keyword

# Install application
flatpak install flathub app_id

# List installed apps
flatpak list

# Update applications
flatpak update

# Remove application
flatpak uninstall app_id
```

---

## 6. Repository Management

### APT Repositories

```bash
# Add repository
sudo add-apt-repository ppa:repository/name

# Remove repository
sudo add-apt-repository --remove ppa:repository/name

# Edit sources list
sudo nano /etc/apt/sources.list

# Add custom repository
echo "deb http://repo.example.com/ubuntu focal main" | sudo tee /etc/apt/sources.list.d/custom.list

# Add GPG key
wget -qO - https://repo.example.com/key.gpg | sudo apt-key add -
```

### YUM/DNF Repositories

```bash
# List repositories
yum repolist
dnf repolist

# Add repository
sudo yum-config-manager --add-repo https://repo.example.com/repo.repo
sudo dnf config-manager --add-repo https://repo.example.com/repo.repo

# Enable/disable repository
sudo yum-config-manager --enable repo_name
sudo dnf config-manager --set-enabled repo_name

# Install from specific repo
sudo yum install package_name --enablerepo=repo_name
sudo dnf install package_name --enablerepo=repo_name
```

---

## 7. Installing from Source

### Prerequisites

```bash
# Install build tools (Ubuntu/Debian)
sudo apt install build-essential

# Install build tools (RHEL/CentOS/Fedora)
sudo yum groupinstall "Development Tools"
sudo dnf groupinstall "Development Tools"

# Common dependencies
sudo apt install cmake git wget curl
```

### Source Installation Process

```bash
# Download source code
wget https://example.com/software-1.0.tar.gz
tar -xzf software-1.0.tar.gz
cd software-1.0

# Configure build
./configure --prefix=/usr/local

# Compile
make

# Install
sudo make install

# Alternative: Install to custom location
./configure --prefix=/opt/software
make
sudo make install
```

### CMake Build

```bash
# CMake-based project
mkdir build
cd build
cmake ..
make
sudo make install
```

---

## 8. Dependency Management

### Resolving Dependencies

```bash
# APT dependency issues
sudo apt install -f
sudo apt --fix-broken install

# YUM dependency issues
sudo yum deplist package_name
sudo yum install package_name --skip-broken

# DNF dependency issues
sudo dnf install package_name --best --allowerasing
```

### Package Dependencies

```bash
# Show package dependencies (APT)
apt-cache depends package_name
apt-cache rdepends package_name

# Show package dependencies (YUM/DNF)
yum deplist package_name
dnf repoquery --requires package_name
```

---

## 9. System Updates and Security

### Security Updates

```bash
# Ubuntu security updates
sudo apt update
sudo apt list --upgradable
sudo unattended-upgrade

# RHEL/CentOS security updates
sudo yum update --security
sudo dnf update --security

# List security updates
yum updateinfo list security
dnf updateinfo list security
```

### Automatic Updates

```bash
# Configure unattended upgrades (Ubuntu)
sudo apt install unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades

# Configure automatic updates (RHEL/CentOS)
sudo yum install yum-cron
sudo systemctl enable yum-cron
sudo systemctl start yum-cron
```

---

## 10. Package Building

### Creating DEB Package

```bash
# Install build tools
sudo apt install devscripts build-essential

# Create package structure
mkdir mypackage-1.0
cd mypackage-1.0
mkdir debian

# Create control file
cat > debian/control << EOF
Package: mypackage
Version: 1.0
Architecture: all
Maintainer: Your Name <email@example.com>
Description: My custom package
EOF

# Build package
debuild -us -uc
```

### Creating RPM Package

```bash
# Install build tools
sudo yum install rpm-build rpmdevtools

# Setup build environment
rpmdev-setuptree

# Create spec file
cat > ~/rpmbuild/SPECS/mypackage.spec << EOF
Name: mypackage
Version: 1.0
Release: 1%{?dist}
Summary: My custom package
License: GPL
%description
My custom package description
%files
/usr/bin/myapp
EOF

# Build RPM
rpmbuild -ba ~/rpmbuild/SPECS/mypackage.spec
```

---

## 11. Practical Examples

### Software Installation Script

```bash
#!/bin/bash
# Multi-distro software installer

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo $ID
    else
        echo "unknown"
    fi
}

install_package() {
    local package=$1
    local distro=$(detect_distro)
    
    case $distro in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y $package
            ;;
        centos|rhel)
            sudo yum install -y $package
            ;;
        fedora)
            sudo dnf install -y $package
            ;;
        *)
            echo "Unsupported distribution: $distro"
            exit 1
            ;;
    esac
}

# Install common packages
PACKAGES="git curl wget vim htop"
for pkg in $PACKAGES; do
    echo "Installing $pkg..."
    install_package $pkg
done
```

### System Update Script

```bash
#!/bin/bash
# System update script

LOG_FILE="/var/log/system-update.log"

log() {
    echo "$(date): $1" | tee -a $LOG_FILE
}

update_system() {
    log "Starting system update"
    
    if command -v apt >/dev/null; then
        log "Updating APT packages"
        sudo apt update && sudo apt upgrade -y
        sudo apt autoremove -y
    elif command -v dnf >/dev/null; then
        log "Updating DNF packages"
        sudo dnf update -y
        sudo dnf autoremove -y
    elif command -v yum >/dev/null; then
        log "Updating YUM packages"
        sudo yum update -y
        sudo yum autoremove -y
    fi
    
    log "System update completed"
}

# Run update
update_system
```

### Package Cleanup Script

```bash
#!/bin/bash
# Package cleanup script

cleanup_apt() {
    echo "Cleaning APT cache..."
    sudo apt autoremove -y
    sudo apt autoclean
    sudo apt clean
}

cleanup_yum() {
    echo "Cleaning YUM cache..."
    sudo yum autoremove -y
    sudo yum clean all
}

cleanup_dnf() {
    echo "Cleaning DNF cache..."
    sudo dnf autoremove -y
    sudo dnf clean all
}

# Detect and cleanup
if command -v apt >/dev/null; then
    cleanup_apt
elif command -v dnf >/dev/null; then
    cleanup_dnf
elif command -v yum >/dev/null; then
    cleanup_yum
fi

echo "Cleanup completed"
```

---

## 12. Command Reference

### APT Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `apt update` | Update package lists | `sudo apt update` |
| `apt upgrade` | Upgrade packages | `sudo apt upgrade` |
| `apt install` | Install package | `sudo apt install vim` |
| `apt remove` | Remove package | `sudo apt remove vim` |
| `apt search` | Search packages | `apt search editor` |
| `apt show` | Show package info | `apt show vim` |
| `apt list` | List packages | `apt list --installed` |

### YUM/DNF Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `yum update` | Update packages | `sudo yum update` |
| `yum install` | Install package | `sudo yum install vim` |
| `yum remove` | Remove package | `sudo yum remove vim` |
| `yum search` | Search packages | `yum search editor` |
| `yum info` | Show package info | `yum info vim` |
| `yum list` | List packages | `yum list installed` |
| `yum history` | Show history | `yum history` |

### Snap Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `snap find` | Search snaps | `snap find editor` |
| `snap install` | Install snap | `sudo snap install code` |
| `snap list` | List snaps | `snap list` |
| `snap refresh` | Update snaps | `sudo snap refresh` |
| `snap remove` | Remove snap | `sudo snap remove code` |

### Flatpak Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `flatpak search` | Search apps | `flatpak search editor` |
| `flatpak install` | Install app | `flatpak install flathub org.gnome.gedit` |
| `flatpak list` | List apps | `flatpak list` |
| `flatpak update` | Update apps | `flatpak update` |
| `flatpak uninstall` | Remove app | `flatpak uninstall org.gnome.gedit` |

---

## 13. Best Practices

### Package Management
- Always update package lists before installing
- Use official repositories when possible
- Verify package signatures and checksums
- Keep system regularly updated
- Remove unused packages to save space

### Security
- Enable automatic security updates
- Use trusted repositories only
- Verify GPG keys before adding repositories
- Monitor security advisories
- Test updates in non-production environments

### Troubleshooting
- Check log files for error details
- Use package manager's fix commands
- Clear package cache if issues persist
- Use dependency resolution tools
- Backup system before major updates

---

## 14. Troubleshooting

### Common Issues

```bash
# APT lock issues
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock*
sudo dpkg --configure -a

# Broken packages
sudo apt --fix-broken install
sudo dpkg --configure -a

# Repository key issues
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys KEY_ID

# YUM/DNF cache issues
sudo yum clean all
sudo dnf clean all
sudo yum makecache
sudo dnf makecache
```

### Package Conflicts

```bash
# Force package installation
sudo dpkg -i --force-depends package.deb

# Skip broken packages
sudo yum install package --skip-broken
sudo dnf install package --best --allowerasing

# Remove conflicting packages
sudo apt remove conflicting_package
sudo yum remove conflicting_package
```

---

## Summary

This session covered comprehensive package management including:
- **Package Managers**: APT, YUM, DNF, Snap, Flatpak
- **Repository Management**: Adding, configuring, and managing repositories
- **Source Installation**: Building software from source code
- **Dependency Management**: Resolving and troubleshooting dependencies
- **System Maintenance**: Updates, security patches, and cleanup
- **Package Building**: Creating custom DEB and RPM packages

These skills enable effective software management and system maintenance across different Linux distributions.