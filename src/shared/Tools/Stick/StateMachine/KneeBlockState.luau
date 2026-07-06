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
end

function KneeBlockState:Tick(dt: number)
	local commands = self.stickController.input.commands

	if self.stickController.hasPuck then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
		return
	end

	if self.timeElapsed > 1.6 and not commands.KneeBlock then
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

	self.name = nil
	self.timeElapsed = nil
	setmetatable(self, nil)
	self = nil
end

return KneeBlockState
