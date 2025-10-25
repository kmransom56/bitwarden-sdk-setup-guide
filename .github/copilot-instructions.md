# Copilot Instructions for Bitwarden SDK Setup Guide

This repository is a setup and troubleshooting guide for the Bitwarden Secrets Manager SDK, focused on Windows environments but useful for cross-platform agents. Follow these instructions to maximize AI productivity:

## Project Overview
- **Purpose:** Help users install, configure, and troubleshoot the Bitwarden SDK and CLI tools.
- **Key Components:**
  - `setup-bitwarden-sdk.ps1`: PowerShell script for automating setup.
  - `examples/BasicExample.cs`: C# usage example.
  - `README.md`: Main setup, build, and troubleshooting guide.
  - `TROUBLESHOOTING.md`: Additional error solutions.


## Essential Workflows

### Cross-Platform Setup Process

#### Windows
- Use `setup-bitwarden-sdk.ps1` with PowerShell 7+ (or follow manual steps below)
- Install dependencies with `winget`:
  - .NET SDK: `winget install Microsoft.DotNet.SDK.8`
  - Rust: `winget install Rustlang.Rust.MSVC`
  - Node.js: `winget install OpenJS.NodeJS`

#### WSL / Linux
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

#### Common Steps (All Platforms)
1. Run `npm install`
2. Run `npm run schemas` (generates C# types)
3. Build Rust components:
   - `cd crates/bitwarden-c && cargo build --release`
4. Build C# SDK:
   - `cd languages/csharp && dotnet restore && dotnet build`
5. Restart VS Code if MSBuild errors persist

#### Verification
- Run `dotnet build` in `languages/csharp` (expect "Build succeeded")
- Run CLI tool: `target/release/bws.exe --help`

## Patterns & Conventions
- **Environment Variables:**
  - `BWS_ACCESS_TOKEN` and `BWS_SERVER_URL` required for CLI/SDK usage
  - Add Rust and .NET to system PATH for builds
- **Schema Generation:**
  - Always run `npm run schemas` after `npm install` before building C# SDK
- **Troubleshooting:**
  - Common issues and fixes are documented in `README.md` and `TROUBLESHOOTING.md`
  - If build errors reference missing types, re-run schema generation

## Integration Points
- **External Dependencies:**
  - .NET 8.0 SDK, Rust toolchain, Node.js
  - Bitwarden SDK downloaded from GitHub releases
- **Cross-Component Communication:**
  - Rust CLI and C# SDK share schemas generated via Node.js scripts

## Examples
- See `examples/BasicExample.cs` for C# SDK usage
- CLI usage patterns in `README.md` (e.g., `bws.exe project list`)

## File References
- `setup-bitwarden-sdk.ps1`: Automates setup steps
- `examples/BasicExample.cs`: C# SDK sample
- `README.md`: Full setup, build, and troubleshooting instructions
- `TROUBLESHOOTING.md`: Error-specific solutions

## Agent Guidance
- Always follow the documented build order—skipping steps leads to errors
- Reference troubleshooting sections for error resolution
- Use provided examples for CLI and SDK usage patterns
- Document only actual, discoverable patterns from the guide

---
For questions or unclear sections, review `README.md` and `TROUBLESHOOTING.md` for authoritative guidance. Suggest improvements if you find missing or outdated instructions.
