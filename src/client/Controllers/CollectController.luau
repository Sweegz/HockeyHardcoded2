local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PuckController = require(script.Parent.PuckController)

local Net = ReplicatedStorage.Net
local CollectEvent = Net:FindFirstChild("Collect") :: RemoteFunction
local DropEvent = Net:FindFirstChild("Drop") :: RemoteEvent

local LocalPlayer = Players.LocalPlayer

local CollectController = {}

function CollectController:Collect()
	if PuckController:GetOwner() == LocalPlayer then
		return
	end

	task.spawn(function()
		CollectEvent:InvokeServer()
	end)
end

function CollectController:Drop()
	DropEvent:FireServer()
end

return CollectController
