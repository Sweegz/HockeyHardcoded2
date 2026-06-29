local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui
local LeftBottom = PlayerGui.LeftBottom

local volume = 0

local HudController = {}

function HudController.Start()
	Synchronizer:WaitAndCall(LocalPlayer, function(channel)
		channel:OnChanged("Coins", function(newValue: number, _oldValue: number)
			local CurrencyTextLabel = LeftBottom.Frame:FindFirstChild("Currency")
			CurrencyTextLabel.Text = ("$%*"):format(tostring(newValue))

			local Sound = Instance.new("Sound")
			Sound.Parent = game.Workspace
			Sound.Volume = volume
			Sound.SoundId = "rbxassetid://120891770644830"
			Sound.Ended:Once(function()
				Sound:Destroy()
			end)
			Sound:Play()
		end)
	end)
end

Synchronizer:WaitAndCall(LocalPlayer, function(channel)
	volume = channel:Get("Settings.Sound Effects") and 1 or 0

	channel:OnChanged("Settings.Sound Effects", function(newValue)
		volume = newValue and 1 or 0
	end)
end)

return HudController
