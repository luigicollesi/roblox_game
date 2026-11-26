# Equipamentos para combate por turnos

118 receitas, 354 combinações de modelo e qualidade, 16 famílias. Foram adicionados cinco modelos econômicos e cinco premium sem alterar as 108 receitas anteriores.

## Contrato de ataque
Uma ação básica tem N golpes consecutivos no alvo principal. Dano físico ou mágico existente representa o total bruto dessa ação, não dano de cada golpe. Divide-se em inteiros com resto nos primeiros golpes. Área: até N inimigos distintos (incluindo principal), cada alvo adicional recebe um único golpe de floor(total * splashPct / 100). Máximo teórico pressupõe todos os alvos disponíveis e todos os golpes acertando. Escudo não tem ataque básico. Qualidade aumenta dano/durabilidade/defesa mas não concede golpes nem alvos extras. Atributos de personagem, acerto, crítico, defesa inimiga, efeitos, custo de ação e dual wield ainda não fazem parte da resolução.

Perfis por família, exceções por ID de receita e overrides explícitos nos dez novos modelos. Dados exibidos no catálogo e no comércio e perfil pelo mesmo cálculo usado pelo servidor. Ordenação de preço crescente/decrescente. Preços continuam ancorados nos custos dos materiais; não há multiplicador de luxo adicional.

## Testar
Meu perfil → Catálogo: Ponta Rústica (2 golpes, total 3), Cometa Partido (3 golpes, total 33), Eclipse Imperial (1 golpe, até 3 alvos, 80 no principal, 52 em cada adicional), Constelação Eterna (2 golpes, até 4 alvos, total 100 no principal, 45 por adicional), Cidadela Eterna (defesa 65 sem ataque). Compare as três qualidades. Mercado: ordene preços, compre uma arma barata e confira a mesma ficha no inventário. Aprenda e fabrique uma receita nova, confirme maestria independente. Teste lojas sem venda, reparos e força. Estoque inicial: 236 equipamentos, 291 cartões e 346 ações de compra. Sem motor de combate, sem persistência global.

Os testes Luau rodam no Studio; não foram executados no ambiente de autoria.
