local Constants = require(script.Parent.Parent.Constants)

local StandBlockState = {}

StandBlockState.__index = StandBlockState

function StandBlockState.New(ctx)
	local self = {
		name = "StandBlockState",
		ctx = ctx,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = false,
		canSprint = false,
	}
	setmetatable(self, StandBlockState)

	return self
end

function StandBlockState:Enter()
	self.ctx.animator:PlayAnimationByName("StandBlock", Constants.FADE_TIME)

	self.ctx.movementDisabled = true
	self.ctx.humanoid.WalkSpeed = 0
end

function StandBlockState:Tick(dt: number)
	local commands = self.ctx.input.commands

	if self.ctx:HasPuck() or self.ctx:IsHit() then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	if self.timeElapsed > 0.8 and not commands.StandBlock then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	self.timeElapsed += dt
end

function StandBlockState:Exit()
	self.ctx.animator:StopAnimationByName("StandBlock", Constants.FADE_TIME)
	local input = self.ctx.input
	input:DisableCommand("StandBlock")

	self.ctx.movementDisabled = false
end

function StandBlockState:Destroy()
	self.name = nil
	self.ctx = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return StandBlockState
