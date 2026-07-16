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

Write-Host 'Applying the Kafka Kustomize package...'
Invoke-Kubectl apply -k $manifestDirectory

Write-Host 'Waiting for the KRaft controllers and brokers...'
Invoke-Kubectl -n banking rollout status statefulset/kafka-controller --timeout=$timeout
Invoke-Kubectl -n banking rollout status statefulset/kafka-broker --timeout=$timeout

Write-Host 'Waiting for the idempotent topic bootstrap job...'
Invoke-Kubectl -n banking wait --for=condition=complete job/kafka-topic-bootstrap --timeout=$timeout

Write-Host 'Kafka is ready. Current topics:'
Invoke-Kubectl -n banking exec kafka-broker-0 -- /opt/kafka/bin/kafka-topics.sh --bootstrap-server kafka:9092 --list
