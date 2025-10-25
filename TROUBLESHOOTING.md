# Troubleshooting Guide

Common issues and solutions when setting up the Bitwarden SDK.

## 🚨 Build and Setup Issues

### Issue: CLI binary not found or not executable

**Symptoms:**
- `bws.exe` not found on Linux/WSL
- `zsh: command not found: bws` or `bws.exe`

**Solution:**
1. On Linux/WSL, the CLI binary is named `bws` (not `bws.exe`).
2. Use the full path to run the CLI:
   ```zsh
   /home/keith/bitwarden-sdk/target/release/bws --help
   ```
3. Add the CLI directory to your PATH for convenience:
   ```zsh
   export PATH="$PATH:/home/keith/bitwarden-sdk/target/release"
   ```
4. If the binary is missing, build it:
   ```zsh
   cd /home/keith/bitwarden-sdk/crates/bws
   cargo build --release
   ```

### Issue: Project ID not found or 404 error when creating secrets

**Symptoms:**
- Error: `[404 Not Found] {"message":"Resource not found." ...}`

**Solution:**
1. Ensure you are using a valid project ID from your Bitwarden organization. You can find it in the web vault or by running:
   ```zsh
   /home/keith/bitwarden-sdk/target/release/bws project list
   ```
2. Example project ID: `fc280c0b-1d9c-4789-b5ff-b3810133de43`
3. Your access token must have permissions for the organization and project.
4. Example Python command to create a secret:
   ```python
   import subprocess, json
   api_key = {
       "client_id": "your-client-id",
       "client_secret": "your-client-secret",
       "scope": "api",
       "grant_type": "client_credentials"
   }
   secret_value = json.dumps(api_key)
   cli_path = "/home/keith/bitwarden-sdk/target/release/bws"
   project_id = "fc280c0b-1d9c-4789-b5ff-b3810133de43"
   subprocess.run([
       cli_path,
       "secret", "create", "BitwardenAPI", secret_value, project_id
   ])
   ```

### Issue: "Failed to find all versions of .NET Core MSBuild" (Windows, WSL, Linux)

**Symptoms:**
```
Microsoft.CodeAnalysis.MSBuild.RemoteInvocationException: 
Failed to find all versions of .NET Core MSBuild. Call to hostfxr_resolve_sdk2.
```

**Solution:**
1. **Windows:** Install .NET 8.0 SDK (not just runtime):
   ```powershell
   winget install Microsoft.DotNet.SDK.8
   ```
2. **WSL/Linux:**
   - Use the Python setup script for automated setup:
     ```zsh
     python3 setup-bitwarden-sdk.py --sdk-path ~/bitwarden-sdk
     ```
   - Or try: `sudo apt-get install dotnet-sdk-8.0`
   - If errors (conflicts, held packages):
     ```zsh
     wget https://dot.net/v1/dotnet-install.sh
     chmod +x dotnet-install.sh
     ./dotnet-install.sh --version 8.0.100
     export PATH="$HOME/.dotnet:$PATH"
     ```
3. Restart VS Code
4. Verify installation:
   ```zsh
   dotnet --list-sdks  # Should show 8.0.x
   ```

### Issue: "cargo: The term 'cargo' is not recognized" or permission denied during Rust install

**Symptoms:**
- Rust build commands fail
- `cargo` command not found
- Permission denied errors for `~/.cargo/bin`

**Solution:**
1. **Windows:**
    - Install Rust:
       ```powershell
       winget install Rustlang.Rust.MSVC
       ```
    - Add to PATH for current session:
       ```powershell
       $env:PATH += ";C:\Program Files\Rust stable MSVC 1.90\bin"
       ```
2. **WSL/Linux:**
    - Install Rust:
       ```zsh
       curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
       ```
    - If you see `Permission denied` for `~/.cargo/bin`, run:
       ```zsh
       sudo rm -rf ~/.cargo ~/.rustup
       curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
       ```
    - Add to PATH:
       ```zsh
       source $HOME/.cargo/env
       ```
3. Restart terminal/VS Code

### Issue: C# build errors about missing types (SecretResponse, ProjectResponse, etc.)

**Symptoms:**
```
error CS0246: The type or namespace name 'SecretResponse' could not be found
```

**Solution:**
1. Generate schemas first:
   ```powershell
   npm install
   npm run schemas
   ```
2. Then build C#:
   ```powershell
   cd "languages\csharp"
   dotnet build
   ```

### Issue: "output path is not a writable directory" during cargo build

**Solution:**
1. Clean and rebuild:
   ```powershell
   cargo clean
   cargo build --release
   ```
2. Run as administrator if needed
3. Check disk space

### Issue: npm/Node.js not found

**Solution:**
1. Install Node.js:
   ```powershell
   winget install OpenJS.NodeJS
   ```
2. Restart terminal
3. Verify:
   ```powershell
   node --version
   npm --version
   ```

## 🔐 Authentication Issues

### Issue: "Access token not found"

**Symptoms:**
- CLI commands fail with authentication errors
- "BWS_ACCESS_TOKEN not set"

**Solution:**
1. Get access token from Bitwarden:
   - Go to https://vault.bitwarden.com
   - Navigate to your organization
   - Go to Secrets Manager → Access Tokens
   - Create new token

2. Set environment variable:
   ```powershell
   $env:BWS_ACCESS_TOKEN = "your-token-here"
   
   # For permanent setting:
   [Environment]::SetEnvironmentVariable("BWS_ACCESS_TOKEN", "your-token", "User")
   ```

### Issue: "Organization not found"

**Solution:**
1. Verify organization ID:
   ```powershell
   # Check your organization settings in Bitwarden vault
   $env:BWS_ORGANIZATION_ID = "your-org-id-here"
   ```
2. Ensure Secrets Manager is enabled for your organization
3. Verify your access token has correct permissions

### Issue: "Invalid access token"

**Solution:**
1. Check token format (should start with `bws_`)
2. Regenerate token in Bitwarden vault
3. Ensure token hasn't expired
4. Verify you have Secrets Manager permissions

## 🌐 Network and Server Issues

### Issue: Connection timeout or network errors

**Solution:**
1. Check network connectivity
2. Configure server URLs:
   ```powershell
   .\bws.exe config server-url https://vault.bitwarden.com
   .\bws.exe config server-api https://api.bitwarden.com
   .\bws.exe config server-identity https://identity.bitwarden.com
   ```
3. Check firewall/proxy settings

### Issue: Self-hosted Bitwarden instance

**Solution:**
1. Configure custom server URLs:
   ```powershell
   .\bws.exe config server-url https://your-bitwarden-server.com
   .\bws.exe config server-api https://your-bitwarden-server.com/api
   .\bws.exe config server-identity https://your-bitwarden-server.com/identity
   ```

## 🛠️ Development Issues

### Issue: IntelliSense not working in VS Code

**Solution:**
1. Ensure C# extension is installed
2. Restart VS Code after building
3. Check `.vscode/settings.json` for correct paths
4. Reload window: Ctrl+Shift+P → "Developer: Reload Window"

### Issue: Debugging doesn't work

**Solution:**
1. Ensure project is built successfully
2. Check `launch.json` configuration
3. Verify environment variables are set
4. Check console for detailed error messages

### Issue: "Project file is not supported"

**Solution:**
1. Update VS Code C# extension
2. Ensure .NET 8.0 SDK is installed
3. Check project file syntax
4. Restart VS Code

## 📦 Package and Dependency Issues

### Issue: npm install fails

**Solution:**
1. Clear npm cache:
   ```powershell
   npm cache clean --force
   ```
2. Delete node_modules and package-lock.json:
   ```powershell
   Remove-Item node_modules -Recurse -Force
   Remove-Item package-lock.json -Force
   npm install
   ```
3. Check Node.js version (should be 18+ or 20+)

### Issue: Rust compilation errors

**Solution:**
1. Update Rust:
   ```powershell
   rustup update
   ```
2. Clear target directory:
   ```powershell
   cargo clean
   ```
3. Check for Windows-specific dependencies
4. Ensure Visual Studio Build Tools are installed

## 🔧 Environment and Configuration

### Issue: PATH variables not persisting

**Solution:**
Set environment variables permanently:
```powershell
# Add Rust to system PATH
$rustPath = "C:\Program Files\Rust stable MSVC 1.90\bin"
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
[Environment]::SetEnvironmentVariable("PATH", "$currentPath;$rustPath", "User")

# Add other useful variables
[Environment]::SetEnvironmentVariable("BWS_ACCESS_TOKEN", "your-token", "User")
```

### Issue: Wrong architecture (x86 vs x64)

**Solution:**
1. Ensure you're using 64-bit versions of all tools
2. Check system architecture:
   ```powershell
   [Environment]::ProcessorArchitecture
   ```
3. Reinstall tools for correct architecture

## 📊 Performance Issues

### Issue: Slow build times

**Solution:**
1. Use release builds when possible:
   ```powershell
   cargo build --release
   ```
2. Increase available memory
3. Close unnecessary applications
4. Use SSD storage if available

### Issue: High memory usage during build

**Solution:**
1. Close other applications
2. Build components separately
3. Use incremental builds
4. Consider cloud-based building for large projects

## 🧪 Testing and Validation

### Issue: Unit tests fail

**Solution:**
1. Ensure all dependencies are built
2. Check test configuration
3. Verify environment variables are set for tests
4. Run tests individually to isolate issues

### Issue: Integration tests fail

**Solution:**
1. Check network connectivity
2. Verify test data and access tokens
3. Ensure test organization exists
4. Check rate limiting

## 📞 Getting Help

If you're still having issues:

1. **Check the logs:**
   ```powershell
   # Enable verbose logging
   $env:RUST_LOG = "debug"
   cargo build
   ```

2. **Search existing issues:**
   - [Bitwarden SDK Issues](https://github.com/bitwarden/sdk-sm/issues)
   - [Community Forums](https://community.bitwarden.com)

3. **Create minimal reproduction:**
   - Start with fresh environment
   - Follow setup steps exactly
   - Document exact error messages

4. **System information to include:**
   ```powershell
   # Gather system info
   dotnet --info
   cargo --version
   node --version
   $PSVersionTable.PSVersion
   ```

## 🔄 Reset Everything

If all else fails, complete reset:

```powershell
# Remove all installed components
winget uninstall Rustlang.Rust.MSVC
winget uninstall Microsoft.DotNet.SDK.8
winget uninstall OpenJS.NodeJS

# Clear environment variables
[Environment]::SetEnvironmentVariable("BWS_ACCESS_TOKEN", $null, "User")
Remove-Item $env:USERPROFILE\.cargo -Recurse -Force -ErrorAction SilentlyContinue

# Start fresh with the setup script
.\setup-bitwarden-sdk.ps1 -Force
```