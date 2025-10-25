import subprocess
import os

# Set your secret key name and project ID
SECRET_KEY = "OPENAI_API_KEY"  # Change as needed
PROJECT_ID = "fc280c0b-1d9c-4789-b5ff-b3810133de43"  # Use your actual project ID
ACCESS_TOKEN = os.environ.get("BWS_ACCESS_TOKEN")
if not ACCESS_TOKEN:
    raise RuntimeError("BWS_ACCESS_TOKEN environment variable is not set.")

cmd = [
    "bws", "secret", "get",
    "--access-token", ACCESS_TOKEN,
    SECRET_KEY,
    PROJECT_ID
]
result = subprocess.run(cmd, capture_output=True, text=True)
if result.returncode != 0:
    print(f"Error fetching secret: {result.stderr.strip()}")
else:
    print(f"Value for {SECRET_KEY}: {result.stdout.strip()}")
