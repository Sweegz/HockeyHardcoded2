local Constants = require(script.Parent.Parent.Constants)

local KneeBlockState = {}

KneeBlockState.__index = KneeBlockState

function KneeBlockState.New(stickController)
	local self = {
		name = "KneeBlock",
		stickController = stickController,
		timestamp = tick(),
	}
	setmetatable(self, KneeBlockState)

	return self
end

function KneeBlockState:Enter()
	self.stickController.animator:PlayAnimationByName("KneeBlock", Constants.FADE_TIME)
end

function KneeBlockState:Tick(_dt: number)
	local commands = self.stickController.input.commands
	local time = tick() - self.timestamp

	if time < 1.6 then
		return
	end

	if not commands.KneeBlock then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
	end
end

function KneeBlockState:Exit()
	self.stickController.animator:StopAnimationByName("KneeBlock", Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("KneeBlock")

	self.name = nil
	self.timestamp = nil
	setmetatable(self, nil)
	self = nil
end

return KneeBlockState
