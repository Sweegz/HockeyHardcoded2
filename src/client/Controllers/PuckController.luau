local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

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
	print("Collect!")
end

return PuckController
