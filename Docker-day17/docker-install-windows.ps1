# docker-install-windows.ps1

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

# Function to write colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check Windows version
function Check-WindowsVersion {
    $version = [System.Environment]::OSVersion.Version
    if ($version.Major -lt 10) {
        Write-Error "Windows 10 or later is required for Docker Desktop"
        exit 1
    }
    Write-Status "Windows version check passed"
}

# Enable required Windows features
function Enable-WindowsFeatures {
    Write-Status "Enabling required Windows features..."
    
    # Enable WSL
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    
    # Enable Virtual Machine Platform
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    
    # Enable Hyper-V (for Windows Pro/Enterprise)
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
        Write-Status "Hyper-V enabled"
    } catch {
        Write-Warning "Could not enable Hyper-V (may not be available on this Windows edition)"
    }
}

# Install WSL2
function Install-WSL2 {
    Write-Status "Installing WSL2..."
    
    # Download and install WSL2 kernel update
    $wslUpdateUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $wslUpdatePath = "$env:TEMP\wsl_update_x64.msi"
    
    Invoke-WebRequest -Uri $wslUpdateUrl -OutFile $wslUpdatePath
    Start-Process msiexec.exe -Wait -ArgumentList "/i $wslUpdatePath /quiet"
    
    # Set WSL2 as default
    wsl --set-default-version 2
    
    # Install Ubuntu distribution
    wsl --install -d Ubuntu
}

# Download and install Docker Desktop
function Install-DockerDesktop {
    Write-Status "Downloading Docker Desktop..."
    
    $dockerUrl = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
    $dockerPath = "$env:TEMP\DockerDesktopInstaller.exe"
    
    # Download Docker Desktop installer
    Invoke-WebRequest -Uri $dockerUrl -OutFile $dockerPath
    
    Write-Status "Installing Docker Desktop..."
    
    # Install Docker Desktop silently
    Start-Process -FilePath $dockerPath -ArgumentList "install --quiet" -Wait
    
    Write-Status "Docker Desktop installation completed"
}

# Configure Docker Desktop
function Configure-DockerDesktop {
    Write-Status "Configuring Docker Desktop..."
    
    # Create Docker Desktop settings
    $settingsPath = "$env:APPDATA\Docker\settings.json"
    $settingsDir = Split-Path $settingsPath -Parent
    
    if (!(Test-Path $settingsDir)) {
        New-Item -ItemType Directory -Path $settingsDir -Force
    }
    
    $settings = @{
        "useWindowsContainers" = $false
        "exposeDockerAPIOnTCP2375" = $false
        "useWSL2" = $true
        "wslEngineEnabled" = $true
    } | ConvertTo-Json
    
    Set-Content -Path $settingsPath -Value $settings
}

# Verify installation
function Verify-Installation {
    Write-Status "Verifying Docker installation..."
    
    # Wait for Docker to start
    Start-Sleep -Seconds 30
    
    try {
        $dockerVersion = docker --version
        Write-Status "Docker version: $dockerVersion"
        
        $composeVersion = docker compose version
        Write-Status "Docker Compose version: $composeVersion"
        
        # Test with hello-world
        docker run hello-world
        Write-Status "Docker installation verified successfully!"
    } catch {
        Write-Error "Docker installation verification failed: $_"
    }
}

# Main installation function
function Main {
    Write-Status "Starting Docker installation on Windows..."
    
    Check-WindowsVersion
    Enable-WindowsFeatures
    Install-WSL2
    Install-DockerDesktop
    Configure-DockerDesktop
    
    Write-Warning "A system restart is required to complete the installation"
    Write-Status "After restart, Docker Desktop will start automatically"
    
    $restart = Read-Host "Do you want to restart now? (y/N)"
    if ($restart -eq "y" -or $restart -eq "Y") {
        Restart-Computer -Force
    }
}

# Run main function
Main