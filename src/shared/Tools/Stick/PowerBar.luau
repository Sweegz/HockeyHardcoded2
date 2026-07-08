local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UI = ReplicatedStorage.UI
local PowerUI = UI.Power

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local PowerBar = {}

PowerBar.__index = PowerBar

function PowerBar.New()
	local self = {
		enabled = false,
		gui = nil,
	}
	setmetatable(self, PowerBar)

	self:Initialize()

	return self
end

function PowerBar:Initialize()
	self.gui = PowerUI:Clone()
	self.gui.Parent = PlayerGui
end

function PowerBar:Enable()
	self.enabled = true
end

function PowerBar:Update(value: number)
	if self.enabled then
		if value > 0 then
			self.gui.Enabled = true
		else
			self.gui.Enabled = false
		end
	end

	local bar = self.gui.Container.Power.Bar

	bar.Size = UDim2.fromScale(value, 1)
end

function PowerBar:Disable()
	self.gui.Enabled = false
	self.enabled = false
end

function PowerBar:Destroy()
	self:Disable()
	self.gui:Destroy()
	self.gui = nil
	self.maxPower = nil
	self.enabled = nil
end

return PowerBar
