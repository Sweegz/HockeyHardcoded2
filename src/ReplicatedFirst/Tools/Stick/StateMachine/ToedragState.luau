local Constants = require(script.Parent.Parent.Constants)

local ToedragState = {}

ToedragState.__index = ToedragState

function ToedragState.New(ctx)
	local self = {
		name = "ToedragState",
		ctx = ctx,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = false,
		canSprint = true,
	}
	setmetatable(self, ToedragState)

	return self
end

function ToedragState:Enter()
	self.ctx.animator:PlayAnimationByName("Toedrag", Constants.FADE_TIME)

	print("Toedrag")
end

function ToedragState:Tick(dt: number)
	if self.ctx:IsHit() then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	if self.timeElapsed > 0.9 then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	self.timeElapsed += dt
end

function ToedragState:Exit()
	self.ctx.animator:StopAnimationByName("Toedrag", Constants.FADE_TIME)
	local input = self.ctx.input
	input:DisableCommand("HighTip")
	--input.commands.GlideLeft = time()

	self.ctx.extended = "Left"
end

function ToedragState:Destroy()
	self.name = nil
	self.ctx = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return ToedragState
