--!strict
local Players = game:GetService("Players")
-- Não dependemos de Character nem de StarterGui.
Players.CharacterAutoLoads = false
local function suppressAvatar(player: Player)
	player.CharacterAdded:Connect(function(character)
		character:Destroy()
	end)
	if player.Character then player.Character:Destroy() end
end
Players.PlayerAdded:Connect(suppressAvatar)
for _, player in Players:GetPlayers() do suppressAvatar(player) end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Validator = require(Shared.world.WorldValidator)
local Protocol = require(Shared.network.Protocol)
Validator.validate()
if RunService:IsStudio() then
	require(script.Parent.tests.NavigationTests).run()
end
local remote = ReplicatedStorage:WaitForChild(Protocol.remoteName)
assert(remote:IsA("RemoteFunction"), "Remote de navegação inválido")
require(script.Parent.services.LocationService).start(remote)
print("[Valdória] Navegação inicializada.")
