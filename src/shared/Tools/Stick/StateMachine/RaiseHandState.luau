local Constants = require(script.Parent.Parent.Constants)

local RaiseHandState = {}

RaiseHandState.__index = RaiseHandState

function RaiseHandState.New(stickController)
	local self = {
		name = "RaiseHandState",
		stickController = stickController,
		timestamp = tick(),
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

function RaiseHandState:Tick(_dt: number)
	local commands = self.stickController.input.commands
	local time = tick() - self.timestamp

	if time < 0.2 then
		return
	end

	if not commands.RaiseHand then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
	end
end

function RaiseHandState:Exit()
	self.stickController.animator:StopAnimationByName("RaiseHand", Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("ChargePower")

	self.name = nil
	self.timestamp = nil
	setmetatable(self, nil)
	self = nil
end

return RaiseHandState
