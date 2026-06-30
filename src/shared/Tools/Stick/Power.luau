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
	self.current = 0
	self.enabled = true
end

function Power:Release()
	local owner = PuckController:GetOwner()

	if owner == LocalPlayer then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.ShotState.New(self.stickController)
		)
	elseif self.current > 30 then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.CheckState.New(self.stickController)
		)
	end

	self.current = 0
end

function Power:Tick(dt)
	if not self.enabled then
		return
	end

	local state = self.stickController.state_machine.state

	if not state.canCharge then
		self.current = 0
		return
	end

	local commands = self.stickController.input.commands

	local powerReleased = (self.current > 0 and not commands.ChargePower)
	local powerExceededTime = (self.current >= 100 and commands.ChargePower and commands.ChargePower < tick() - 1.45)

	if powerReleased or powerExceededTime then
		self:Release()
	elseif commands.ChargePower then
		self.current = math.min(self.current + self.rate * dt, self.max)
	end
end

function Power:Disable()
	self.current = 0
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
