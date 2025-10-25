param(
    [string]$SecretKey = "OPENAI_API_KEY",
    [string]$ProjectId = "fc280c0b-1d9c-4789-b5ff-b3810133de43"
)

if (-not $env:BWS_ACCESS_TOKEN) {
    Write-Error "BWS_ACCESS_TOKEN environment variable is not set."
    exit 1
}

$bwsPath = "bws"  # Assumes bws is in your PATH
$result = & $bwsPath secret get --access-token $env:BWS_ACCESS_TOKEN $SecretKey $ProjectId
if ($LASTEXITCODE -ne 0) {
    Write-Error "Error fetching secret: $result"
} else {
    Write-Output "Value for $SecretKey: $result"
}
