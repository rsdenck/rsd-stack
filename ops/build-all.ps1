# RSD-STACK :: Build All for Windows (PowerShell)
# Este script garante a ordem de build determinística da stack no Windows.

$Version = if ($args[0]) { $args[0] } else { "v1.0.0" }
$Namespace = "rdenck"

Write-Host "################################################################" -ForegroundColor Cyan
Write-Host "RSD-STACK :: SOVEREIGN BUILD PROCESS (Version: $Version)" -ForegroundColor Cyan
Write-Host "################################################################" -ForegroundColor Cyan

# 1. Build da Base Image
Write-Host "`n[1/6] Building ${Namespace}/base-runtime:12..." -ForegroundColor Cyan
docker build -t "${Namespace}/base-runtime:12" docker/base-runtime/

if ($LASTEXITCODE -ne 0) { Write-Error "Falha no build da base-runtime"; exit 1 }

# 2. Build dos serviços
$Services = @("els", "lgs", "kbn", "wzh", "efw")
$Count = 2

foreach ($Svc in $Services) {
    Write-Host "`n[$Count/6] Building ${Namespace}/${Svc}:${Version}..." -ForegroundColor Cyan
    docker build -t "${Namespace}/${Svc}:${Version}" "docker/$Svc/"
    if ($LASTEXITCODE -ne 0) { Write-Error "Falha no build de $Svc"; exit 1 }
    $Count++
}

Write-Host "`n✔ Build de todas as imagens concluído com sucesso!" -ForegroundColor Green
