# Local Development Script for Azure Echo Demo
# Sets up local environment for testing before deploying to Azure

param(
    [switch]$Docker,
    [switch]$Ngrok,
    [int]$Port = 8080
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "=== Azure Echo Demo - Local Development ===" -ForegroundColor Cyan

# Check Python
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    Write-Host "Python not found. Please install Python 3.11+" -ForegroundColor Red
    exit 1
}

# Run with Docker
if ($Docker) {
    Write-Host "`nStarting with Docker..." -ForegroundColor Yellow
    
    # Check Docker
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $docker) {
        Write-Host "Docker not found. Please install Docker Desktop." -ForegroundColor Red
        exit 1
    }
    
    # Build and run
    Push-Location $ProjectRoot
    Write-Host "Building Docker image..." -ForegroundColor Cyan
    docker build -t echo-server .
    
    Write-Host "Running container on port $Port..." -ForegroundColor Cyan
    docker run --rm -p "${Port}:8080" -e ENVIRONMENT=local echo-server
    Pop-Location
    exit 0
}

# Run with Python directly
Write-Host "`nSetting up Python environment..." -ForegroundColor Yellow

# Create virtual environment if it doesn't exist
$venvPath = Join-Path $ProjectRoot ".venv"
if (-not (Test-Path $venvPath)) {
    Write-Host "Creating virtual environment..." -ForegroundColor Cyan
    python -m venv $venvPath
}

# Activate virtual environment
$activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
. $activateScript

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Cyan
pip install -q -r "$ProjectRoot\app\requirements.txt"

# Set environment variables
$env:ENVIRONMENT = "local"
$env:PORT = $Port

# Start ngrok in background if requested
if ($Ngrok) {
    $ngrok = Get-Command ngrok -ErrorAction SilentlyContinue
    if (-not $ngrok) {
        Write-Host "Installing ngrok..." -ForegroundColor Yellow
        winget install ngrok.ngrok --accept-source-agreements --accept-package-agreements
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }
    
    Write-Host "`nStarting ngrok tunnel..." -ForegroundColor Cyan
    Start-Process ngrok -ArgumentList "http $Port" -WindowStyle Minimized
    Start-Sleep -Seconds 2
    
    # Get ngrok URL
    try {
        $ngrokApi = Invoke-RestMethod "http://localhost:4040/api/tunnels" -ErrorAction SilentlyContinue
        $publicUrl = $ngrokApi.tunnels | Where-Object { $_.proto -eq "https" } | Select-Object -First 1 -ExpandProperty public_url
        Write-Host ""
        Write-Host "Public URL: $publicUrl" -ForegroundColor Green
        Write-Host "   (Share this URL to test from anywhere)" -ForegroundColor Gray
    }
    catch {
        Write-Host "ngrok started - check http://localhost:4040 for public URL" -ForegroundColor Yellow
    }
}

# Run the application
Write-Host ""
Write-Host "Starting Echo Server..." -ForegroundColor Green
Write-Host "   Local:  http://localhost:$Port" -ForegroundColor White
Write-Host "   Health: http://localhost:$Port/health" -ForegroundColor White
Write-Host "   API:    http://localhost:$Port/echo" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

Push-Location "$ProjectRoot\app"
python main.py
Pop-Location
