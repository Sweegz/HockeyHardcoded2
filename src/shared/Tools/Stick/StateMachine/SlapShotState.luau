local StarterPlayer = game:GetService("StarterPlayer")
local CollectController = require(StarterPlayer.StarterPlayerScripts.Controllers.CollectController)
local Constants = require(script.Parent.Parent.Constants)

local PHASE_1 = false
local PHASE_2 = false
local SHOT = false

local SlapShotState = {}

SlapShotState.__index = SlapShotState

function SlapShotState.New(stickController)
	local self = {
		name = "SlapShotState",
		stickController = stickController,
		timestamp = tick(),
		canCollect = false,
		canDropOthersPuck = false,
	}
	setmetatable(self, SlapShotState)

	return self
end

function SlapShotState:Enter()
	CollectController:Drop()
	local animator = self.stickController.animator
	animator:PlayAnimationByName("SlapWind1", 0.3)

	PHASE_1 = false
	PHASE_2 = false
	SHOT = false
end

function SlapShotState:Tick(_dt: number)
	local animator = self.stickController.animator
	local commands = self.stickController.input.commands
	local time = tick() - self.timestamp

	if time > 0.3 and not PHASE_1 and not SHOT then
		PHASE_1 = true
		animator:PlayAnimationByName("SlapWind2", 1.5)
	end

	if time > 0.45 and not PHASE_2 and not SHOT then
		PHASE_2 = true
		animator:AdjustWeightByName("SlapWind2", 0, 1.5)
	end

	if time > 0.3 and not commands.SlapShot and not SHOT then
		SHOT = tick()
		animator:StopAnimationByName("SlapWind2", 0.1)
		animator:StopAnimationByName("SlapWind2", 0.1)
		animator:PlayAnimationByName("SlapShot", 0.1)
	end

	if SHOT and tick() - SHOT > 1 then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
	end
end

function SlapShotState:Exit()
	local animator = self.stickController.animator
	animator:StopAnimationByName("SlapWind1", Constants.FADE_TIME)
	animator:StopAnimationByName("SlapWind2", Constants.FADE_TIME)
	animator:StopAnimationByName("SlapShot", Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("SlapShot")

	self.name = nil
	self.timestamp = nil
	setmetatable(self, nil)
	self = nil
end

return SlapShotState
