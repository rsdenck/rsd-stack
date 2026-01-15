# RSD-STACK :: COMPOSE INTEGRITY VERIFICATION (POWERSHELL)
# Autor: rsdenck - Ranlens Denck

$ComposeFile = "docker-compose.yml"
$TrustFile = "security/trust/compose.sha256"

Write-Host "[INTEGRITY] Verificando integridade do docker-compose.yml..." -ForegroundColor Cyan

if (-not (Test-Path $ComposeFile)) {
    Write-Host "[CRITICAL] Arquivo docker-compose.yml não encontrado." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $TrustFile)) {
    Write-Host "[CRITICAL] Trust Registry do Compose (compose.sha256) ausente." -ForegroundColor Red
    exit 1
}

$CurrentHash = (Get-FileHash $ComposeFile -Algorithm SHA256).Hash.ToLower()
$ExpectedHash = (Get-Content $TrustFile).Trim().ToLower()

if ($CurrentHash -ne $ExpectedHash) {
    Write-Host "################################################################" -ForegroundColor Red
    Write-Host "[VIOLAÇÃO DE SEGURANÇA] HASH DO COMPOSE DIVERGENTE!" -ForegroundColor Red
    Write-Host "Esperado: $ExpectedHash" -ForegroundColor Red
    Write-Host "Encontrado: $CurrentHash" -ForegroundColor Red
    Write-Host "################################################################" -ForegroundColor Red
    exit 2
}

Write-Host "[OK] Integridade do docker-compose.yml validada." -ForegroundColor Green
exit 0
