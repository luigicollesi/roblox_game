# Teste prático — economia

Execute `git pull origin main`, `rojo build -o Valdoria.rbxlx`, abra o arquivo e pressione F5. Em Output procure os testes de navegação e de economia OK. A UI continua genérica.

1. Rua Central → Comercial → Mercado Central → Salão comercial. Abra serviços econômicos. Veja moedas, estoques; compre 5 minérios de ferro e 5 troncos de carvalho. Confira o inventário. Venda e recompre materiais; não deve surgir lucro na ida e volta.
2. Artesanal → Guilda de Produtores → Recepção. Busque "Espada de ferro", aprenda a receita. Maestria 0.
3. Ferraria → Oficina. Alugue forno e transforme minério em barras. Aguarde o tempo indicado e clique Atualizar dados. Verifique que o trabalho só entrega uma vez. Compre barras adicionais se necessário. Carpintaria → Oficina: alugue serragem, processe carvalho.
4. Ferraria → Oficina. Alugue forja e fabrique uma espada (3 ferro + 1 carvalho). Atualize após a duração. Primeiro resultado comum, maestria 5. Fabrique novamente; ao alcançar 10, chance superior desbloqueada.
5. Inventário → Equipar. Equipe a espada, teste as mãos. Use Teste Studio para simular desgaste. Na Ferraria, veja as três modalidades de reparo, escolha uma. Confira consumo e conservação.
6. Mercado → venda a espada após desequipar. Loja de Armas: compare o preço (10% acima da referência marginal). Tente vender na loja: não deve aparecer ação de venda. O estoque deve diminuir ao comprar.
7. Treinamento: verifique a força; tente equipar arma pesada sem requisito suficiente. Cajados e varinhas não exigem atributos.
8. Server & Clients com 2 clientes: compre material em um; atualize o segundo e confirme estoque compartilhado, mas dinheiro e inventário independentes. Uma cotação antiga deve falhar com atualização da tela.
9. Teste novamente a Rua Central, todos os distritos, entradas, retornos e portões. A interface de economia deve fechar e retornar à localização original.
10. Teste tela pequena: rolagem, filtro, abas e paginação. Teste reconexão ao mesmo servidor e reinício (não há persistência entre servidores).

## Limites
Testes automáticos em Studio são cadastrados, não executados no ambiente de autoria. Rojo e motor Roblox precisam ser executados localmente.
