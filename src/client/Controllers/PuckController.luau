local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

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

function PuckController:GetInstance(): BasePart
	if Workspace:GetAttribute("CustomReplication") then
		return game.Workspace.Client:FindFirstChild("Puck")
	end
	return Channel:Get("Instance")
end

function PuckController:GetCooldown(): number
	return Channel:Get("Cooldown")
end

return PuckController
