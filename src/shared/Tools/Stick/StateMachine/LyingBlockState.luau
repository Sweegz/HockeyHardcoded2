local Constants = require(script.Parent.Parent.Constants)

local LyingBlockState = {}

LyingBlockState.__index = LyingBlockState

function LyingBlockState.New(stickController)
	local self = {
		name = "LyingBlockState",
		stickController = stickController,
		timestamp = tick(),
		canCollect = false,
		canDropOthersPuck = false,
		canSprint = false,
	}
	setmetatable(self, LyingBlockState)

	return self
end

function LyingBlockState:Enter()
	self.stickController.animator:StopAnimationByName("Idle", Constants.FADE_TIME)

	self.stickController.animator:PlayAnimationByName("LyingBlock", Constants.FADE_TIME)
end

function LyingBlockState:Tick(_dt: number)
	local commands = self.stickController.input.commands
	local time = tick() - self.timestamp

	if self.stickController.hasPuck then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
	end

	if time > 0.8 then
		self.stickController.animator:AdjustSpeedByName("LyingBlock", 0)
	end

	if time < 1.6 then
		return
	end

	if not commands.LyingBlock then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
	end
end

function LyingBlockState:Exit()
	self.stickController.animator:StopAnimationByName("LyingBlock", Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("LyingBlock")

	self.name = nil
	self.timestamp = nil
	setmetatable(self, nil)
	self = nil
end

return LyingBlockState
