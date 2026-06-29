local Constants = require(script.Parent.Parent.Constants)

local LowTipState = {}

LowTipState.__index = LowTipState

function LowTipState.New(stickController)
	local self = {
		name = "LowTipState",
		stickController = stickController,
		timestamp = tick(),
		canCollect = false,
		canDropOthersPuck = false,
		canSprint = true,
	}
	setmetatable(self, LowTipState)

	return self
end

function LowTipState:Enter()
	self.stickController.animator:PlayAnimationByName("LowTip", Constants.FADE_TIME)
end

function LowTipState:Tick(_dt: number)
	local time = tick() - self.timestamp

	if time < 1.6 then
		return
	end

	self.stickController.state_machine:ChangeState(
		self.stickController.state_machine.states.DefaultState.New(self.stickController)
	)
end

function LowTipState:Exit()
	self.stickController.animator:StopAnimationByName("LowTip", Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("LowTip")

	self.name = nil
	self.timestamp = nil
	setmetatable(self, nil)
	self = nil
end

return LowTipState
