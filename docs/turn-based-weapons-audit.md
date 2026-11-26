# Auditoria — armas de combate por turnos

Leitura independente dos arquivos gravados no commit 646a218111e44e3be4509f70d0654fdd98e8b1ab: 1.441 condições estruturais e matemáticas verificadas, zero divergências. Foram examinados 118 modelos em três qualidades: perfis de ataque, soma dos golpes, dano em área, progressão, escudos, materiais, reparação, estações e separação de custos. Catálogo anterior preservado, NamedWeapons e Valdoria idênticos por hash. Servidor e catálogo usam o mesmo cálculo; filtros de preço e testes de contagem revisados.

Custo-base de materiais dos cinco modelos econômicos: 13–24 moedas. Premium: 1.810–4.260 moedas. Estoque inicial e preços variáveis seguem a economia existente; não há garantia de venda. Combate ainda não implementado: o perfil descreve uma ação, sem crítico, acerto, resistência, regras de mão secundária ou seleção de alvos em execução. Escudos não atacam. A área não repete todos os golpes em todos os inimigos: cada secundário recebe um golpe de dano calculado.

Testes Luau adicionados à suíte de Studio, mas não executados aqui; validação real de interface, Rojo e motor Roblox continua pendente.
