[CmdletBinding()]
param(
    [System.Security.SecureString]$AdminPassword,
    [ValidateRange(1, 60)]
    [int]$TimeoutMinutes = 10
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-Kubectl {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)

    & kubectl @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "kubectl $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }
}

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    throw 'kubectl is required. Install it, configure a Kubernetes cluster context, then run this script again.'
}

if ($null -eq $AdminPassword) {
    $AdminPassword = Read-Host 'Enter a Grafana admin password' -AsSecureString
}

$manifestDirectory = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$timeout = "${TimeoutMinutes}m"
$plainPassword = [System.Net.NetworkCredential]::new('', $AdminPassword).Password

try {
    Write-Host 'Checking Kubernetes access and a default StorageClass...'
    Invoke-Kubectl version --client
    Invoke-Kubectl get storageclass

    Write-Host 'Creating or updating the Grafana admin secret...'
    Invoke-Kubectl apply -f (Join-Path $manifestDirectory 'namespace.yaml')
    $secretManifest = & kubectl -n monitoring create secret generic grafana-admin `
        --from-literal=admin-user=admin `
        --from-literal="admin-password=$plainPassword" `
        --dry-run=client -o yaml
    if ($LASTEXITCODE -ne 0) {
        throw "Could not build the Grafana admin secret (exit code $LASTEXITCODE)."
    }
    $secretManifest | & kubectl apply -f -
    if ($LASTEXITCODE -ne 0) {
        throw "Could not apply the Grafana admin secret (exit code $LASTEXITCODE)."
    }

    Write-Host 'Applying the Grafana Kustomize package...'
    Invoke-Kubectl apply -k $manifestDirectory

    Write-Host 'Waiting for Grafana to become ready...'
    Invoke-Kubectl -n monitoring rollout status deployment/grafana --timeout=$timeout

    Write-Host 'Grafana is ready at http://localhost:3000 after running:'
    Write-Host 'kubectl -n monitoring port-forward service/grafana 3000:3000'
}
finally {
    $plainPassword = $null
}
