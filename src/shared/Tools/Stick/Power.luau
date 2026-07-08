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
		chargeValue = 0,
		max = 100,
		holdStart = 0,
	}
	setmetatable(self, Power)

	self:Initialize()

	return self
end

function Power:Initialize()
	self.UI = PowerBar.New(self.max)
end

function Power:Release(chargeValue: number)
	local owner = PuckController:GetOwner()

	if owner == LocalPlayer then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.ShotState.New(self.stickController)
		)
	elseif chargeValue > 30 then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.CheckState.New(self.stickController)
		)
	end

	self.holdStart = 0
end

function Power:Enable()
	self.enabled = true
	self.holdStart = 0

	-- Enable UI
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
		self.holdStart = 0
		return
	end

	local commands = self.stickController.input.commands

	if commands.ChargePower and self.holdStart == 0 then
		self.holdStart = time()
	end

	if self.holdStart > 0 then
		if self.UI then
			self.UI:Enable()
		end

		local chargeTime = time() - self.holdStart

		local powerReleased = not commands.ChargePower
		local powerExceededTime = commands.ChargePower and time() - self.holdStart >= 1.45

		if chargeTime > 1.15 then
			chargeTime = 1.15
		end

		self.chargeValue = (chargeTime / 1.15) * 100

		self.UI:Update(self.chargeValue)

		if powerReleased or powerExceededTime then
			if state:TransitionFinished() then
				self:Release(self.chargeValue)
			end
		end
	else
		if self.UI then
			self.UI:Disable()
		end
	end
end

function Power:Disable()
	self.enabled = false
	self.holdStart = 0

	-- Disable UI
	if self.UI then
		self.UI:Disable()
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
