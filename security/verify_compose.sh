#!/bin/bash
###############################################################################
# RSD-STACK :: COMPOSE INTEGRITY VERIFICATION
# Autor: rsdenck - Ranlens Denck
###############################################################################

set -euo pipefail

COMPOSE_FILE="docker-compose.yml"
TRUST_FILE="security/trust/compose.sha256"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "[INTEGRITY] Verificando integridade do docker-compose.yml..."

if [ ! -f "$COMPOSE_FILE" ]; then
    echo -e "${RED}[CRITICAL] Arquivo docker-compose.yml não encontrado.${NC}"
    exit 1
fi

if [ ! -f "$TRUST_FILE" ]; then
    echo -e "${RED}[CRITICAL] Trust Registry do Compose (compose.sha256) ausente.${NC}"
    exit 1
fi

# Calcula hash atual (ignora espaços e quebras de linha extras para evitar falso-positivo)
CURRENT_HASH=$(sha256sum "$COMPOSE_FILE" | awk '{print $1}')
EXPECTED_HASH=$(cat "$TRUST_FILE" | tr -d ' \n\r')

if [ "$CURRENT_HASH" != "$EXPECTED_HASH" ]; then
    echo -e "${RED}################################################################"
    echo -e "[VIOLAÇÃO DE SEGURANÇA] HASH DO COMPOSE DIVERGENTE!"
    echo -e "Esperado: $EXPECTED_HASH"
    echo -e "Encontrado: $CURRENT_HASH"
    echo -e "################################################################${NC}"
    exit 2
fi

echo -e "${GREEN}[OK] Integridade do docker-compose.yml validada.${NC}"
