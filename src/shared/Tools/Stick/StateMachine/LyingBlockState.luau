local Constants = require(script.Parent.Parent.Constants)

local LyingBlockState = {}

LyingBlockState.__index = LyingBlockState

function LyingBlockState.New(ctx)
	local self = {
		name = "LyingBlockState",
		ctx = ctx,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = false,
		canSprint = false,
	}
	setmetatable(self, LyingBlockState)

	return self
end

function LyingBlockState:Enter()
	self.ctx.animator:StopAnimationByName("Idle", Constants.FADE_TIME)
	self.ctx.animator:PlayAnimationByName("LyingBlock", Constants.FADE_TIME)

	self.ctx.movementDisabled = true
	self.ctx.humanoid.WalkSpeed = 0
end

function LyingBlockState:Tick(dt: number)
	local commands = self.ctx.input.commands

	if self.ctx:HasPuck() or self.ctx:IsHit() then
		self.ctx.state_machine:ChangeState(self.ctx.state_machine.states.DefaultState.New(self.ctx))
		return
	end

	if self.timeElapsed > 0.8 then
		self.ctx.animator:AdjustSpeedByName("LyingBlock", 0)
	end

	if self.timeElapsed > 1.6 and not commands.LyingBlock then
		self.ctx.state_machine:ChangeState(self.ctx.state_machine.states.DefaultState.New(self.ctx))
		return
	end

	self.timeElapsed += dt
end

function LyingBlockState:Exit()
	self.ctx.animator:StopAnimationByName("LyingBlock", Constants.FADE_TIME)
	local input = self.ctx.input
	input:DisableCommand("LyingBlock")

	self.ctx.movementDisabled = false
end

function LyingBlockState:Destroy()
	self.name = nil
	self.ctx = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return LyingBlockState
