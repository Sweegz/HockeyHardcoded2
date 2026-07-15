local Constants = require(script.Parent.Parent.Constants)

local HighTipState = {}

HighTipState.__index = HighTipState

function HighTipState.New(ctx)
	local self = {
		name = "HighTipState",
		ctx = ctx,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = false,
		canSprint = true,
	}
	setmetatable(self, HighTipState)

	return self
end

function HighTipState:Enter()
	self.ctx.animator:PlayAnimationByName("HighTip", Constants.FADE_TIME)
end

function HighTipState:Tick(dt: number)
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

function HighTipState:Exit()
	self.ctx.animator:StopAnimationByName("HighTip", Constants.FADE_TIME)
	local input = self.ctx.input
	input:DisableCommand("HighTip")
end

function HighTipState:Destroy()
	self.name = nil
	self.ctx = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return HighTipState
