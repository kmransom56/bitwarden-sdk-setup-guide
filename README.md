# Bitwarden Secrets Manager CLI Usage & Troubleshooting

## Authentication

You must authenticate every CLI command using an access token. You can set the environment variable:

```zsh
export BWS_ACCESS_TOKEN="your-access-token"
```

Or pass the token directly to commands:

```
bws secret create --access-token <ACCESS_TOKEN> <KEY> <VALUE> <PROJECT_ID>
```

## Secret Creation

The correct command format is:

```
bws secret create [--access-token <ACCESS_TOKEN>] <KEY> <VALUE> <PROJECT_ID>
```

Optionally, you can add a note:

```
bws secret create --access-token <ACCESS_TOKEN> <KEY> <VALUE> <PROJECT_ID> --note "API Key for XYZ"
```

## Project Management

List projects you have access to:

```
bws project list --access-token <ACCESS_TOKEN>
```

Create a new project:

```

## Project Permissions and Machine Accounts

**Important:** If you receive `Resource not found (404)` errors when creating secrets, your machine account (the one associated with your access token) may not have access to the target Bitwarden project. You must explicitly add the project to the machine account in the Bitwarden web vault or organization settings.

**Steps to resolve:**
1. Go to your Bitwarden web vault.
2. Navigate to your organization and select the target project.
3. Add your machine account (or service account) as a member of the project.
4. Ensure your access token is generated for the correct account and organization.
5. Retry your CLI or SDK operation.

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more details.
bws project create --access-token <ACCESS_TOKEN> "My Project"
```

## Secret Listing

List all secrets:

```
bws secret list --access-token <ACCESS_TOKEN>
```

List secrets for a specific project:

```
bws secret list --access-token <ACCESS_TOKEN> <PROJECT_ID>
```

## Troubleshooting

- If you get "Resource not found" errors, check:
   - The project ID is valid and accessible to your access token.
   - Your access token has the correct permissions.
- If you get rate limit errors, add delays between requests.

## Other Useful Commands

Get help for any command:

```
bws --help
bws secret --help
bws project --help
```

Check your CLI version:

```
bws --version
```

## Reference

See the [Bitwarden Secrets Manager CLI Documentation](https://bitwarden.com/help/secrets-manager-cli/) for full details.
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
npm --version   # Should show 9+ or 10+

## Cross-Platform Setup Process

### Windows
- Use the PowerShell setup script: `setup-bitwarden-sdk.ps1` (requires PowerShell 7+)
- This script automates installation using `winget` and builds the .NET SDK version.
- Manual steps are also available if you prefer.

### WSL / Linux
- Use the Python setup script: `setup-bitwarden-sdk.py` (requires Python 3)
- This script automates installation and builds the SDK for Linux environments.
- Manual steps are also available if you prefer.
   - **.NET SDK:**
      - Try: `sudo apt-get install dotnet-sdk-8.0`
      - If errors, use official script:
         ```zsh
         wget https://dot.net/v1/dotnet-install.sh
         chmod +x dotnet-install.sh
         ./dotnet-install.sh --version 8.0.100
         export PATH="$HOME/.dotnet:$PATH"
         ```
   - **Rust:**
      - Install: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
      - If permission denied, remove old dirs: `sudo rm -rf ~/.cargo ~/.rustup` and retry
      - Add to PATH: `source $HOME/.cargo/env`
   - **Node.js:**
      - Install: `sudo apt-get install nodejs npm`
      - For latest: use nvm or NodeSource

### Common Steps (All Platforms)
1. Run `npm install`
2. Run `npm run schemas` (generates C# types)
3. Build Rust components:
    - `cd crates/bitwarden-c && cargo build --release`
4. Build C# SDK:
    - `cd languages/csharp && dotnet restore && dotnet build`
5. Restart VS Code if MSBuild errors persist

### Verification
- Run `dotnet build` in `languages/csharp` (expect "Build succeeded")
- Run CLI tool: `target/release/bws.exe --help`

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

#### Set your access token
```zsh
export BWS_ACCESS_TOKEN="your-access-token-here"
```

#### List projects (Linux/WSL)
```zsh
/home/keith/bitwarden-sdk/target/release/bws project list
```

#### Create a secret with OAuth 2.0 Client Credentials (Python example)
```python
import subprocess
import json

api_key = {
   "client_id": "your-client-id",
   "client_secret": "your-client-secret",
   "scope": "api",
   "grant_type": "client_credentials"
}

secret_value = json.dumps(api_key)
cli_path = "/home/keith/bitwarden-sdk/target/release/bws"  # Linux binary
project_id = "fc280c0b-1d9c-4789-b5ff-b3810133de43"  # Example project ID
subprocess.run([
   cli_path,
   "secret", "create", "BitwardenAPI", secret_value, project_id
])
```

#### Create a secret (PowerShell example, Windows)
```powershell
$apiKey = @{
   client_id = "your-client-id"
   client_secret = "your-client-secret"
   scope = "api"
   grant_type = "client_credentials"
} | ConvertTo-Json

& "C:\Projects\bitwarden-sdk\target\release\bws.exe" secret create "BitwardenAPI" $apiKey "your-project-id"
```

#### Run application with secrets as environment variables
```zsh
/home/keith/bitwarden-sdk/target/release/bws run -- your-app-command
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