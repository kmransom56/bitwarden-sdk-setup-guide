# Bitwarden SDK Setup Script
# Run this script to automatically set up the Bitwarden SDK on Windows

param(
    [string]$SdkPath = "C:\Projects\bitwarden-sdk",
    [switch]$SkipDownload,
    [switch]$Force
)

Write-Host "🔧 Bitwarden SDK Setup Script" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# Function to check if command exists
function Test-Command {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to install via winget
function Install-WithWinget {
    param($PackageId, $Name)
    
    Write-Host "📦 Installing $Name..." -ForegroundColor Yellow
    try {
        winget install $PackageId --silent
        Write-Host "✅ $Name installed successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Failed to install $Name via winget" -ForegroundColor Red
        return $false
    }
}

# Check prerequisites
Write-Host "`n🔍 Checking prerequisites..." -ForegroundColor Yellow

# Check winget
if (-not (Test-Command "winget")) {
    Write-Host "❌ winget is not available. Please install from Microsoft Store or GitHub." -ForegroundColor Red
    exit 1
}

# Install .NET 8.0 SDK
Write-Host "`n1️⃣ Checking .NET 8.0 SDK..." -ForegroundColor Cyan
$dotnetVersion = try { dotnet --version 2>$null } catch { $null }
if (-not $dotnetVersion -or -not $dotnetVersion.StartsWith("8.")) {
    Install-WithWinget "Microsoft.DotNet.SDK.8" ".NET 8.0 SDK"
} else {
    Write-Host "✅ .NET 8.0 SDK already installed: $dotnetVersion" -ForegroundColor Green
}

# Install Rust
Write-Host "`n2️⃣ Checking Rust..." -ForegroundColor Cyan
if (-not (Test-Command "cargo")) {
    Install-WithWinget "Rustlang.Rust.MSVC" "Rust"
    # Add to PATH for current session
    $rustPath = "C:\Program Files\Rust stable MSVC 1.90\bin"
    if (Test-Path $rustPath) {
        $env:PATH += ";$rustPath"
    }
} else {
    $cargoVersion = cargo --version
    Write-Host "✅ Rust already installed: $cargoVersion" -ForegroundColor Green
}

# Install Node.js
Write-Host "`n3️⃣ Checking Node.js..." -ForegroundColor Cyan
if (-not (Test-Command "node")) {
    Install-WithWinget "OpenJS.NodeJS" "Node.js"
} else {
    $nodeVersion = node --version
    Write-Host "✅ Node.js already installed: $nodeVersion" -ForegroundColor Green
}

# Setup SDK directory
if (-not $SkipDownload) {
    Write-Host "`n4️⃣ Setting up SDK directory..." -ForegroundColor Cyan
    if (Test-Path $SdkPath) {
        if ($Force) {
            Write-Host "🗑️ Removing existing directory..." -ForegroundColor Yellow
            Remove-Item $SdkPath -Recurse -Force
        } else {
            Write-Host "⚠️ Directory already exists. Use -Force to overwrite." -ForegroundColor Yellow
            Read-Host "Press Enter to continue with existing directory or Ctrl+C to cancel"
        }
    }
    
    if (-not (Test-Path $SdkPath)) {
        New-Item -ItemType Directory -Path $SdkPath -Force | Out-Null
    }
    
    Write-Host "📁 SDK will be set up at: $SdkPath" -ForegroundColor Cyan
    Write-Host "📥 Please download the latest SDK from:" -ForegroundColor Yellow
    Write-Host "   https://github.com/bitwarden/sdk-sm/releases" -ForegroundColor Blue
    Write-Host "   Extract it to: $SdkPath" -ForegroundColor Yellow
    Read-Host "`nPress Enter when you've extracted the SDK files"
}

# Build SDK components
Write-Host "`n5️⃣ Building SDK components..." -ForegroundColor Cyan

if (Test-Path $SdkPath) {
    Push-Location $SdkPath
    
    try {
        # Install npm dependencies
        Write-Host "📦 Installing npm dependencies..." -ForegroundColor Yellow
        npm install
        
        # Generate schemas
        Write-Host "🔧 Generating schemas..." -ForegroundColor Yellow
        npm run schemas
        
        # Build Rust components
        Write-Host "🦀 Building Rust components..." -ForegroundColor Yellow
        Set-Location "crates\bitwarden-c"
        cargo build --release
        
        # Build C# SDK
        Write-Host "🏗️ Building C# SDK..." -ForegroundColor Yellow
        Set-Location "..\..\languages\csharp"
        dotnet restore
        dotnet build
        
        Write-Host "`n🎉 Setup completed successfully!" -ForegroundColor Green
        Write-Host "✅ Bitwarden CLI available at: $SdkPath\target\release\bws.exe" -ForegroundColor Green
        Write-Host "✅ C# SDK built successfully" -ForegroundColor Green
        Write-Host "`n💡 You can now open the solution in VS Code:" -ForegroundColor Cyan
        Write-Host "   code `"$SdkPath\languages\csharp\Bitwarden.sln`"" -ForegroundColor Blue
        
    }
    catch {
        Write-Host "❌ Build failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
    finally {
        Pop-Location
    }
} else {
    Write-Host "❌ SDK directory not found: $SdkPath" -ForegroundColor Red
    exit 1
}

Write-Host "`n🚀 Next steps:" -ForegroundColor Cyan
Write-Host "1. Get an access token from your Bitwarden organization" -ForegroundColor White
Write-Host "2. Set environment variable: `$env:BWS_ACCESS_TOKEN = 'your-token'" -ForegroundColor White
Write-Host "3. Test the CLI: .\bws.exe --help" -ForegroundColor White
Write-Host "4. Open VS Code and start coding!" -ForegroundColor White