# RSD-STACK :: SUPPLY CHAIN VERIFICATION (POWERSHELL RUNTIME GATE)
# Autor: rsdenck - Ranlens Denck

$TrustRegistry = "security/trust/images.sha256"
$Services = @("els", "lgs", "kbn", "wzh", "efw")

Write-Host "[SUPPLY CHAIN] Iniciando validação criptográfica de imagens..." -ForegroundColor Cyan

$Success = $true

foreach ($Svc in $Services) {
    Write-Host "Validando rdenck/$Svc... " -NoNewline
    
    # 1. Obter Hash esperado do Trust Registry
    $RegistryContent = Get-Content $TrustRegistry
    $ExpectedHashLine = $RegistryContent | Where-Object { $_ -match "^${Svc}:" }
    if (-not $ExpectedHashLine) {
        Write-Host "FALHA: Serviço não encontrado no Trust Registry." -ForegroundColor Red
        $Success = $false
        continue
    }
    $ExpectedHash = $ExpectedHashLine.Split(":")[1].Trim()

    # 2. Obter Digest real da imagem local
    $ImageName = "rdenck/${Svc}:v1.0.0"
    $Digest = docker inspect --format='{{index .RepoDigests 0}}' $ImageName 2>$null
    
    if (-not $Digest) {
        Write-Host "FALHA: Imagem $ImageName não encontrada localmente." -ForegroundColor Red
        $Success = $false
        continue
    }

    $ActualHash = $Digest.Split("@")[1].Replace("sha256:", "").Trim()

    # 3. Comparar
    if ($ExpectedHash -eq $ActualHash) {
        Write-Host "OK (Verified)" -ForegroundColor Green
    } else {
        Write-Host "FALHA: Hash mismatch (Audit Violation)." -ForegroundColor Red
        Write-Host "   Auditado: $ExpectedHash"
        Write-Host "   Execução: $ActualHash"
        $Success = $false
    }
}

if ($Success) {
    Write-Host "[OK] Supply Chain validada com sucesso." -ForegroundColor Green
    exit 0
} else {
    Write-Host "[ERRO] Falha na validação da Supply Chain." -ForegroundColor Red
    exit 1
}
