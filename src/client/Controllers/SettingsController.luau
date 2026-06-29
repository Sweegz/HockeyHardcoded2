local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Net = ReplicatedStorage.Net
local ToggleSetting = Net:FindFirstChild("ToggleSetting")

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui
local Settings = PlayerGui.Settings

local function ButtonEnabled(enabled: boolean)
	local SFXButton = Settings.Frame:FindFirstChild("SFXButton")
	SFXButton.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end

local SettingsController = {}

function SettingsController.Start()
	local SFXButton = Settings.Frame:FindFirstChild("SFXButton")
	SFXButton.Activated:Connect(function()
		local _success, _message = ToggleSetting:InvokeServer("Sound Effects")
	end)
end

Synchronizer:WaitAndCall(LocalPlayer, function(channel)
	ButtonEnabled(channel:Get("Settings.Sound Effects"))

	channel:OnChanged("Settings.Sound Effects", function(newValue)
		ButtonEnabled(newValue)
	end)
end)

return SettingsController
