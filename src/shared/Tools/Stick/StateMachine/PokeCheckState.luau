local Constants = require(script.Parent.Parent.Constants)

local PokeCheckState = {}

PokeCheckState.__index = PokeCheckState

function PokeCheckState.New(stickController)
	local self = {
		name = "PokeCheckState",
		stickController = stickController,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = true,
		canSprint = true,
	}
	setmetatable(self, PokeCheckState)

	return self
end

function PokeCheckState:Enter()
	self.stickController.animator:PlayAnimationByName("PokeCheck", Constants.FADE_TIME)
end

function PokeCheckState:Tick(dt: number)
	if self.stickController.hasPuck then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
		return
	end

	if self.timeElapsed > 1 then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
		return
	end

	self.timeElapsed += dt
end

function PokeCheckState:Exit()
	self.stickController.animator:StopAnimationByName("PokeCheck", Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("PokeCheck")
end

function PokeCheckState:Destroy()
	self.name = nil
	self.stickController = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return PokeCheckState
