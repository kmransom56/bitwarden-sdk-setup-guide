using System;
using System.IO;
using System.Threading.Tasks;
using Bitwarden.Sdk;

namespace BitwardenSdkExamples
{
    /// <summary>
    /// Basic example showing how to use the Bitwarden C# SDK
    /// </summary>
    public class BasicExample
    {
        public static async Task Main(string[] args)
        {
            // Configuration
            var accessToken = Environment.GetEnvironmentVariable("BWS_ACCESS_TOKEN");
            var organizationIdStr = Environment.GetEnvironmentVariable("BWS_ORGANIZATION_ID");
            
            if (string.IsNullOrEmpty(accessToken))
            {
                Console.WriteLine("❌ Please set BWS_ACCESS_TOKEN environment variable");
                Console.WriteLine("   Get your token from: https://vault.bitwarden.com");
                return;
            }
            
            if (string.IsNullOrEmpty(organizationIdStr) || !Guid.TryParse(organizationIdStr, out var organizationId))
            {
                Console.WriteLine("❌ Please set BWS_ORGANIZATION_ID environment variable");
                Console.WriteLine("   Find your Organization ID in Bitwarden vault settings");
                return;
            }

            Console.WriteLine("🚀 Bitwarden SDK Example");
            Console.WriteLine("========================");

            // Initialize the Bitwarden client
            using var bitwardenClient = new BitwardenClient(new BitwardenSettings
            {
                ApiUrl = "https://api.bitwarden.com",
                IdentityUrl = "https://identity.bitwarden.com"
            });

            try
            {
                // Authenticate
                Console.WriteLine("🔐 Authenticating...");
                var stateFile = Path.GetTempFileName();
                bitwardenClient.Auth.LoginAccessToken(accessToken, stateFile);
                Console.WriteLine("✅ Authentication successful");

                // List projects
                Console.WriteLine("\n📁 Listing projects...");
                var projects = bitwardenClient.Projects.List(organizationId);
                
                if (projects.Data.Any())
                {
                    Console.WriteLine($"Found {projects.Data.Count()} projects:");
                    foreach (var project in projects.Data)
                    {
                        Console.WriteLine($"  📂 {project.Name} (ID: {project.Id})");
                    }
                }
                else
                {
                    Console.WriteLine("No projects found");
                }

                // List secrets
                Console.WriteLine("\n🔑 Listing secrets...");
                var secrets = bitwardenClient.Secrets.List(organizationId);
                
                if (secrets.Data.Any())
                {
                    Console.WriteLine($"Found {secrets.Data.Count()} secrets:");
                    foreach (var secret in secrets.Data)
                    {
                        Console.WriteLine($"  🗝️ {secret.Key} (ID: {secret.Id})");
                    }
                }
                else
                {
                    Console.WriteLine("No secrets found");
                }

                // Create a test project (if none exist)
                if (!projects.Data.Any())
                {
                    Console.WriteLine("\n➕ Creating a test project...");
                    var newProject = bitwardenClient.Projects.Create(organizationId, "SDK Test Project");
                    Console.WriteLine($"✅ Created project: {newProject.Name} (ID: {newProject.Id})");

                    // Create a test secret
                    Console.WriteLine("\n➕ Creating a test secret...");
                    var newSecret = bitwardenClient.Secrets.Create(
                        organizationId,
                        "TestSecret",
                        "This is a test secret value",
                        "Created by SDK example",
                        new[] { newProject.Id }
                    );
                    Console.WriteLine($"✅ Created secret: {newSecret.Key} (ID: {newSecret.Id})");

                    // Retrieve the secret
                    Console.WriteLine("\n🔍 Retrieving the secret...");
                    var retrievedSecret = bitwardenClient.Secrets.Get(newSecret.Id);
                    Console.WriteLine($"📋 Secret Key: {retrievedSecret.Key}");
                    Console.WriteLine($"📋 Secret Value: {retrievedSecret.Value}");
                    Console.WriteLine($"📋 Secret Note: {retrievedSecret.Note}");

                    // Clean up (optional)
                    Console.WriteLine("\n🧹 Cleaning up test data...");
                    bitwardenClient.Secrets.Delete(new[] { newSecret.Id });
                    bitwardenClient.Projects.Delete(new[] { newProject.Id });
                    Console.WriteLine("✅ Cleanup completed");
                }

                Console.WriteLine("\n🎉 Example completed successfully!");
                
                // Clean up temp state file
                if (File.Exists(stateFile))
                {
                    File.Delete(stateFile);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error: {ex.Message}");
                Console.WriteLine("\n💡 Troubleshooting tips:");
                Console.WriteLine("  - Verify your access token is valid");
                Console.WriteLine("  - Check your organization ID");
                Console.WriteLine("  - Ensure you have Secrets Manager permissions");
                Console.WriteLine("  - Verify network connectivity to Bitwarden servers");
            }
        }
    }
}