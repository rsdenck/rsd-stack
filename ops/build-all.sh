#!/bin/bash
# RSD-STACK :: Sovereign Build All
# Este script garante a ordem de build determinística da stack.
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuração de Versão
VERSION=${1:-"v1.0.0"}

echo -e "${CYAN}################################################################"
echo -e "RSD-STACK :: SOVEREIGN BUILD PROCESS (Version: $VERSION)"
echo -e "################################################################${NC}"

# 1. Build da Base Image (Fundamental)
echo -e "\n[1/6] Building rdenck/base-runtime:12..."
docker build -t rdenck/base-runtime:12 docker/base-runtime/

# 2. Build dos serviços (Dependem da base-runtime)
SERVICES=("els" "lgs" "kbn" "wzh" "efw")
COUNT=2
for SVC in "${SERVICES[@]}"; do
    echo -e "\n[$COUNT/6] Building rdenck/${SVC}:${VERSION}..."
    docker build -t "rdenck/${SVC}:${VERSION}" "docker/${SVC}/"
    COUNT=$((COUNT+1))
done

echo -e "\n${GREEN}✔ Build de todas as imagens concluído com sucesso!${NC}"
