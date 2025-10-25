import subprocess
import json

api_key = {
    "client_id": "user.cd812054-0420-470d-a616-b35e011f4f26",
    "client_secret": "JdiraACfcjnvx9PzTJOKOwoar4xyDW",
    "scope": "api",
    "grant_type": "client_credentials"
}

secret_value = json.dumps(api_key)
cli_path = "/home/keith/bitwarden-sdk/target/release/bws"  # Linux binary
project_id = "fc280c0b-1d9c-4789-b5ff-b3810133de43"
subprocess.run([
    cli_path,
    "secret", "create", "BitwardenAPI", secret_value, project_id
])
