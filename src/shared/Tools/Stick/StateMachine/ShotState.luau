local StarterPlayer = game:GetService("StarterPlayer")
local PlayerActionController = require(StarterPlayer.StarterPlayerScripts.Controllers.PlayerActionController)
local Constants = require(script.Parent.Parent.Constants)

local ShotState = {}

ShotState.__index = ShotState

function ShotState.New(stickController)
	local self = {
		name = "ShotState",
		stickController = stickController,
		timestamp = tick(),
	}
	setmetatable(self, ShotState)

	return self
end

local function GetAnimationName(power, extended)
	if extended == "Right" then
		if power < 50 then
			return "RightWrist"
		else
			return "RightSlap"
		end
	elseif extended == "Left" then
		if power < 50 then
			return "LeftWrist"
		else
			return "LeftSlap"
		end
	else
		if power < 50 then
			return "Wrist"
		else
			return "Slap"
		end
	end
end

function ShotState:Enter()
	local extended = self.stickController.extended
	self.power = self.stickController.power.current
	self.animation_name = GetAnimationName(self.power, extended)
	self.track = self.stickController.animator:GetAnimationTrack(self.animation_name)

	task.spawn(function()
		self.connection = self.track:GetMarkerReachedSignal("Shoot"):Once(function()
			PlayerActionController:Shoot(self.power, {
				wrist = false,
				chip = false,
				fake = false,
			})
		end)
	end)

	self.stickController.animator:PlayAnimationByName(self.animation_name, 0)

	print("Enter ShotState from:", extended, " Power:", self.power)
end

function ShotState:Tick(_dt: number)
	local _commands = self.stickController.input.commands

	if not self.track.IsPlaying then
		self.stickController.state_machine:ChangeState(
			self.stickController.state_machine.states.DefaultState.New(self.stickController)
		)
	end
end

function ShotState:Exit()
	print("Exit ShotState")
	self.stickController.animator:StopAnimationByName(self.animation_name, Constants.FADE_TIME)
	local input = self.stickController.input
	input:DisableCommand("ChargePower")

	self.name = nil
	self.timestamp = nil
	self.animation_name = nil
	self.track = nil
	if self.connection then
		self.connection:Disconnect()
	end
	setmetatable(self, nil)
	self = nil
end

return ShotState
