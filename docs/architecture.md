# Fase 1 — arquitetura

Capital estática, grafo explícito, navegação instantânea. Hierarquia não autoriza deslocamento. Ruas dos distritos são representadas por seu próprio nó; estabelecimentos têm um nó de entrada e interiores conectados em sequência (retorno sempre disponível). Portões terminam dentro da capital. Sem persistência, sem economia ou interação social.

Grafo inicial: 122 nós, 127 conexões bidirecionais, 69 áreas internas, 42 estabelecimentos, 16 rotas entre regiões. Cada jogador tem estado próprio no servidor. IDs não dependem do texto exibido; os IDs já cadastrados não devem mudar.
