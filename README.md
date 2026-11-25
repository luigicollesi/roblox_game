# Valdória — Fase 1

Jogo Roblox 100% por interface. Fundação: capital navegável, 6 distritos, 42 estabelecimentos, 69 áreas internas e 4 portões. Sem avatar físico, economia, combate, persistência ou presença social.

## Teste no Roblox Studio (Windows/macOS)

1. Instale [Rojo 7](https://rojo.space/docs/v7/getting-started/installation/) (CLI; plugin opcional para sincronização).
2. No terminal, execute:

```sh
git clone https://github.com/luigicollesi/roblox_game.git
cd roblox_game
rojo build -o Valdoria.rbxlx
```

3. Abra Valdoria.rbxlx no Roblox Studio e pressione **Play (F5)**, não Run.
4. No Output, procure "[Valdória] Testes de domínio: OK" e "[Valdória] Navegação inicializada."
5. Confirme que a UI começa na Rua Central. Navegue para distritos, estabelecimentos, salas e portões.

Para editar ao vivo, execute `rojo serve` e conecte o plugin Rojo no Studio usando um place de teste vazio.

Veja [checklist de teste prático](docs/testing.md), [arquitetura](docs/architecture.md) e [mapa de rotas](docs/world/valdoria.md). As imagens são placeholders nativos; IDs autorizados podem ser configurados em Assets.luau.
