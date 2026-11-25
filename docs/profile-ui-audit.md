# Revisão da atualização de perfil e comércio

Releitura independente do commit 0a3093ffc1f4afbffcadcc150313c7899936269d: 21 verificações estruturais aprovadas. Os hashes de Catalog, Rules, Valdoria, NavigationController e LocationService são idênticos aos anteriores. O servidor continua recalculando preços e validando a localização, revisões e cotação. A interface não cria moedas, atributos ou mercadorias.

Correções posteriores: agrupamento de quantidades por material, equipamentos mantidos como instâncias distintas; seleção inicial explícita; mensagens de saldo/estoque insuficiente. Testes Studio adicionados: 230 ações iniciais de compra agrupadas em 175 cartões (26 brutos, 29 processados, 120 equipamentos), perfil inicial e atualizado, loja sem venda, equipamentos de duas mãos e independência do grafo.

A causa do problema observado pelo usuário não foi reproduzida em Studio. A atualização corrige a baixa visibilidade dos serviços e da listagem, elimina abas horizontais e controla explicitamente o canvas pela altura do layout. Nenhum teste de execução do motor ou renderização foi executado no ambiente de autoria. Teste prático em docs/profile-ui.md.
