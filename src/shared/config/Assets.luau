--!strict
-- Campos vazios: a UI apresenta um placeholder nativo, sem depender de assets externos.
-- Para ativar uma imagem genérica autorizada: image = "rbxassetid://123..."
local assets = {
	street = { label = "Rua / distrito", image = "" },
	shop = { label = "Loja / mercado", image = "" },
	tavern = { label = "Taverna", image = "" },
	guild = { label = "Guilda", image = "" },
	workshop = { label = "Oficina", image = "" },
	castle = { label = "Castelo", image = "" },
	church = { label = "Igreja", image = "" },
	training = { label = "Treinamento / arena", image = "" },
	storage = { label = "Armazém", image = "" },
	gate = { label = "Portão", image = "" },
	garden = { label = "Jardim", image = "" },
	interior = { label = "Interior", image = "" },
}
for _, asset in assets do table.freeze(asset) end
return table.freeze(assets)
