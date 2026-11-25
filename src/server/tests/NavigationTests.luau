--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Registry = require(ReplicatedStorage.Shared.world.WorldRegistry)
local Navigation = require(script.Parent.Parent.services.NavigationState)
local Tests = {}
function Tests.run()
	local counts: {[string]: number} = {}
	local edges = 0
	for _, node in Registry.all do
		counts[node.kind] = (counts[node.kind] or 0) + 1
		edges += #node.connections
	end
	assert(#Registry.all == 122 and edges == 254, "Inventário de rotas divergente")
	assert(counts.street == 1 and counts.district == 6 and counts.gate == 4)
	assert(counts.establishment == 42 and counts.room == 69)
	local a = Navigation.new(Registry)
	local b = Navigation.new(Registry)
	assert(a.locationId == "valdoria.central" and a.revision == 0)
	local nextA, code = Navigation.move(Registry, a, "valdoria.comercial", 0)
	assert(not code and nextA.locationId == "valdoria.comercial" and nextA.revision == 1)
	assert(b.locationId == Registry.spawnId and b.revision == 0)
	assert(a.revision == 0)
	local invalid, invalidCode = Navigation.move(Registry, nextA, "valdoria.real.castelo", 1)
	assert(invalid == nextA and invalidCode == "INVALID_ROUTE")
	local stale, staleCode = Navigation.move(Registry, nextA, Registry.spawnId, 0)
	assert(stale == nextA and staleCode == "STALE")
	local unknown, unknownCode = Navigation.move(Registry, nextA, "missing", 1)
	assert(unknown == nextA and unknownCode == "INVALID_ROUTE")
	for _, node in Registry.all do
		local state = {locationId = node.id, revision = 0}
		for _, target in node.connections do
			local moved, err = Navigation.move(Registry, state, target, 0)
			assert(not err and moved.locationId == target and moved.revision == 1)
			local returned, returnErr = Navigation.move(Registry, moved, node.id, 1)
			assert(not returnErr and returned.locationId == node.id and returned.revision == 2)
		end
		if node.kind == "gate" then assert(#node.connections == 1) end
	end
	print("[Valdória] Testes de domínio: OK (122 nós, 254 direções, retornos e isolamento).")
end
return Tests
