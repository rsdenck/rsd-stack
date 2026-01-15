# RSD-STACK :: SOVEREIGN RUNTIME GATE (POWERSHELL ENTRYPOINT)
# Autor: rsdenck - Ranlens Denck

$Banner = "=" * 64
Write-Host $Banner -ForegroundColor Cyan
Write-Host "RSD-STACK :: SOVEREIGN RUNTIME CONTROL" -ForegroundColor Cyan
Write-Host $Banner -ForegroundColor Cyan

# 1. Gate de Integridade do Compose
# Valida se o docker-compose.yml corresponde ao hash versionado em security/trust/
powershell -ExecutionPolicy Bypass -File security/verify_compose.ps1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ABORT] VIOLAÇÃO DE INTEGRIDADE: O arquivo de orquestração foi alterado sem atualização do hash versionado." -ForegroundColor Red
    Write-Host "[HINT] Se a mudança for legítima, atualize security/trust/compose.sha256 com o novo hash." -ForegroundColor Yellow
    exit 1
}

# 1b. Gate de Conformidade Linux (Opcional em homologação, mas recomendado)
Write-Host "[VALIDATION] Verificando conformidade arquitetural (RT-09/RT-11)..." -ForegroundColor Cyan
wsl bash ops/validate-build.sh
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ABORT] FALHA DE CONFORMIDADE: Dockerfiles não seguem o contrato arquitetural." -ForegroundColor Red
    exit 1
}

# 2. Gate de Supply Chain
powershell -ExecutionPolicy Bypass -File security/verify_supply_chain.ps1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ABORT] Falha na validacao da cadeia de suprimentos." -ForegroundColor Red
    exit 2
}

# 3. Execucao Controlada
Write-Host "[SUCCESS] Todos os gates criptograficos superados." -ForegroundColor Green
Write-Host "[DEPLOY] Iniciando rsd-stack em modo Hardened..."

# Forca o uso do compose validado
docker-compose -f docker-compose.yml up -d --remove-orphans

Write-Host $Banner -ForegroundColor Green
Write-Host "STACK APROVADA PARA PRODUCAO - SOVEREIGN RUNTIME CONTROL" -ForegroundColor Green
Write-Host $Banner -ForegroundColor Green
