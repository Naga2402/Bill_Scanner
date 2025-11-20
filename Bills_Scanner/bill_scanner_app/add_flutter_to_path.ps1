# PowerShell Script to Add Flutter to PATH
# Run this script as Administrator

Write-Host "Adding Flutter to PATH..." -ForegroundColor Green

# Add Flutter to User PATH
$flutterPath = "C:\flutter\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)

if ($currentPath -notlike "*$flutterPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$flutterPath", [EnvironmentVariableTarget]::User)
    Write-Host "✅ Flutter added to PATH successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "⚠️  Please restart your terminal/IDE for changes to take effect." -ForegroundColor Yellow
} else {
    Write-Host "✅ Flutter is already in PATH!" -ForegroundColor Green
}

Write-Host ""
Write-Host "To verify, restart terminal and run: flutter --version" -ForegroundColor Cyan


