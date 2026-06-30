local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local PuckController = require(StarterPlayer.StarterPlayerScripts.Controllers.PuckController)
local Power = {}

local LocalPlayer = Players.LocalPlayer

Power.__index = Power

function Power.New(stickController)
	local self = {
		stickController = stickController,
		enabled = false,
		current = 0,
		max = 100,
		rate = 100 / 1.15,
	}
	setmetatable(self, Power)

	return self
end

function Power:Enable()
	self.enabled = true
end

function Power:Tick(dt: number)
	local state = self.stickController.state_machine.state
	local commands = self.stickController.input.commands

	if not self.enabled then
		return
	end

	if not (state.name == "DefaultState") then
		self.current = 0
		return
	end

	if commands.ChargePower then
		self.current = math.min(self.current + self.rate * dt, self.max)
	end

	print(self.current)
end

function Power:Disable()
	self.enabled = false
end

function Power:SetPower(power: number)
	self.current = power
end

function Power:Destroy()
	self:Disable()
	self.enabled = nil
	self.current = nil
	self.max = nil
	self.rate = nil
end

return Power
