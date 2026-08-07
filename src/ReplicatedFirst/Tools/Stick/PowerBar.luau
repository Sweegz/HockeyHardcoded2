local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PowerUI = ReplicatedStorage.Power

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

local function getMeterColor(value)
	value = math.clamp(value, 0, 1)

	local GREEN = Color3.fromRGB(0, 255, 0)
	local YELLOW = Color3.fromRGB(255, 255, 0)
	local RED = Color3.fromRGB(255, 40, 0)

	local color

	if value < 0.5 then
		color = GREEN:Lerp(YELLOW, value / 0.5)
	else
		color = YELLOW:Lerp(RED, (value - 0.5) / 0.5)
	end

	return color
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

	bar.BackgroundColor3 = getMeterColor(value)
	bar.Size = UDim2.fromScale(value, 1)
end

function PowerBar:Disable()
	if self.gui then
		self.gui.Enabled = false
	end
	self.enabled = false
end

function PowerBar:Destroy()
	self:Disable()
	if self.gui then
		self.gui:Destroy()
		self.gui = nil
	end
	self.maxPower = nil
	self.enabled = nil
end

return PowerBar
