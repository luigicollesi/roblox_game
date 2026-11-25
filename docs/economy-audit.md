# Auditoria — Economia de armas

A verificação independente consistiu na releitura do código armazenado no GitHub, sem reutilizar os objetos de geração do catálogo. O commit c1da05896fd7d030ada82d7e04c5f1c7add09d06 foi verificado com 2.223 condições de catálogo, dependências de processamento, compatibilidade de receitas, materiais de reparo, locais registrados, preços marginais e limites matemáticos. Nenhuma falhou. O commit 356ca02f277e811bfdf035edf7c31c4355fb9aad foi verificado com 16 condições adicionais de integração e proteção, sem falhas; os seis arquivos centrais de navegação e os testes existentes preservaram seus hashes originais.

## Correções e escolhas
- Compra/venda em lotes: soma marginal por unidade, preservando a margem de 10% das lojas e evitando lucro na reversão imediata.
- Cotações de equipamentos contabilizam estoque em um índice por visualização; limite de 500 itens no mercado.
- Inventário reserva capacidade de saída dos trabalhos em andamento; confirmação de conclusão é única.
- Requisições usam localização, revisões de perfil/mercado, token e título de cotação emitido pelo servidor.
- Botões de ação com texto longo ganharam altura maior; receitas mostram componentes e estação antes do aprendizado.
- A interface econômica é um painel separado que retorna à localização sem alterar o grafo. Desgaste artificial é exclusivo do Studio.
- Testes determinísticos de domínio adicionados: raridade, preços, ida/volta, isolamento, localização, produção, reparação, equipamento e cotações obsoletas.

## Limitações de validação
Os 2.239 checks são estruturais/matemáticos, não testes executados no motor Roblox. A suíte Luau foi escrita, mas não executada neste ambiente: Rojo, Luau CLI e Roblox Studio não estão disponíveis, e o acesso de rede do terminal não permite baixar ferramentas. A validação de sintaxe/tipos no motor, a execução dos testes automáticos, o build, a interface e o multiplayer real permanecem pendentes. Consulte economy-testing.md antes de publicar.

Economia de sessão, compartilhada apenas por servidor. Nenhuma promessa de consistência global ou persistência. Nenhum sistema de combate ou mercado P2P foi adicionado.
