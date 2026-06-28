local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

local Net = ReplicatedStorage.Net
local CollectEvent = Net:FindFirstChild("Collect") :: RemoteFunction
local DropEvent = Net:FindFirstChild("Drop") :: RemoteEvent

local LocalPlayer = Players.LocalPlayer

local PuckController = {}

local Channel

function PuckController:Start()
	Synchronizer:WaitAndCall("Puck", function(channel)
		Channel = channel
	end)
end

function PuckController:GetOwner(): Player
	return Channel:Get("Owner")
end

function PuckController:GetInstance(): Instance
	return Channel:Get("Instance")
end

function PuckController:GetCooldown(): number
	return Channel:Get("Cooldown")
end

function PuckController:Collect()
	if PuckController:GetOwner() == LocalPlayer then
		return
	end

	task.spawn(function()
		CollectEvent:InvokeServer()
	end)
end

function PuckController:Drop()
	if PuckController:GetOwner() ~= LocalPlayer then
		return
	end

	DropEvent:FireServer()
end

return PuckController
