$apiKey = @{
    client_id = "user.cd812054-0420-470d-a616-b35e011f4f26"
    client_secret = "JdiraACfcjnvx9PzTJOKOwoar4xyDW"
    scope = "api"
    grant_type = "client_credentials"
    project_id = "fc280c0b-1d9c-4789-b5ff-b3810133de43"
} | ConvertTo-Json

& "/home/keith/bitwarden-sdk/target/release/bws.exe" secret create "BitwardenAPI" $apiKey
