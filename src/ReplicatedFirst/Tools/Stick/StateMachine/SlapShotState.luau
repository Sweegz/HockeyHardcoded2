local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local CollectController = require(StarterPlayer.StarterPlayerScripts.Controllers.CollectController)
local PlayerActionController = require(StarterPlayer.StarterPlayerScripts.Controllers.PlayerActionController)
local Constants = require(script.Parent.Parent.Constants)

local TIME_TRANSITION = 0.3
local TIME_CHARGE = 1.5
local PHASE_1 = false
local PHASE_2 = false

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
		canCharge = true,
		cancel = false,
		SHOT = false,
		power = 0,
		sentEvent = false,
	}
	setmetatable(self, SlapShotState)

	return self
end

function SlapShotState:Enter()
	CollectController:Drop()
	local animator = self.ctx.animator
	animator:PlayAnimationByName("SlapWind1", 0.3)

	self.ctx.customLock:SetTorquePower(1000)
	self.ctx.customLock:ForceMouseLock(true)
	self.ctx.customLock:FollowMouse(true)

	self.ctx.movementDisabled = true
	self.ctx.humanoid.WalkSpeed = 16
	self.frontPart = self.ctx.tool:FindFirstChild("Collect")

	local character: Model = self.ctx.humanoid.Parent
	if not character then
		return
	end

	for _, child in character:GetChildren() do
		if child.Name:match("Collider") then
			child.CanCollide = false
		end
	end

	PHASE_1 = false
	PHASE_2 = false
end

function SlapShotState:TransitionFinished()
	return self.timeElapsed > TIME_TRANSITION
end

function SlapShotState:Tick(dt: number)
	local animator = self.ctx.animator

	if self.ctx:IsHit() or self.cancel then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	if self.timeElapsed > TIME_TRANSITION and not PHASE_1 and not self.SHOT then
		PHASE_1 = true
		animator:PlayAnimationByName("SlapWind2", TIME_CHARGE)
	end

	if self.timeElapsed > TIME_TRANSITION + 1.5 and not PHASE_2 and not self.SHOT then
		PHASE_2 = true
		animator:AdjustWeightByName("SlapWind2", 0, TIME_CHARGE)
	end

	if self.SHOT and not self.sentEvent then
		local puckPart = Workspace.Pucks:FindFirstChild("Puck")
		if puckPart then
			local distance = (puckPart.Position - self.frontPart.Position).Magnitude
			if distance <= 3 then
				PlayerActionController:Slapshot(puckPart, self.power, {})
				self.sentEvent = true
			end
		end
	end

	if self.SHOT and (time() - self.SHOT) > 0.45 then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	self.timeElapsed += dt
end

function SlapShotState:Cancel()
	self.cancel = true
end

function SlapShotState:Shoot(power: number)
	print("Slapshot2")
	local animator = self.ctx.animator
	self.SHOT = time()
	self.power = power
	animator:StopAnimationByName("SlapWind1", 0.1)
	animator:StopAnimationByName("SlapWind2", 0.1)
	animator:PlayAnimationByName("SlapShot", 0.1)
end

function SlapShotState:Exit()
	local animator = self.ctx.animator
	animator:StopAnimationByName("SlapWind1", Constants.FADE_TIME)
	animator:StopAnimationByName("SlapWind2", Constants.FADE_TIME)
	animator:StopAnimationByName("SlapShot", Constants.FADE_TIME)
	local input = self.ctx.input
	input:DisableCommand("SlapShot")
	input:DisableCommand("CancelSlapshot")
	input:DisableCommand("DropPuck")
	input:DisableCommand("LyingBlock")
	self.ctx.customLock:FollowMouse(false)

	local character: Model = self.ctx.humanoid.Parent
	if not character then
		return
	end

	task.delay(0.2, function()
		for _, child in character:GetChildren() do
			if child.Name:match("Collider") then
				child.CanCollide = true
			end
		end
	end)

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
