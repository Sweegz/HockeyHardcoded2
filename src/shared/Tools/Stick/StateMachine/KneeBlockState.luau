local Constants = require(script.Parent.Parent.Constants)

local KneeBlockState = {}

KneeBlockState.__index = KneeBlockState

function KneeBlockState.New(stickController)
	local self = {
		name = "KneeBlock",
		stickController = stickController,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = false,
		canSprint = false,
	}
	setmetatable(self, KneeBlockState)

	return self
end

function KneeBlockState:Enter()
	self.stickController.animator:PlayAnimationByName("KneeBlock", Constants.FADE_TIME)

	self.stickController.movementDisabled = true
	self.stickController.humanoid.WalkSpeed = 0
end

function KneeBlockState:Tick(dt: number)
	local commands = self.stickController.input.commands

	if self.stickController.hasPuck then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
		return
	end

	if self.timeElapsed > 0.8 and not commands.KneeBlock then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
		return
	end

	self.timeElapsed += dt
end

function KneeBlockState:Exit()
	self.stickController.animator:StopAnimationByName("KneeBlock", Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("KneeBlock")

	self.stickController.movementDisabled = false
end

function KneeBlockState:Destroy()
	self.name = nil
	self.stickController = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return KneeBlockState
