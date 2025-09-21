# Bitwarden SDK Setup Guide

A comprehensive guide for setting up and using the Bitwarden Secrets Manager SDK on Windows, with solutions to common build issues.

## 🚨 Problem Solved

This guide addresses the common error when trying to load the Bitwarden SDK in VS Code:

```
Error while loading: Microsoft.CodeAnalysis.MSBuild.RemoteInvocationException: 
Failed to find all versions of .NET Core MSBuild. Call to hostfxr_resolve_sdk2.
```

## 📋 Prerequisites

Before starting, ensure you have:

- Windows 10/11
- Visual Studio Code
- PowerShell 5.1 or PowerShell 7+
- Internet connection for downloading dependencies

## 🛠️ Complete Setup Process

### Step 1: Install .NET 8.0 SDK

The Bitwarden SDK requires .NET 8.0 SDK (not just runtime):

```powershell
# Option 1: Using winget (recommended)
winget install Microsoft.DotNet.SDK.8

# Option 2: Manual download
# Visit: https://dotnet.microsoft.com/download/dotnet/8.0
# Download ".NET 8.0 SDK" (not just runtime)
```

**Verify installation:**
```powershell
dotnet --version  # Should show 8.0.x
dotnet --list-sdks  # Should include 8.0.x
```

### Step 2: Install Rust Toolchain

The SDK includes Rust components that need to be built:

```powershell
# Using winget
winget install Rustlang.Rust.MSVC

# Add Rust to PATH for current session (if needed)
$env:PATH += ";C:\Program Files\Rust stable MSVC 1.90\bin"
```

**Verify installation:**
```powershell
cargo --version  # Should show 1.90.0 or later
rustc --version  # Should show Rust version
```

### Step 3: Install Node.js (for schema generation)

```powershell
# Using winget
winget install OpenJS.NodeJS

# Or download from: https://nodejs.org/
```

**Verify installation:**
```powershell
node --version  # Should show v18+ or v20+
npm --version   # Should show 9+ or 10+
```

### Step 4: Download and Setup Bitwarden SDK

```powershell
# Download the latest SDK from GitHub releases
# https://github.com/bitwarden/sdk-sm/releases

# Extract to your preferred location
# Example: C:\Projects\bitwarden-sdk\
```

### Step 5: Build the SDK Components

Navigate to your SDK directory and run these commands **in order**:

```powershell
# 1. Install npm dependencies
npm install

# 2. Build Rust components and generate C# schemas
npm run schemas

# 3. Build the Rust CLI tool
cd "crates\bitwarden-c"
cargo build --release

# 4. Build the C# SDK
cd "..\..\languages\csharp"
dotnet restore
dotnet build
```

## 🎯 Verification Steps

After completing the setup:

1. **Check C# build:**
   ```powershell
   cd "languages\csharp"
   dotnet build
   # Should complete with "Build succeeded" (warnings are OK)
   ```

2. **Verify CLI tool:**
   ```powershell
   cd "..\..\target\release"
   .\bws.exe --help
   # Should show Bitwarden CLI help
   ```

3. **Test VS Code:**
   - Open the `languages\csharp\Bitwarden.sln` in VS Code
   - Should load without MSBuild errors
   - IntelliSense should work properly

## 🚀 Usage Examples

### Using the Bitwarden CLI (bws)

```powershell
# Set your access token
$env:BWS_ACCESS_TOKEN = "your-access-token-here"

# List projects
.\bws.exe project list

# List secrets
.\bws.exe secret list

# Create a secret
.\bws.exe secret create "MySecret" "SecretValue"

# Run application with secrets as environment variables
.\bws.exe run -- dotnet run
```

### Using the C# SDK

```csharp
using Bitwarden.Sdk;

// Initialize client
using var bitwardenClient = new BitwardenClient(new BitwardenSettings
{
    ApiUrl = "https://api.bitwarden.com",
    IdentityUrl = "https://identity.bitwarden.com"
});

// Authenticate
var accessToken = "your-access-token";
var stateFile = Path.GetTempFileName();
bitwardenClient.Auth.LoginAccessToken(accessToken, stateFile);

// Work with secrets
var organizationId = Guid.Parse("your-organization-id");
var secrets = bitwardenClient.Secrets.List(organizationId);

// Create a secret
var newSecret = bitwardenClient.Secrets.Create(
    organizationId,
    "MySecret",
    "SecretValue",
    "Description",
    new[] { projectId }
);
```

## 🐛 Troubleshooting

### Common Issues and Solutions

#### Issue 1: "cargo: The term 'cargo' is not recognized"
**Solution:** Rust is not in PATH. Add it manually:
```powershell
$env:PATH += ";C:\Program Files\Rust stable MSVC 1.90\bin"
```

#### Issue 2: "No .NET SDKs were found"
**Solution:** Install .NET 8.0 SDK (not just runtime):
```powershell
winget install Microsoft.DotNet.SDK.8
```

#### Issue 3: C# build errors about missing types
**Solution:** Generate schemas first:
```powershell
npm install
npm run schemas
```

#### Issue 4: Permission denied during cargo build
**Solution:** Clean and rebuild:
```powershell
cargo clean
cargo build --release
```

#### Issue 5: VS Code still shows MSBuild errors
**Solution:** Restart VS Code after installing all dependencies

### Environment Variables

For permanent setup, add these to your system environment:

```powershell
# Add to system PATH
C:\Program Files\Rust stable MSVC 1.90\bin
C:\Program Files\dotnet\

# Bitwarden configuration
BWS_ACCESS_TOKEN=your-access-token-here
BWS_SERVER_URL=https://vault.bitwarden.com
```

## 📁 Project Structure

After successful setup, your SDK directory should contain:

```
├── crates/
│   ├── bitwarden-c/         # Rust C bindings
│   ├── bws/                 # CLI tool source
│   └── sdk-schemas/         # Schema generation
├── languages/
│   ├── csharp/             # C# SDK
│   │   ├── Bitwarden.Sdk/  # Main SDK library
│   │   └── Bitwarden.Sdk.Samples/  # Example code
│   ├── python/             # Python bindings
│   └── ...                 # Other language bindings
├── target/
│   └── release/
│       └── bws.exe         # Built CLI tool
├── support/
│   └── schemas/            # Generated schemas
└── package.json            # npm configuration
```

## 🔗 Additional Resources

- [Official Bitwarden Secrets Manager CLI Documentation](https://bitwarden.com/help/secrets-manager-cli/)
- [Access Tokens Guide](https://bitwarden.com/help/access-tokens/)
- [Bitwarden SDK GitHub Repository](https://github.com/bitwarden/sdk-sm)
- [.NET 8.0 Download](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Rust Installation Guide](https://rustup.rs/)

## 📝 Build Order Summary

**Critical:** Always follow this exact order:

1. ✅ Install .NET 8.0 SDK
2. ✅ Install Rust toolchain  
3. ✅ Install Node.js
4. ✅ Run `npm install`
5. ✅ Run `npm run schemas` (generates C# types)
6. ✅ Build Rust components with `cargo build --release`
7. ✅ Build C# SDK with `dotnet build`
8. ✅ Restart VS Code

## 🏷️ Version Information

This guide was tested with:
- Windows 11
- .NET SDK 8.0.414
- Rust 1.90.0
- Node.js 22.18.0
- npm 11.5.2
- Bitwarden SDK v1.0.0

## 📄 License

This guide is provided as-is for educational purposes. The Bitwarden SDK itself is subject to Bitwarden's licensing terms.

---

**💡 Tip:** Bookmark this guide and share it with your team to avoid setup headaches!