# RT-11A — Governança de Recursos de Runtime

Este relatório documenta a implementação da política de governança de recursos da **RSD-Stack**, garantindo a estabilidade do host e prevenindo a exaustão de recursos por containers individuais.

## 1. Política de Limites de CPU

Conforme estabelecido no Contrato Arquitetural, nenhum serviço da stack pode ser executado sem limites explícitos de CPU definidos no arquivo de orquestração (`docker-compose.yml`).

### Limites Atuais por Serviço:
- **rsd-els**: 2.0 CPUs (Foco em processamento de busca e indexação)
- **rsd-lgs**: 1.0 CPU (Foco em processamento de pipelines)
- **rsd-kbn**: 1.0 CPU (Foco em renderização de UI)
- **rsd-wzh**: 2.0 CPUs (Foco em análise de eventos e logs de segurança)
- **rsd-efw**: 1.0 CPU (Foco em coleta de fluxos)

## 2. Validação Automática (CI/CD Gate)

O script de validação `ops/validate-build.sh` foi atualizado para atuar como um gate de integridade:
- **Bloqueio de Build**: Se um novo serviço for adicionado ou um existente for alterado removendo a diretiva `deploy.resources.limits.cpus`, o script retornará erro (Exit 1).
- **Consistência de Pipeline**: Esta validação é executada tanto no `ops/stack-up.ps1` (homologação) quanto nos runners de CI (produção).

## 3. Benefícios da Governança
- **Previsibilidade**: Evita o "efeito vizinho barulhento" (noisy neighbor) no host Linux.
- **Segurança**: Mitiga ataques de negação de serviço (DoS) que visam exaurir o processamento do servidor.
- **Controle de Custos**: Facilita o dimensionamento correto (rightsizing) da infraestrutura de produção.

## 4. Status Final
- **Governança de Recursos**: ATIVA.
- **Validação Automática**: IMPLEMENTADA.
- **Conformidade RT-11A**: 100%.

---
*Gerado em 2026-01-15 por Arquiteto de Plataforma / SRE.*
