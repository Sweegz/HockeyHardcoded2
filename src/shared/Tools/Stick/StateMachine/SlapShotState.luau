local StarterPlayer = game:GetService("StarterPlayer")
local CollectController = require(StarterPlayer.StarterPlayerScripts.Controllers.CollectController)
local Constants = require(script.Parent.Parent.Constants)

local PHASE_1 = false
local PHASE_2 = false
local SHOT = false

local SlapShotState = {}

SlapShotState.__index = SlapShotState

function SlapShotState.New(ctx)
	local self = {
		name = "SlapShotState",
		ctx = ctx,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = false,
		canSprint = false,
	}
	setmetatable(self, SlapShotState)

	return self
end

function SlapShotState:Enter()
	CollectController:Drop()
	local animator = self.ctx.animator
	animator:PlayAnimationByName("SlapWind1", 0.3)

	self.ctx.customLock:SetTorquePower(2000)
	self.ctx.customLock:ForceMouseLock(true)

	self.ctx.movementDisabled = true
	self.ctx.humanoid.WalkSpeed = 16

	PHASE_1 = false
	PHASE_2 = false
	SHOT = false
end

function SlapShotState:Tick(dt: number)
	local animator = self.ctx.animator
	local commands = self.ctx.input.commands

	if self.ctx:IsHit() then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	if self.timeElapsed > 0.3 and not PHASE_1 and not SHOT then
		PHASE_1 = true
		animator:PlayAnimationByName("SlapWind2", 1.5)
	end

	if self.timeElapsed > 0.45 and not PHASE_2 and not SHOT then
		PHASE_2 = true
		animator:AdjustWeightByName("SlapWind2", 0, 1.5)
	end

	if self.timeElapsed > 0.3 and not commands.SlapShot and not SHOT then
		SHOT = time()
		animator:StopAnimationByName("SlapWind1", 0.1)
		animator:StopAnimationByName("SlapWind2", 0.1)
		animator:PlayAnimationByName("SlapShot", 0.1)
	end

	if SHOT and time() - SHOT > 0.45 then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	self.timeElapsed += dt
end

function SlapShotState:Exit()
	local animator = self.ctx.animator
	animator:StopAnimationByName("SlapWind1", Constants.FADE_TIME)
	animator:StopAnimationByName("SlapWind2", Constants.FADE_TIME)
	animator:StopAnimationByName("SlapShot", Constants.FADE_TIME)
	local input = self.ctx.input
	input:DisableCommand("SlapShot")
	input:DisableCommand("DropPuck")

	self.ctx.movementDisabled = false

	self.ctx.customLock:ResetTorquePower()
	self.ctx.customLock:ForceMouseLock(false)
end

function SlapShotState:Destroy()
	self.name = nil
	self.ctx = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return SlapShotState
