Set-Location $PSScriptRoot

function Command-Exists {
    param ($cmd)
    return (Get-Command $cmd -ErrorAction SilentlyContinue) -ne $null
}

function Install-Git {
    if (Command-Exists git) { return }
    Write-Host "Installing Git (fallback)..."
    $url = "https://github.com/git-for-windows/git/releases/latest/download/Git-64-bit.exe"
    $out = "$env:TEMP\git.exe"
    Invoke-WebRequest $url -OutFile $out
    Start-Process $out -ArgumentList "/VERYSILENT /NORESTART" -Wait
}

function Install-Node {
    if (Command-Exists node) { return }
    Write-Host "Installing Node.js (fallback)..."
    $url = "https://nodejs.org/dist/v18.20.4/node-v18.20.4-x64.msi"
    $out = "$env:TEMP\node.msi"
    Invoke-WebRequest $url -OutFile $out
    Start-Process msiexec -ArgumentList "/i `"$out`" /quiet /norestart" -Wait
}

function Install-Python {
    if (Command-Exists python) { return }
    Write-Host "Installing Python (fallback)..."
    $url = "https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe"
    $out = "$env:TEMP\python.exe"
    Invoke-WebRequest $url -OutFile $out
    Start-Process $out -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
}

# ===============================
# INSTALL DEPENDENCIES
# ===============================

Install-Git
Install-Node
Install-Python

# refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")

# ===============================
# BUILD & INJECT
# ===============================

npm install -g pnpm@10.4.1

Get-Process Discord -ErrorAction SilentlyContinue | Stop-Process -Force

git pull
pnpm install --frozen-lockfile
pnpm build
pnpm inject

python stereo_injector.py

Write-Host "=== DONE ==="
pause
