local Constants = require(script.Parent.Parent.Constants)

local StandBlockState = {}

StandBlockState.__index = StandBlockState

function StandBlockState.New(stickController)
	local self = {
		name = "StandBlockState",
		stickController = stickController,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = false,
		canSprint = false,
	}
	setmetatable(self, StandBlockState)

	return self
end

function StandBlockState:Enter()
	self.stickController.animator:PlayAnimationByName("StandBlock", Constants.FADE_TIME)
end

function StandBlockState:Tick(dt: number)
	local commands = self.stickController.input.commands

	if self.stickController.hasPuck then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
		return
	end

	if self.timeElapsed > 1.6 and not commands.StandBlock then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
		return
	end

	self.timeElapsed += dt
end

function StandBlockState:Exit()
	self.stickController.animator:StopAnimationByName("StandBlock", Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("StandBlock")

	self.name = nil
	self.timeElapsed = nil
	setmetatable(self, nil)
	self = nil
end

return StandBlockState
