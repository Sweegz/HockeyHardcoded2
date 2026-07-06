local Constants = require(script.Parent.Parent.Constants)

local ShoveState = {}

ShoveState.__index = ShoveState

function ShoveState.New(stickController)
	local self = {
		name = "ShoveState",
		stickController = stickController,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = true,
		canSprint = true,
	}
	setmetatable(self, ShoveState)

	return self
end

function ShoveState:Enter()
	self.stickController.animator:PlayAnimationByName("Shove", Constants.FADE_TIME)
end

function ShoveState:Tick(dt: number)
	if self.stickController.hasPuck then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
	end

	if self.timeElapsed > 0.8 then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
		return
	end

	self.timeElapsed += dt
end

function ShoveState:Exit()
	self.stickController.animator:StopAnimationByName("Shove", Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("Shove")

	self.name = nil
	self.timeElapsed = nil
	setmetatable(self, nil)
	self = nil
end

return ShoveState
