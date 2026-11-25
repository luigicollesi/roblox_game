--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Registry = require(Shared.world.WorldRegistry)
local Protocol = require(Shared.network.Protocol)
local Navigation = require(script.Parent.NavigationState)
type Session = { state: Navigation.State, lastMove: number }
local sessions: {[Player]: Session} = {}
local Service = {}
local started = false
local function getSession(player: Player): Session
	local session = sessions[player]
	if not session then
		session = { state = Navigation.new(Registry), lastMove = -math.huge }
		sessions[player] = session
	end
	return session
end
local function response(session: Session, code: string?)
	return { ok = code == nil, code = code, locationId = session.state.locationId, revision = session.state.revision }
end
function Service.start(remote: RemoteFunction)
	assert(not started, "LocationService já iniciado")
	started = true
	Players.PlayerAdded:Connect(getSession)
	Players.PlayerRemoving:Connect(function(player) sessions[player] = nil end)
	for _, player in Players:GetPlayers() do getSession(player) end
	-- Não há yields no processamento: duas requisições não podem intercalar uma mutação.
	remote.OnServerInvoke = function(player: Player, action: unknown, destination: unknown, revision: unknown)
		if player.Parent ~= Players then return {ok = false, code = "DISCONNECTED"} end
		local session = getSession(player)
		if action == "snapshot" then return response(session, nil) end
		if action ~= "move" then return response(session, "INVALID_REQUEST") end
		local now = os.clock()
		if now - session.lastMove < Protocol.moveInterval then return response(session, "RATE_LIMIT") end
		session.lastMove = now
		if type(destination) ~= "string" or #destination == 0 or #destination > Protocol.maxIdLength
			or type(revision) ~= "number" or revision ~= revision or revision < 0 or revision % 1 ~= 0 then
			return response(session, "INVALID_REQUEST")
		end
		local nextState, code = Navigation.move(Registry, session.state, destination, revision)
		session.state = nextState
		return response(session, code)
	end
end
return Service
