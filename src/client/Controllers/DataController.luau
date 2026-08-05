local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")

local Synchronizer = require(ReplicatedStorage.ModdedPackages.Synchronizer)

local LocalPlayer = Players.LocalPlayer

local DataController = {}

function DataController:Load()
	Synchronizer:Wait(LocalPlayer)
	Synchronizer:Wait("Match")

	ReplicatedFirst:SetAttribute("DataLoaded", true)
	ReplicatedFirst:SetAttribute("MatchLoaded", true)
	ReplicatedFirst:SetAttribute("PuckLoaded", true)
	print("Loaded")
end

return DataController
