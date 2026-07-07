local Constants = require(script.Parent.Parent.Constants)

local HighTipState = {}

HighTipState.__index = HighTipState

function HighTipState.New(stickController)
	local self = {
		name = "HighTipState",
		stickController = stickController,
		timeElapsed = 0,
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

function HighTipState:Tick(dt: number)
	if self.stickController.hasPuck then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
		return
	end

	if self.timeElapsed > 2 then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
		return
	end

	self.timeElapsed += dt
end

function HighTipState:Exit()
	self.stickController.animator:StopAnimationByName("HighTip", Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("HighTip")
end

function HighTipState:Destroy()
	self.name = nil
	self.stickController = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return HighTipState
