local Constants = require(script.Parent.Parent.Constants)

local RaiseHandState = {}

RaiseHandState.__index = RaiseHandState

function RaiseHandState.New(ctx)
	local self = {
		name = "RaiseHandState",
		ctx = ctx,
		timeElapsed = 0,
		canCollect = true,
		canDropOthersPuck = true,
		canSprint = true,
	}
	setmetatable(self, RaiseHandState)

	return self
end

function RaiseHandState:Enter()
	self.ctx.animator:PlayAnimationByName("RaiseHand", Constants.FADE_TIME)
end

function RaiseHandState:Tick(dt: number)
	local commands = self.ctx.input.commands

	if self.ctx:IsHit() then
		self.ctx.state_machine:ChangeState(self.ctx.state_machine.states.DefaultState.New(self.ctx))
		return
	end

	if self.timeElapsed > 0.2 and not commands.RaiseHand then
		self.ctx.state_machine:ChangeState(self.ctx.state_machine.states.DefaultState.New(self.ctx))
		return
	end

	self.timeElapsed += dt
end

function RaiseHandState:Exit()
	self.ctx.animator:StopAnimationByName("RaiseHand", Constants.FADE_TIME)
	local input = self.ctx.input
	input:DisableCommand("ChargePower")
end

function RaiseHandState:Destroy()
	self.name = nil
	self.ctx = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return RaiseHandState
