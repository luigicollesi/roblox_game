--!strict
local Types = require(script.Parent.LocationTypes)
local data = require(script.Parent.Valdoria)
type Location = Types.Location
local byId: {[string]: Location} = {}
local all: {Location} = {}
for _, raw in data.nodes do
	local node = raw :: Location
	assert(not byId[node.id], "ID duplicado: " .. node.id)
	table.freeze(node.connections)
	table.freeze(node)
	byId[node.id] = node
	table.insert(all, node)
end
table.freeze(byId)
table.freeze(all)
local Registry = { spawnId = data.spawnId, cityName = data.cityName, all = all }
function Registry.get(id: string): Location?
	return byId[id]
end
function Registry.canMove(from: string, to: string): boolean
	local node = byId[from]
	return node ~= nil and byId[to] ~= nil and table.find(node.connections, to) ~= nil
end
function Registry.breadcrumb(id: string): string
	local parts = {}
	local current = byId[id]
	local visited = {}
	while current do
		assert(not visited[current.id], "Ciclo hierárquico")
		visited[current.id] = true
		table.insert(parts, 1, current.name)
		current = if current.parentId then byId[current.parentId] else nil
	end
	table.insert(parts, 1, data.cityName)
	return table.concat(parts, " / ")
end
return table.freeze(Registry)
