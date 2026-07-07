local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local PowerBar = require(script.Parent.PowerBar)
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

	self:Initialize()

	return self
end

function Power:Initialize()
	self.UI = PowerBar.New(self.max)
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
	else
		self:SetPower(0)
	end
end

function Power:Enable()
	self:SetPower(0)
	self.enabled = true

	-- Enable PowerBar
	if self.UI then
		self.UI:Enable()
	end
end

function Power:Tick(dt)
	if not self.enabled then
		return
	end

	local state = self.stickController.state_machine.state

	if not state.canCharge then
		if not state.freezePower then
			self:SetPower(0)
		end
		return
	end

	local commands = self.stickController.input.commands

	local powerReleased = (self.current > 0 and not commands.ChargePower)
	local powerExceededTime = (self.current >= 100 and commands.ChargePower and commands.ChargePower < tick() - 1.45)

	if powerReleased or powerExceededTime then
		if state:TransitionFinished() and state.canCharge then
			self:Release()
		end
	elseif commands.ChargePower then
		self:SetPower((math.min(self.current + self.rate * dt, self.max)))
	end
end

function Power:Disable()
	self:SetPower(0)
	self.enabled = false

	-- Disable PowerBar
	if self.UI then
		self.UI:Disable()
	end
end

function Power:SetPower(power: number)
	self.current = power

	-- Update PowerBar
	if self.UI then
		self.UI:Update(self.current)
	end
end

function Power:Destroy()
	self:Disable()

	if self.UI then
		self.UI:Destroy()
	end

	self.enabled = nil
	self.current = nil
	self.max = nil
	self.rate = nil
end

return Power
