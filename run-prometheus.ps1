[CmdletBinding()]
param(
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

$manifestDirectory = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$timeout = "${TimeoutMinutes}m"

Write-Host 'Checking Kubernetes access and a default StorageClass...'
Invoke-Kubectl version --client
Invoke-Kubectl get storageclass

Write-Host 'Applying the Prometheus Kustomize package...'
Invoke-Kubectl apply -k $manifestDirectory

Write-Host 'Reloading Prometheus with the deployed configuration...'
Invoke-Kubectl -n monitoring rollout restart statefulset/prometheus

Write-Host 'Waiting for Prometheus to become ready...'
Invoke-Kubectl -n monitoring rollout status statefulset/prometheus --timeout=$timeout

Write-Host 'Prometheus is ready at http://localhost:9090 after running:'
Write-Host 'kubectl -n monitoring port-forward service/prometheus 9090:9090'
