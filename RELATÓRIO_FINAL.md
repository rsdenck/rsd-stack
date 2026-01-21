# RSD-STACK :: Stack Completa e Documentada 
 
Conforme solicitado, a RSD-STACK foi finalizada com todos os componentes das stacks ELK, Wazuh e ElasticFlow, respeitando os padrões de volumes, redes e arquitetura PROD. 
 
## 1. Serviços Configurados (docker-compose.yml)
A orquestração agora reflete fielmente a topologia solicitada: 
 
- **ELK Stack:** els-nd01, lgs-pl01, kbn-ui01. 
- **Wazuh Stack:** wzh-mgr01 integrado ao ELK. 
- **ElasticFlow Stack:** efw-col01 (host mode), efw-lgs01 (pipeline), efw-kbn01 (dashboard dedicado na porta 5602). 

## 2. Padrão de Volumes e Redes (PROD)
Os volumes foram renomeados e mapeados conforme a tabela de produção: 
 
- **Volumes:** els_data_01, wzh_mgr_01, lgs_cfg_01, efw_flow_01. 
- **Redes:** elk_net (Bridge), wazuh_net (Bridge), mgmt_net (Bridge). 

## 3. Documentação Atualizada
O arquivo README.md foi atualizado com todas as tabelas de arquitetura, papéis, funções, portas e observações de escala PROD. 
 
## 4. Status da Validação (WSL Ubuntu)
A stack foi iniciada com sucesso no ambiente Linux: 
 
- **els-nd01:** [Saudável] - Senhas resetadas e sincronizadas no .env. 
- **kbn-ui01 / efw-kbn01:** [Saudáveis] - Acessíveis em :5601 e :5602. 
- **wzh-mgr01:** [Saudável] - Operando com capacidades SETUID/SETGID. 
- **efw-col01:** [Saudável] - Rodando em network_mode: host. 

### Senhas Atualizadas (.env): 
 
- **ELASTIC_PASSWORD:** -Nubkk4FNC=iSvlqPGZ- 
- **KIBANA_PASSWORD:** pTaI=i15rGwK=_HwGXwZ 

A stack está pronta para operação e documentada conforme os padrões de soberania e segurança da RSD.
