local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local vide = require(ReplicatedStorage.Packages.vide)
local HitTracker = require(ReplicatedStorage.UI.Components.HitTracker)
local PowerBarApp = require(ReplicatedStorage.UI.Components.PowerBarApp)
local StaminaBarApp = require(ReplicatedStorage.UI.Components.StaminaBarApp)
local TeamMenuApp = require(ReplicatedStorage.UI.Components.TeamMenuApp)
local px = require(ReplicatedStorage.UI.px)

local UIController = {}

function UIController:Load()
	vide.mount(function()
		px.mount()
		HitTracker().Parent = Players.LocalPlayer.PlayerGui
		StaminaBarApp().Parent = Players.LocalPlayer.PlayerGui
		TeamMenuApp().Parent = Players.LocalPlayer.PlayerGui
		--PowerBarApp().Parent = Players.LocalPlayer.PlayerGui
	end)
end

return UIController
