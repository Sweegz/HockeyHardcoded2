local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PuckController = require(script.Parent.PuckController2)

local Net = ReplicatedStorage.Net
local CollectEvent = Net:FindFirstChild("Collect") :: RemoteFunction
local DropEvent = Net:FindFirstChild("Drop") :: RemoteEvent

local LocalPlayer = Players.LocalPlayer

local CollectController = {}

function CollectController:Collect(puck: BasePart, pickup: boolean)
	if PuckController:GetOwner(puck) == LocalPlayer then
		return
	end

	task.spawn(function()
		local uuid = puck:GetAttribute("UUID")
		CollectEvent:InvokeServer(uuid, pickup)
	end)
end

function CollectController:Drop(puck: BasePart)
	if puck then
		local uuid = puck:GetAttribute("UUID")
		DropEvent:FireServer(uuid, puck.CFrame)
	end
end

return CollectController
