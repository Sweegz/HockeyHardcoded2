local Constants = require(script.Parent.Parent.Constants)

local KneeBlockState = {}

KneeBlockState.__index = KneeBlockState

function KneeBlockState.New(ctx)
	local self = {
		name = "KneeBlock",
		ctx = ctx,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = false,
		canSprint = false,
	}
	setmetatable(self, KneeBlockState)

	return self
end

function KneeBlockState:Enter()
	self.ctx.animator:PlayAnimationByName("KneeBlock", Constants.FADE_TIME)

	self.ctx.movementDisabled = true
	self.ctx.humanoid.WalkSpeed = 0

	local character: Model = self.ctx.humanoid.Parent
	if not character then
		return
	end

	for _, child in character:GetChildren() do
		if child.Name:match("Collider") then
			child.CanCollide = false
		end
	end
end

function KneeBlockState:Tick(dt: number)
	local commands = self.ctx.input.commands

	if self.ctx:HasPuck() or self.ctx:IsHit() then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	if self.timeElapsed > 0.8 and not commands.KneeBlock then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	self.timeElapsed += dt
end

function KneeBlockState:Exit()
	self.ctx.animator:StopAnimationByName("KneeBlock", Constants.FADE_TIME)
	local input = self.ctx.input
	input:DisableCommand("KneeBlock")

	local character: Model = self.ctx.humanoid.Parent
	if not character then
		return
	end

	task.delay(0.2, function()
		for _, child in character:GetChildren() do
			if child.Name:match("Collider") then
				child.CanCollide = true
			end
		end
	end)

	self.ctx.movementDisabled = false
end

function KneeBlockState:Destroy()
	self.name = nil
	self.ctx = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return KneeBlockState
