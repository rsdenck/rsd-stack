#!/bin/bash
###############################################################################
# RSD-STACK :: SUPPLY CHAIN VERIFICATION SCRIPT
# Autor: rsdenck - Ranlens Denck
###############################################################################

set -e

# Configurações
TRUST_REGISTRY="security/trust/hashes.txt"
SERVICES=("els" "lgs" "kbn" "wzh" "efw")
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "----------------------------------------------------------------"
echo "INICIANDO VERIFICAÇÃO DE SUPPLY CHAIN SECURITY - RSD-STACK"
echo "----------------------------------------------------------------"

# 1. Verificar dependências
if ! command -v cosign &> /dev/null; then
    echo -e "${RED}[ERRO] Cosign não instalado.${NC}"
    exit 1
fi

# 2. Validar cada serviço
for SVC in "${SERVICES[@]}"; do
    IMAGE="ghcr.io/rsdenck/rsd-stack/rsd/$SVC:latest"
    echo -n "Validando rsd/$SVC... "

    # A. Verificar Assinatura Cosign
    if ! cosign verify "$IMAGE" \
        --certificate-identity-regexp "https://github.com/rsdenck/rsd-stack/.github/workflows/docker-build.yml" \
        --certificate-oidc-issuer "https://token.actions.githubusercontent.com" &> /dev/null; then
        echo -e "${RED}FALHA (Assinatura Inválida)${NC}"
        exit 2
    fi

    # B. Verificar contra o Trust Registry (Hashes)
    EXPECTED_HASH=$(grep "$SVC:" "$TRUST_REGISTRY" | tail -n 1 | awk '{print $2}')
    ACTUAL_HASH=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE" | cut -d'@' -f2)

    if [ "$EXPECTED_HASH" != "$ACTUAL_HASH" ]; then
        echo -e "${RED}FALHA (Hash Mismatch)${NC}"
        echo "   Esperado: $EXPECTED_HASH"
        echo "   Encontrado: $ACTUAL_HASH"
        exit 3
    fi

    echo -e "${GREEN}OK${NC}"
done

echo "----------------------------------------------------------------"
echo -e "${GREEN}SUCESSO: Todas as imagens são autênticas e confiáveis.${NC}"
echo "----------------------------------------------------------------"
