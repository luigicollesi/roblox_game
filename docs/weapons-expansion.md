# Expansão do catálogo de armas

108 receitas (60 originais + 48 modelos nomeados), 16 famílias, 324 combinações com as três qualidades existentes. Todas as receitas nomeadas podem ser aprendidas independentemente na Guilda de Produtores; fabricação, aluguel, reparação, compra e venda seguem as regras existentes. IDs antigos e ingredientes não foram alterados.

Novas famílias: machado de uma mão, machado de duas mãos, maça, martelo de guerra, lança e alabarda. Três modelos nomeados para cada uma das 16 famílias. Cada modelo tem receita, materiais estruturais de reparo, estação, tempo, peso, força mínima, dano físico/mágico, defesa e durabilidade. Modelos nomeados não são instâncias únicas do mundo: podem ser fabricados repetidamente.

Dano físico = floor((dano base + bônus fixo do modelo) × qualidade / 100). Poder mágico segue a mesma regra. Qualidade: 100%, 115%, 135%; defesa 100%, 110%, 125%; durabilidade 100%, 135%, 180%. Tipo de dano (corte/perfuração/impacto/arcano) é metadado para combate futuro, não existe combate implementado. Descrições de afinidade mágica não concedem habilidades. Sem exigência de atributos para magia; força somente nos equipamentos pesados.

Perfil → Catálogo permite comparar todos os modelos e as três qualidades, independentemente de estoque e aprendizado. Filtro por família e pesquisa. Comércio → Equipamentos permite filtrar família e qualidade; estoque inicial conserva um comum e um superior por receita (216 instâncias); obras-primas surgem por fabricação e revenda, não por estoque inicial. 271 cartões no Mercado Central: 55 materiais e 216 armas, 326 ações de compra. Bônus e qualidade aparecem nas fichas do equipamento. Não foram introduzidos novos materiais, NPCs, estações, imagens ou sistemas de combate.

## Teste prático

1. Atualize e reconstrua com Rojo. Inicie Play; testes automáticos devem passar.
2. Meu perfil → Catálogo: pesquise Lâmina da Vigília e compare as três qualidades; veja receita.
3. Guilda de Produtores: aprenda Lâmina da Vigília (3 ferro, 1 carvalho, 1 couro). A maestria começa em zero, mesmo conhecendo Espada de ferro.
4. Compre materiais, alugue forja e fabrique. Comum: 12 dano (10+2), 120 durabilidade. Compare Superior (13 dano, 162 durabilidade) e Obra-prima (16 dano, 216 durabilidade).
5. Loja de Armas: procure machados, lanças, maças e alabardas. Teste filtro de qualidade. Escudos e magia continuam em lojas apropriadas.
6. Equipar e reparar a arma; verifique requisitos de força nas armas pesadas, e ausência de requisito nos cajados e varinhas.
7. Confirme rotas, preços, aluguel, maestria e perfil existentes. Não publicar sem validação prática.
