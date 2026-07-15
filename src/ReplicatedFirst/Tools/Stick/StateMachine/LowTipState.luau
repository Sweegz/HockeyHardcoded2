local Constants = require(script.Parent.Parent.Constants)

local LowTipState = {}

LowTipState.__index = LowTipState

function LowTipState.New(ctx)
	local self = {
		name = "LowTipState",
		ctx = ctx,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = false,
		canSprint = true,
	}
	setmetatable(self, LowTipState)

	return self
end

function LowTipState:Enter()
	self.ctx.animator:PlayAnimationByName("LowTip", Constants.FADE_TIME)
end

function LowTipState:Tick(dt: number)
	if self.ctx:HasPuck() or self.ctx:IsHit() then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	if self.timeElapsed > 2 then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	self.timeElapsed += dt
end

function LowTipState:Exit()
	self.ctx.animator:StopAnimationByName("LowTip", Constants.FADE_TIME)
	local input = self.ctx.input
	input:DisableCommand("LowTip")
end

function LowTipState:Destroy()
	self.name = nil
	self.ctx = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return LowTipState
