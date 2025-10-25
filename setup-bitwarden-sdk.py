#!/usr/bin/env python3
import os
import subprocess
import sys
import shutil
from pathlib import Path

SDK_URL = "https://github.com/bitwarden/sdk-sm/releases"
DEFAULT_SDK_PATH = str(Path.home() / "bitwarden-sdk")


def command_exists(cmd):
    return shutil.which(cmd) is not None


def run(cmd, cwd=None, check=True):
    print(f"$ {' '.join(cmd) if isinstance(cmd, list) else cmd}")
    result = subprocess.run(cmd, shell=isinstance(cmd, str), cwd=cwd)
    if check and result.returncode != 0:
        sys.exit(result.returncode)


def prompt(msg):
    input(msg)


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Bitwarden SDK Setup Script (Python)")
    parser.add_argument("--sdk-path", default=DEFAULT_SDK_PATH, help="SDK directory path")
    parser.add_argument("--skip-download", action="store_true", help="Skip SDK download prompt")
    parser.add_argument("--force", action="store_true", help="Force overwrite SDK directory")
    args = parser.parse_args()

    print("\n🔧 Bitwarden SDK Setup Script\n================================\n")

    # Check prerequisites
    print("🔍 Checking prerequisites...")

    # .NET SDK
    if not command_exists("dotnet"):
        print("❌ .NET SDK not found. Please install .NET 8.0 SDK manually.")
        print("   See: https://dotnet.microsoft.com/download/dotnet/8.0")
        sys.exit(1)
    else:
        dotnet_version = subprocess.getoutput("dotnet --version")
        if not dotnet_version.startswith("8."):
            print(f"❌ .NET SDK version is {dotnet_version}. Please install .NET 8.0 SDK.")
            sys.exit(1)
        print(f"✅ .NET SDK found: {dotnet_version}")

    # Rust
    if not command_exists("cargo"):
        print("❌ Rust not found. Please install Rust using:")
        print("   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh")
        sys.exit(1)
    else:
        cargo_version = subprocess.getoutput("cargo --version")
        print(f"✅ Rust found: {cargo_version}")

    # Node.js
    if not command_exists("node") or not command_exists("npm"):
        print("❌ Node.js or npm not found. Please install Node.js and npm.")
        print("   See: https://nodejs.org/")
        sys.exit(1)
    else:
        node_version = subprocess.getoutput("node --version")
        npm_version = subprocess.getoutput("npm --version")
        print(f"✅ Node.js found: {node_version}")
        print(f"✅ npm found: {npm_version}")

    # Setup SDK directory
    sdk_path = Path(args.sdk_path).expanduser().resolve()
    if not args.skip_download:
        print(f"\n4️⃣ Setting up SDK directory at: {sdk_path}")
        if sdk_path.exists():
            if args.force:
                print("🗑️ Removing existing directory...")
                shutil.rmtree(sdk_path)
            else:
                print("⚠️ Directory already exists. Use --force to overwrite.")
                prompt("Press Enter to continue with existing directory or Ctrl+C to cancel")
        if not sdk_path.exists():
            sdk_path.mkdir(parents=True)
        print(f"📁 SDK will be set up at: {sdk_path}")
        print("📥 Please download the latest SDK from:")
        print(f"   {SDK_URL}")
        print(f"   Extract it to: {sdk_path}")
        prompt("\nPress Enter when you've extracted the SDK files")

    # Build SDK components
    print("\n5️⃣ Building SDK components...")
    if sdk_path.exists():
        # npm install
        print("📦 Installing npm dependencies...")
        run(["npm", "install"], cwd=sdk_path)
        # npm run schemas
        print("🔧 Generating schemas...")
        run(["npm", "run", "schemas"], cwd=sdk_path)
        # Build Rust
        print("🦀 Building Rust components...")
        rust_dir = sdk_path / "crates" / "bitwarden-c"
        run(["cargo", "build", "--release"], cwd=rust_dir)
        # Build C#
        print("🏗️ Building C# SDK...")
        csharp_dir = sdk_path / "languages" / "csharp"
        run(["dotnet", "restore"], cwd=csharp_dir)
        run(["dotnet", "build"], cwd=csharp_dir)
        print("\n🎉 Setup completed successfully!")
        print(f"✅ Bitwarden CLI available at: {sdk_path}/target/release/bws.exe")
        print("✅ C# SDK built successfully")
        print("\n💡 You can now open the solution in VS Code:")
        print(f"   code {csharp_dir}/Bitwarden.sln")
    else:
        print(f"❌ SDK directory not found: {sdk_path}")
        sys.exit(1)

    print("\n🚀 Next steps:")
    print("1. Get an access token from your Bitwarden organization")
    print("2. Set environment variable: export BWS_ACCESS_TOKEN='your-token'")
    print("3. Test the CLI: bws.exe --help")
    print("4. Open VS Code and start coding!")

if __name__ == "__main__":
    main()
