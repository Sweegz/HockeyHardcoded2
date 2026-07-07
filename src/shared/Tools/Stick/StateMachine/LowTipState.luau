local Constants = require(script.Parent.Parent.Constants)

local LowTipState = {}

LowTipState.__index = LowTipState

function LowTipState.New(stickController)
	local self = {
		name = "LowTipState",
		stickController = stickController,
		timeElapsed = 0,
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

function LowTipState:Tick(dt: number)
	if self.timeElapsed > 2 then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
		return
	end

	self.timeElapsed += dt
end

function LowTipState:Exit()
	self.stickController.animator:StopAnimationByName("LowTip", Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("LowTip")
end

function LowTipState:Destroy()
	self.name = nil
	self.stickController = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return LowTipState
