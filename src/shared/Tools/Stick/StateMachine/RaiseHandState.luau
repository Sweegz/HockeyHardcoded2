local Constants = require(script.Parent.Parent.Constants)

local RaiseHandState = {}

RaiseHandState.__index = RaiseHandState

function RaiseHandState.New(stickController)
	local self = {
		name = "RaiseHandState",
		stickController = stickController,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = true,
		canSprint = true,
	}
	setmetatable(self, RaiseHandState)

	return self
end

function RaiseHandState:Enter()
	self.stickController.animator:PlayAnimationByName("RaiseHand", Constants.FADE_TIME)
end

function RaiseHandState:Tick(dt: number)
	local commands = self.stickController.input.commands

	if self.timeElapsed > 0.2 and not commands.RaiseHand then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
		return
	end

	self.timeElapsed += dt
end

function RaiseHandState:Exit()
	self.stickController.animator:StopAnimationByName("RaiseHand", Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("ChargePower")
end

function RaiseHandState:Destroy()
	self.name = nil
	self.stickController = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return RaiseHandState
