# Validação e teste prático

## Testes automáticos

Ao iniciar um servidor no Studio, o validador verifica IDs, conexões, reciprocidade, hierarquia, categorias de assets e alcançabilidade. NavigationTests verifica o inventário de 122 nós/127 arestas, todas as 254 direções e retorno, estado independente de dois jogadores, rota proibida, ID inexistente e revisão desatualizada. Falhas interrompem a inicialização. Não há dados persistentes.

## Teste de integração manual (Studio)

- Play: spawn na Rua Central; nenhuma instância física do avatar; sem tela de seleção.
- Caminho: Rua Central → Comercial → Guilda de Comércio → Recepção → Salão principal → Sala de contratos; voltar pelo mesmo caminho.
- Real → Castelo → Entrada → Pátio → Salão do trono; retorno disponível.
- Comercial → Religioso → Popular → Militar; não precisa retornar à Rua Central.
- Portão Norte/Leste/Oeste/Sul: saída externa indisponível; retorno ao distrito.
- Verificar 4 tavernas, 3 guildas, igreja e centro de treinamento.
- Testar clique rápido e sincronização; UI não permite cliques enquanto espera o servidor.
- No modo Server & Clients, iniciar 2 clientes e navegar apenas com um; outro permanece na Rua Central.
- Device Emulator: tela pequena e toque; rolagem deve tornar todos os botões acessíveis.
- Para teste de rejeição no console cliente de Studio, usar RemoteFunction:InvokeServer("move", "valdoria.real.castelo", 0) a partir da Rua Central. Resposta INVALID_ROUTE, sem alteração; respeitar intervalo de 0,15 s entre pedidos.
- Reentrar: retorna à Rua Central (persistência fora do escopo).

Não publicar antes de executar esses testes no Studio. O ambiente de implementação não executa o motor Roblox.
