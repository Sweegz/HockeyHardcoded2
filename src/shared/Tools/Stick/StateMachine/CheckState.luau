local Constants = require(script.Parent.Parent.Constants)

local CheckState = {}

CheckState.__index = CheckState

function CheckState.New(stickController)
	local self = {
		name = "CheckState",
		stickController = stickController,
		timestamp = tick(),
	}
	setmetatable(self, CheckState)

	return self
end

function CheckState:Enter()
	self.stickController.animator:PlayAnimationByName("Check", Constants.FADE_TIME)
end

function CheckState:Tick(dt: number)
	local time = tick() - self.timestamp

	if time < 0.75 then
		return
	end

	self.stickController.state_machine:ChangeState(
		self.stickController.state_machine.states.DefaultState.New(self.stickController)
	)
end

function CheckState:Exit()
	self.stickController.animator:StopAnimationByName("Check", Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("ChargePower")

	self.name = nil
	self.timestamp = nil
	setmetatable(self, nil)
	self = nil
end

return CheckState
