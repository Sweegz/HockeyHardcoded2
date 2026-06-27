local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")

local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

local LocalPlayer = Players.LocalPlayer

local Channel = nil

return {
	Load = function()
		Synchronizer:WaitAndCall(LocalPlayer, function(channel)
			Channel = channel
			ReplicatedFirst:SetAttribute("DataLoaded", true)
			print("Loaded!")
		end)
	end,
}
