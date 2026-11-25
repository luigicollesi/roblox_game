# Fase 2 — economia de armas (protótipo de servidor)

## Fluxo disponível

- Mercado Central / Salão comercial: compra e venda de materiais e equipamentos. Lojas especializadas apenas vendem. Estoque e orçamento NPC são finitos e compartilhados pelos clientes do mesmo servidor.
- Guilda de Produtores / Recepção: aprender 60 receitas. Preço de aprendizado: metade do custo-base dos ingredientes, mínimo 5 moedas. Cada fabricação concluída acrescenta 5 de maestria à receita, até 100.
- Ferraria / Oficina: fundição, ligas e forja; Carpintaria / Oficina: madeira e escudos; Curtume / Área de produção: couro; Oficina de Alquimia / Laboratório: lapidação, lâminas de pedra e armas mágicas.
- Lojas de Armas, Armaduras, Suprimentos e balcões de oficinas: venda especializada. Todos os balcões usam um estoque central comum nesta versão, sem estoques separados por estabelecimento.
- Inventário em qualquer localização: materiais, equipamento, maestria e mão principal/secundária. Força inicial 10, moedas 1200. Centro de Treinamento / Área de treinamento físico: +1 força por 10 moedas, provisório. Mágicos sem restrição.
- Aluguel por 300 segundos; 1 ou 5 operações por lote. Apenas um trabalho em andamento por jogador, ingredientes reservados antes de começar. Conclusão no próximo acesso após o prazo, inclusive se mudou de sala ou expirou o aluguel. Processamento não exige receita aprendida.
- Equipamentos: Comum 60%, Superior 120%, Obra-prima 220% do custo de referência dos materiais, com fator de estoque entre 0,85 e 1,05. Raridade e durabilidade separadas. Resultado por unidade usando a maestria atual (aumenta dentro do lote). Equipamento usado vale floor(valor novo * durabilidade atual / máxima).
- Mercado: preço de material responde ao estoque. Compra pelo preço marginal após a retirada; venda pelo preço marginal antes da entrada. Operações inversas no mesmo estado não geram moedas. Loja vende por ceil(preço marginal * 1,1) por unidade, sem comprar do jogador. Lotes somam preços unitários.
- Reparação: ceil(qtd original * desgaste / 2) de cada material estrutural. Pessoal com aluguel, serviço com materiais do jogador + ceil(custo * 0,2), ou completo com materiais retirados do estoque + 20%. Não altera raridade/maestria; restaura 100%.
- Estoques iniciais: 120 unidades brutas e 60 processadas por material, um equipamento comum e um superior por receita, orçamento 100.000 moedas. Não há reposição automática nesta fase. Mercado aceita no máximo 3x estoque-alvo de materiais, 12 armas por receita/raridade, 500 armas no total. Inventário de equipamento limitado a 100. Não há compra NPC ilimitada.
- No Studio exclusivamente, botão "Simular desgaste" no inventário para testar manutenção sem combate.

## Garantias e limites

Servidor usa localização real validada pela navegação, versão de perfil, revisão de mercado, token de cotação e recálculo da ação; cliente não envia preços, raridade, moedas ou materiais. Mutações são síncronas, sem yields. Uma cotação desatualizada é rejeitada e a tela atualizada. Sem persistência nem coordenação entre instâncias: perfis e mercado são mantidos apenas durante a vida do servidor; reconectar ao mesmo servidor conserva o perfil; outro servidor ou reinício reinicializa. Não há economia global, extração, armazéns funcionais, contratos, PvP, combate, leilões ou troca direta. Não publicar como economia definitiva; DataStore e transações entre servidores exigem implementação própria e teste de falhas. Não há compras com Robux nem monetização.
