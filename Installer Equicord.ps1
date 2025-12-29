[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-Location $PSScriptRoot

function Command-Exists {
    param ($cmd)
    return (Get-Command $cmd -ErrorAction SilentlyContinue) -ne $null
}

function Safe-Download($url, $out) {
    Write-Host "Downloading: $url"
    try {
        Invoke-WebRequest $url -OutFile $out -UseBasicParsing
        return $true
    }
    catch {
        Write-Host "Download failed."
        return $false
    }
}

function Install-Git {
    if (Command-Exists git) { return }
    Write-Host "Installing Git..."
    $out = "$env:TEMP\git.exe"
    if (Safe-Download "https://github.com/git-for-windows/git/releases/download/v2.52.0.windows.1/Git-2.52.0-64-bit.exe" $out) {
        Start-Process $out -ArgumentList "/VERYSILENT /NORESTART" -Wait
    }
    else {
        throw "Git download failed"
    }
}

function Install-Node {
    if (Command-Exists node) { return }
    Write-Host "Installing Node.js..."
    $out = "$env:TEMP\node.msi"
    if (Safe-Download "https://nodejs.org/dist/v18.20.4/node-v18.20.4-x64.msi" $out) {
        Start-Process msiexec -ArgumentList "/i `"$out`" /quiet /norestart" -Wait
    }
    else {
        throw "Node download failed"
    }
}

function Install-Python {
    if (Command-Exists python) { return }
    Write-Host "Installing Python..."
    $out = "$env:TEMP\python.exe"
    if (Safe-Download "https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe" $out) {
        Start-Process $out -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
    }
    else {
        throw "Python download failed"
    }
}

# ===============================
# INSTALL DEPENDENCIES
# ===============================
Install-Git
Install-Node
Install-Python

# Refresh PATH
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
