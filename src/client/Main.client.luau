--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Protocol = require(Shared.network.Protocol)
local remote = ReplicatedStorage:WaitForChild(Protocol.remoteName)
assert(remote:IsA("RemoteFunction"))
-- Preserva menus e controles de segurança da plataforma; remove apenas a mochila física.
pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) end)
require(script.Parent.ui.LocationScreen).mount(playerGui, remote)
