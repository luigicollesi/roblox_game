--!strict
-- Lógica pura: sem remotes, sem espera, sem dependência de Player.
local NavigationState = {}
export type State = { locationId: string, revision: number }
export type Graph = { spawnId: string, canMove: (string, string) -> boolean }
function NavigationState.new(graph: Graph): State
	return {locationId = graph.spawnId, revision = 0}
end
function NavigationState.move(graph: Graph, state: State, destination: string, expectedRevision: number): (State, string?)
	if expectedRevision ~= state.revision then return state, "STALE" end
	if not graph.canMove(state.locationId, destination) then return state, "INVALID_ROUTE" end
	return { locationId = destination, revision = state.revision + 1 }, nil
end
return NavigationState
