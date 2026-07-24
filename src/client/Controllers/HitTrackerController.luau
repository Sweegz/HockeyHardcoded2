local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui
local HitTracker = PlayerGui:WaitForChild("HitTracker")

local HitEntry = ReplicatedStorage:WaitForChild("HitEntry")

type HitData = {
	player: Player,
	hitPlayer: Player,
	hitPart: BasePart,
	power: number,
	distanceHit: number,
	distanceFromPuck: number,
	penalty: boolean,
}

local FrameRegistry = {}

local HitTrackerController = {}

local Channel

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.H then
		HitTracker.Enabled = not HitTracker.Enabled
	end
end)

HitTracker.hittracker.Close.Activated:Connect(function()
	HitTracker.Enabled = false
end)

function HitTrackerController:Start()
	Synchronizer:WaitAndCall("HitTracker", function(channel)
		Channel = channel

		channel:OnDictionaryInserted("Hits", function(data: HitData, key)
			local temp = HitEntry:Clone()
			temp.Parent = HitTracker.hittracker.List

			local output = ("%* hit %*'s %* Power %*%%. Hit Distance: %* studs. Distance from puck: %* studs."):format(
				data.player.Name,
				data.hitPlayer.Name,
				data.hitPart.Name,
				data.power,
				data.distanceHit,
				data.distanceFromPuck
			)

			if data.penalty then
				temp.TextColor3 = Color3.fromRGB(255, 0, 0)
			end

			temp.Text = output
			temp.LayoutOrder = 10000000 - key

			FrameRegistry[key] = temp
		end)

		channel:OnDictionaryRemoved("Hits", function(data: HitData, key)
			local frame = FrameRegistry[key]
			if frame then
				frame:Destroy()
			end
		end)
	end)
end

return HitTrackerController
