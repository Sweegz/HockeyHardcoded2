local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UI = ReplicatedStorage.UI
local PowerUI = UI.Power

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local PowerBar = {}

PowerBar.__index = PowerBar

function PowerBar.New(maxPower: number)
	local self = {
		enabled = false,
		maxPower = maxPower,
		gui = nil,
	}
	setmetatable(self, PowerBar)

	self:Initialize()

	return self
end

function PowerBar:Initialize()
	self.gui = PowerUI:Clone()
	self.gui.Parent = PlayerGui

	print("Init")
end

function PowerBar:Update(value: number)
	local bar = self.gui.Container.Power.Bar

	bar.Size = UDim2.fromScale(value / self.maxPower, 1)
end

function PowerBar:Enable()
	self.gui.Enabled = true
	self.enabled = true
end

function PowerBar:Disable()
	self.gui.Enabled = false
	self.enabled = false
end

function PowerBar:Destroy()
	self:Disable()
end

return PowerBar
