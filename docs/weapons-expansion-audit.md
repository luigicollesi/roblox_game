# Auditoria da expansão de armas

Verificação independente a partir dos arquivos gravados no commit ffcfb82dba1acc08e2a81c5bca007f2bbde0316a: 1.140 condições verificadas, nenhuma divergência.

- 60 receitas originais preservadas byte a byte (trecho original do catálogo); 48 novas receitas, 16 famílias, 3 modelos nomeados por família.
- IDs/nomes, estações, materiais processados, quantidades de fabricação e reparação, atributos, peso, força e duração.
- 324 combinações modelo/qualidade verificadas quanto ao cálculo inteiro e progressão não decrescente de atributos, durabilidade crescente.
- Sem requisitos de força para magia; requisito físico somente acima de 4 kg.
- Estatísticas compartilhadas entre servidor e catálogo; validação de cotação e compra/venda mantida.
- Grafo de Valdória, LocationService e NavigationController preservados por hash.
- Testes de integração Luau atualizados para 326 ações/271 cartões iniciais, maestria separada de Lâmina da Vigília e fabricação com bônus.
- Ajuste posterior de UX: seletor expansível de família para acesso direto a qualquer tipo, sem ciclos de 16 cliques.

A auditoria estrutural não executa o motor Roblox nem os testes Luau. Rojo e Luau CLI não estão disponíveis no ambiente de autoria. Execute os testes práticos em weapons-expansion.md. Bônus são atributos calculados de equipamento; combate, efeitos elementais, habilidades, persistência e economia global continuam fora do escopo.
