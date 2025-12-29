Set-Location $PSScriptRoot

function Command-Exists {
    param ($cmd)
    return (Get-Command $cmd -ErrorAction SilentlyContinue) -ne $null
}

Write-Host "=== Checking Git ==="
if (-not (Command-Exists git)) {
    winget install --id Git.Git -e --source winget
}

Write-Host "=== Checking Node.js ==="
if (-not (Command-Exists node)) {
    winget install --id OpenJS.NodeJS.LTS -e --source winget
}

Write-Host "=== Checking Python ==="
if (-not (Command-Exists python)) {
    winget install --id Python.Python.3.11 -e --source winget
}

Write-Host "=== Installing pnpm ==="
npm install -g pnpm@10.4.1

Write-Host "=== Closing Discord ==="
Get-Process Discord -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host "=== Updating Equicord ==="
git pull

Write-Host "=== Installing deps ==="
pnpm install --frozen-lockfile

Write-Host "=== Building Equicord ==="
pnpm build

Write-Host "=== Injecting Equicord ==="
pnpm inject

Write-Host "=== Injecting Stereo ==="
python stereo_injector.py

Write-Host "=== DONE ==="
pause
