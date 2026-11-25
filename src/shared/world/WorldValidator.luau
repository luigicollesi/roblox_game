--!strict
local Registry = require(script.Parent.WorldRegistry)
local Assets = require(script.Parent.Parent.config.Assets)
local Validator = {}
function Validator.validate()
	local kinds = {street = true, district = true, gate = true, establishment = true, room = true}
	assert(Registry.get(Registry.spawnId), "Spawn inexistente")
	for _, node in Registry.all do
		assert(kinds[node.kind], "Tipo inválido: " .. node.id)
		assert((Assets :: any)[node.assetKey], "Asset desconhecido: " .. node.id)
		assert(#node.connections > 0, "Local isolado: " .. node.id)
		local seen = {}
		for _, target in node.connections do
			assert(target ~= node.id and not seen[target], "Conexão inválida: " .. node.id)
			seen[target] = true
			assert(Registry.get(target), "Destino inexistente: " .. target)
			assert(Registry.canMove(target, node.id), "Rota sem retorno: " .. node.id)
		end
		if node.parentId then
			local parent = assert(Registry.get(node.parentId), "Pai inexistente")
			assert((node.kind == "room" and parent.kind == "establishment") or (node.kind == "establishment" and parent.kind == "district"), "Hierarquia inválida: " .. node.id)
		else
			assert(node.kind ~= "room" and node.kind ~= "establishment", "Pai obrigatório")
		end
		Registry.breadcrumb(node.id)
	end
	local seen = {[Registry.spawnId] = true}
	local queue = {Registry.spawnId}
	local i = 1
	while i <= #queue do
		local node = assert(Registry.get(queue[i]))
		i += 1
		for _, target in node.connections do
			if not seen[target] then
				seen[target] = true
				table.insert(queue, target)
			end
		end
	end
	assert(#queue == #Registry.all, "Local inacessível a partir do spawn")
end
return Validator
