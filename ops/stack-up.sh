#!/bin/bash
###############################################################################
# RSD-STACK :: SOVEREIGN RUNTIME GATE (ENTRYPOINT ÚNICO)
# Autor: rsdenck - Ranlens Denck
###############################################################################

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}################################################################"
echo -e "RSD-STACK :: SOVEREIGN RUNTIME CONTROL"
echo -e "################################################################${NC}"

# 1. Gate de Integridade do Compose
if ! bash security/verify_compose.sh; then
    echo -e "${RED}[ABORT] Falha na integridade do arquivo de orquestração.${NC}"
    exit 1
fi

# 2. Gate de Supply Chain
if ! bash security/verify_supply_chain.sh; then
    echo -e "${RED}[ABORT] Falha na validação da cadeia de suprimentos.${NC}"
    exit 2
fi

# 3. Execução Controlada
echo -e "${GREEN}[SUCCESS] Todos os gates criptográficos superados.${NC}"
echo "[DEPLOY] Iniciando rsd-stack em modo Hardened..."

# Força o uso do compose validado
docker-compose -f docker-compose.yml up -d --remove-orphans

echo -e "${GREEN}################################################################"
echo -e "STACK APROVADA PARA PRODUÇÃO — SOVEREIGN RUNTIME CONTROL"
echo -e "################################################################${NC}"
