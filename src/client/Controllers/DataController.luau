local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")

local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

local LocalPlayer = Players.LocalPlayer

local DataController = {}

function DataController.Load()
	Synchronizer:WaitAndCall(LocalPlayer, function(channel)
		DataController.Channel = channel
		ReplicatedFirst:SetAttribute("DataLoaded", true)
		print("Loaded!")
	end)
end

return DataController
