local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local PowerBar = require(script.Parent.PowerBar)
local PuckController = require(StarterPlayer.StarterPlayerScripts.Controllers.PuckController)
local Power = {}

local LocalPlayer = Players.LocalPlayer

Power.__index = Power

function Power.New(ctx)
	local self = {
		ctx = ctx,
		enabled = false,
		chargeValue = 0,
		holdStartTime = 0,
	}
	setmetatable(self, Power)

	self:Initialize()

	return self
end

function Power:Initialize()
	self.UI = PowerBar.New()
end

function Power:Release(chargeValue: number)
	local owner = PuckController:GetOwner()

	if owner == LocalPlayer then
		self.ctx.state_machine:ChangeState(self.ctx.state_machine.states.ShotState.New(self.ctx))
	elseif chargeValue > 30 then
		self.ctx.state_machine:ChangeState(self.ctx.state_machine.states.CheckState.New(self.ctx))
	end

	self.holdStartTime = 0
end

function Power:Enable()
	self.enabled = true
	self.holdStartTime = 0

	-- Enable UI
	if self.UI then
		self.UI:Enable()
	end
end

function Power:Tick(dt)
	if not self.enabled then
		return
	end

	local state = self.ctx.state_machine.state

	if not state.canCharge then
		self.holdStartTime = 0
		return
	end

	local commands = self.ctx.input.commands

	if commands.ChargePower and self.holdStartTime == 0 then
		self.holdStartTime = time()
	end

	if self.holdStartTime > 0 then
		local chargeTime = time() - self.holdStartTime

		local powerReleased = not commands.ChargePower
		local powerExceededTime = commands.ChargePower and chargeTime >= 1.45

		if self.UI then
			self.UI:Enable()
			self.UI:Update(chargeTime / 1.45)
		end

		if chargeTime > 1.15 then
			chargeTime = 1.15
		end

		self.chargeValue = (chargeTime / 1.15) * 100

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
	self.holdStartTime = 0

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

	self.chargeValue = nil
	self.holdStartTime = 0

	self.enabled = nil
end

return Power
