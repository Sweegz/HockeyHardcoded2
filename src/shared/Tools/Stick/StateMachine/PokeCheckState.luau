local Constants = require(script.Parent.Parent.Constants)

local PokeCheckState = {}

PokeCheckState.__index = PokeCheckState

function PokeCheckState.New(stickController)
	local self = {
		name = "PokeCheckState",
		stickController = stickController,
		timestamp = tick(),
		canCollect = false,
		canDropOthersPuck = true,
	}
	setmetatable(self, PokeCheckState)

	return self
end

function PokeCheckState:Enter()
	self.stickController.animator:PlayAnimationByName("PokeCheck", Constants.FADE_TIME)
end

function PokeCheckState:Tick(_dt: number)
	local time = tick() - self.timestamp

	if self.stickController.hasPuck then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
	end

	if time < 1 then
		return
	end

	self.stickController.state_machine:ChangeState(
		self.stickController.state_machine.states.DefaultState.New(self.stickController)
	)
end

function PokeCheckState:Exit()
	self.stickController.animator:StopAnimationByName("PokeCheck", Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("PokeCheck")

	self.name = nil
	self.timestamp = nil
	setmetatable(self, nil)
	self = nil
end

return PokeCheckState
