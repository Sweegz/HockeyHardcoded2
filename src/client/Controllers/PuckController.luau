local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

function PuckController:GetInstance(): Instance
	return Channel:Get("Instance")
end

function PuckController:GetCooldown(): number
	return Channel:Get("Cooldown")
end

return PuckController
