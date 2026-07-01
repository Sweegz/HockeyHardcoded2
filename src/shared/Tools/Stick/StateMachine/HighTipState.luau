local Constants = require(script.Parent.Parent.Constants)

local HighTipState = {}

HighTipState.__index = HighTipState

function HighTipState.New(stickController)
	local self = {
		name = "HighTipState",
		stickController = stickController,
		timestamp = tick(),
		canCollect = false,
		canDropOthersPuck = false,
		canSprint = true,
	}
	setmetatable(self, HighTipState)

	return self
end

function HighTipState:Enter()
	self.stickController.animator:PlayAnimationByName("HighTip", Constants.FADE_TIME)
end

function HighTipState:Tick(_dt: number)
	local time = tick() - self.timestamp

	if self.stickController.hasPuck then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
	end

	if time < 2 then
		return
	end

	self.stickController.state_machine:ChangeState(
		self.stickController.state_machine.states.DefaultState.New(self.stickController)
	)
end

function HighTipState:Exit()
	self.stickController.animator:StopAnimationByName("HighTip", Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("HighTip")

	self.name = nil
	self.timestamp = nil
	setmetatable(self, nil)
	self = nil
end

return HighTipState
