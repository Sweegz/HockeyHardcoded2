local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local vide = require(ReplicatedStorage.Packages.vide)
local HitTracker = require(ReplicatedStorage.UI.Components.HitTracker)

local UIController = {}

function UIController:Load()
	vide.mount(function()
		HitTracker().Parent = Players.LocalPlayer.PlayerGui
	end)
end

return UIController
