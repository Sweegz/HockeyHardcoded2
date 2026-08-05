local StarterPlayer = game:GetService("StarterPlayer")
local PlayerActionController = require(StarterPlayer.StarterPlayerScripts.Controllers.PlayerActionController)
local Constants = require(script.Parent.Parent.Constants)

local ShotState = {}

ShotState.__index = ShotState

function ShotState.New(ctx)
	local self = {
		name = "ShotState",
		ctx = ctx,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = false,
		canSprint = true,
	}
	setmetatable(self, ShotState)

	return self
end

local function GetAnimationName(power, extended, isWristShot)
	if extended == "Right" then
		if power < 50 or isWristShot then
			return "RightWrist"
		else
			return "RightSlap"
		end
	elseif extended == "Left" then
		if power < 50 or isWristShot then
			return "LeftWrist"
		else
			return "LeftSlap"
		end
	else
		if power < 50 or isWristShot then
			return "Wrist"
		else
			return "Slap"
		end
	end
end

function ShotState:Enter()
	local extended = self.ctx.extended
	local commands = self.ctx.input.commands
	self.power = self.ctx.power.chargeValue

	local isWristShot = self.ctx.stateMachine.previous_state.timeElapsed <= 0.25 or commands.WristShot

	self.animation_name = GetAnimationName(self.power, extended, isWristShot)
	self.track = self.ctx.animator:GetAnimationTrack(self.animation_name)

	task.spawn(function()
		self.connection = self.track:GetMarkerReachedSignal("Shoot"):Once(function()
			local puck = self.ctx:HasPuck()

			PlayerActionController:Shoot(puck, self.power, {
				wrist = false,
				chip = typeof(commands.Chip) == "number",
				fake = typeof(commands.Fake) == "number",
			})
		end)
	end)

	self.ctx.animator:PlayAnimationByName(self.animation_name, 0)
end

function ShotState:Tick(_dt: number)
	local _commands = self.ctx.input.commands

	if self.ctx:IsHit() then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	if not self.track.IsPlaying then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end
end

function ShotState:Exit()
	self.ctx.animator:StopAnimationByName(self.animation_name, Constants.FADE_TIME)
	local input = self.ctx.input
	input:DisableCommand("ChargePower")
	input:DisableCommand("LowTip")
	input:DisableCommand("LyingBlock")
	input:DisableCommand("Chip")
	input:DisableCommand("WristShot")
end

function ShotState:Destroy()
	self.name = nil
	self.power = nil
	self.animation_name = nil
	self.track = nil
	if self.connection then
		self.connection:Disconnect()
	end
	self.ctx = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return ShotState
