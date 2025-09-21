# Bitwarden CLI Examples

This directory contains examples for using the Bitwarden CLI (bws) tool.

## Prerequisites

1. Set your access token:
   ```powershell
   $env:BWS_ACCESS_TOKEN = "your-access-token-here"
   ```

2. Get your organization ID from Bitwarden vault

## Basic CLI Commands

### List all projects
```powershell
.\bws.exe project list
```

### List all secrets
```powershell
.\bws.exe secret list
```

### Create a new secret
```powershell
.\bws.exe secret create "MySecret" "SecretValue" --note "Optional note"
```

### Get a specific secret
```powershell
.\bws.exe secret get <secret-id>
```

### Create a new project
```powershell
.\bws.exe project create "My Project"
```

### Update a secret
```powershell
.\bws.exe secret edit <secret-id> --key "NewName" --value "NewValue"
```

### Delete a secret
```powershell
.\bws.exe secret delete <secret-id>
```

## Advanced Usage

### Use different output formats
```powershell
# Table format (human-readable)
.\bws.exe secret list --output table

# YAML format
.\bws.exe secret list --output yaml

# Environment variables format
.\bws.exe secret list --output env

# JSON format (default)
.\bws.exe secret list --output json
```

### Run applications with secrets as environment variables
```powershell
# This injects all secrets as environment variables for the command
.\bws.exe run -- dotnet run

# Or run any other command
.\bws.exe run -- python my_script.py
.\bws.exe run -- node app.js
```

### Use configuration files
```powershell
# Configure the CLI
.\bws.exe config server-url https://vault.bitwarden.com
.\bws.exe config server-api https://api.bitwarden.com
.\bws.exe config server-identity https://identity.bitwarden.com

# Use a specific config file
.\bws.exe --config-file custom-config.json secret list

# Use a specific profile
.\bws.exe --profile production secret list
```

## Practical Examples

### Development Workflow
```powershell
# 1. List secrets to see what's available
.\bws.exe secret list --output table

# 2. Run your development server with secrets
.\bws.exe run -- npm start

# 3. Or run your .NET application
.\bws.exe run -- dotnet run --project MyApp.csproj
```

### CI/CD Integration
```powershell
# In your build script, inject secrets for testing
.\bws.exe run -- dotnet test

# Or for deployment
.\bws.exe run -- docker build -t myapp .
```

### Backup/Migration
```powershell
# Export all secrets to a file
.\bws.exe secret list --output json > secrets-backup.json

# Export environment variables format
.\bws.exe secret list --output env > .env.backup
```

## Error Handling

### Common errors and solutions:

1. **"Access token not found"**
   ```powershell
   # Set the token
   $env:BWS_ACCESS_TOKEN = "your-token"
   ```

2. **"Organization not found"**
   - Verify your access token has the correct permissions
   - Check that Secrets Manager is enabled for your organization

3. **"Network error"**
   ```powershell
   # Check server configuration
   .\bws.exe config server-url https://your-bitwarden-server.com
   ```

## Tips and Best Practices

1. **Use environment variables for sensitive data:**
   ```powershell
   # Don't do this (token visible in command history)
   .\bws.exe --access-token "bws_123..." secret list
   
   # Do this instead
   $env:BWS_ACCESS_TOKEN = "bws_123..."
   .\bws.exe secret list
   ```

2. **Use descriptive secret names:**
   ```powershell
   # Good
   .\bws.exe secret create "Database.ConnectionString" "Server=..." --note "Production DB"
   
   # Less clear
   .\bws.exe secret create "secret1" "value1"
   ```

3. **Organize with projects:**
   ```powershell
   # Create projects for different environments
   .\bws.exe project create "Production"
   .\bws.exe project create "Development"
   .\bws.exe project create "Testing"
   ```

4. **Use the `run` command for secure execution:**
   ```powershell
   # Secrets are only available during command execution
   .\bws.exe run -- your-application.exe
   ```

## Getting Help

```powershell
# General help
.\bws.exe --help

# Help for specific commands
.\bws.exe secret --help
.\bws.exe project --help
.\bws.exe run --help
```