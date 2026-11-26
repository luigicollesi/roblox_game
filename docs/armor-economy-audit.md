# Auditoria — economia de armaduras

## Verificações executadas

Releitura independente do commit b656aee790d97c8af668795f0187ebbb2b23c445: 2.325 condições de catálogo e matemática, sem falhas. Foram verificados 212 modelos e 636 combinações de qualidade, nomes únicos, ingredientes processados, reparos, estações, força, defesa, 20 coleções de quatro peças, efeitos lendários, cadeia de transformação sem ciclos e estoque inicial. Mais 13 verificações estruturais da integração e oito comparações de hashes (2.346 verificações no total, todas aprovadas). Arquivos de mapa, navegação, serviço remoto, perfis de ataque e os três módulos anteriores de armas permanecem idênticos. O conteúdo anterior do catálogo também foi preservado antes da extensão.

Custos-base das coleções:
- Econômicas: 28, 96, 96 e 113 moedas.
- Intermediárias: 216–520.
- Avançadas: 932–1.342.
- Elite: 4.724–9.248.
- Lendárias: 35.820–39.918.
- Seis relíquias individuais de armadura: 6.432–11.237 por peça.

## Correções e regressões

A integração usa a validação de cotação e localização existente; armadura não entra nas mãos; venda de peça equipada bloqueada; substituição e quebra removem bônus; quatro espaços distintos; arma de duas mãos não interfere na armadura. A defesa do conjunto é aplicada aos pontos, não como imunidade. O cálculo agrega bônus somente de peças equipadas íntegras, com limiares 2/4 e 4/4 e qualidade independente. Loja de Armas exclui armaduras; Loja de Armaduras inclui escudos; filtro de comércio mantém agrupamento de materiais. Perfil recebe cópia dos espaços e totais calculados no servidor.

Foram adicionados testes Luau de processamento de algodão, fabricação, maestria, equipagem, bloqueio de venda e mãos, troca, quebra, reparação, força, 2+2, conjunto lendário e remoção de feitiço. A revisão final acrescenta cenários de 0 a 4 peças em cada uma das 20 coleções, quebra de peça, combinações de passivas e apresentação das resistências totais no perfil. Os testes antigos continuam na suíte com contagens atualizadas.

## Limites

As verificações executadas foram estruturais/matemáticas em código independente, não execução do motor Luau. Não há Roblox Studio, Rojo ou Luau CLI no ambiente de autoria. Os testes Luau novos e antigos ainda precisam rodar no Studio. Nenhum sistema de combate, vida/mana atuais, persistência ou mercado global foi introduzido. Habilidades de encontro são contratos de dados e helpers, não efeitos já executados em batalha. Capacidade do mercado continua 500 equipamentos (394 iniciais), sem reposição. Consulte armor-economy.md.
