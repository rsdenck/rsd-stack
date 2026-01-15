#!/bin/bash
###############################################################################
# RSD-STACK :: SUPPLY CHAIN VERIFICATION (RUNTIME GATE)
# Autor: rsdenck - Ranlens Denck
###############################################################################

set -euo pipefail

TRUST_REGISTRY="security/trust/images.sha256"
SERVICES=("els" "lgs" "kbn" "wzh" "efw")
GH_REPO="rsdenck/rsd-stack"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "[SUPPLY CHAIN] Iniciando validação criptográfica de imagens..."

# 1. Verificar dependências
if ! command -v cosign &> /dev/null; then
    echo -e "${RED}[ERRO] Cosign não instalado no host de execução.${NC}"
    exit 1
fi

# 2. Validar cada serviço declarado
for SVC in "${SERVICES[@]}"; do
    IMAGE="ghcr.io/${GH_REPO}/rsd/${SVC}:latest"
    echo -n "Validando rsd/${SVC}... "

    # A. Verificar Assinatura Cosign (Keyless/OIDC)
    if ! cosign verify "$IMAGE" \
        --certificate-identity-regexp "https://github.com/${GH_REPO}/.github/workflows/docker-build.yml" \
        --certificate-oidc-issuer "https://token.actions.githubusercontent.com" &> /dev/null; then
        echo -e "${RED}FALHA: Assinatura não confiável ou ausente.${NC}"
        exit 2
    fi

    # B. Verificar contra o Trust Registry (Hash travado)
    EXPECTED_HASH=$(grep "^${SVC}:" "$TRUST_REGISTRY" | cut -d':' -f2)
    
    # Obtém o digest real da imagem local ou remota
    ACTUAL_HASH=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE" 2>/dev/null | cut -d'@' -f2 || echo "NOT_FOUND")

    if [ "$ACTUAL_HASH" == "NOT_FOUND" ]; then
        echo -e "${RED}FALHA: Imagem não encontrada localmente.${NC}"
        exit 3
    fi

    if [ "$EXPECTED_HASH" != "$ACTUAL_HASH" ]; then
        echo -e "${RED}FALHA: Hash mismatch (Audit Violation).${NC}"
        echo "   Auditado: $EXPECTED_HASH"
        echo "   Execução: $ACTUAL_HASH"
        exit 4
    fi

    echo -e "${GREEN}OK (Verified)${NC}"
done

echo -e "${GREEN}[OK] Supply Chain validada com sucesso.${NC}"
