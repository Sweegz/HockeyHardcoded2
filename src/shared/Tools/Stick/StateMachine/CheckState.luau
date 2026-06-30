local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getValidMouseHit = require(ReplicatedStorage.Shared.Utility.getValidMouseHit)
local Constants = require(script.Parent.Parent.Constants)

local CheckState = {}

CheckState.__index = CheckState

function CheckState.New(stickController)
	local self = {
		name = "CheckState",
		stickController = stickController,
		timestamp = tick(),
		movementSpeedMultiplier = 0,
		lastVelocityUpdate = 0,
		canCollect = true,
		canDropOthersPuck = true,
		canSprint = true,
	}
	setmetatable(self, CheckState)

	return self
end

function CheckState:Enter()
	self.stickController.animator:PlayAnimationByName("Check", Constants.FADE_TIME)

	local power = self.stickController.power.current

	local humanoid = self.stickController.humanoid
	local momentum = self.stickController.momentum

	local character = humanoid.Parent
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	local targetPosition = getValidMouseHit()

	local hrp_speed = humanoidRootPart.AssemblyLinearVelocity.Magnitude
	if humanoid.WalkSpeed < hrp_speed then
		hrp_speed = humanoid.WalkSpeed
	end

	momentum:SetMoving(true)

	local humanoidRootPartSpeed = humanoidRootPart.AssemblyLinearVelocity.Magnitude
	if humanoid.WalkSpeed < humanoidRootPartSpeed then
		humanoidRootPartSpeed = humanoid.WalkSpeed
	end

	if humanoid.WalkSpeed >= 32 and power >= 18.4 then
		if power <= 25 then
			if humanoidRootPartSpeed < power * 1.335 then
				local Velocity = (targetPosition - humanoidRootPart.Position).Unit * (power / 50 * 47 * 1.40175)
				momentum:SetBodyVelocity(Velocity)
				self.movementSpeedMultiplier = power * 1.40175
			else
				local Velocity = (targetPosition - humanoidRootPart.Position).Unit * humanoidRootPartSpeed
				momentum:SetBodyVelocity(Velocity)
				self.movementSpeedMultiplier = humanoidRootPartSpeed
			end
		elseif humanoidRootPartSpeed < power / 50 * 47 * 1.035 then
			local Velocity = (targetPosition - humanoidRootPart.Position).Unit * (power / 50 * 47 * 1.086)
			momentum:SetBodyVelocity(Velocity)
			self.movementSpeedMultiplier = power / 50 * 47 * 1.086
		else
			local Velocity = (targetPosition - humanoidRootPart.Position).Unit * humanoidRootPartSpeed
			momentum:SetBodyVelocity(Velocity)
			self.movementSpeedMultiplier = humanoidRootPartSpeed
		end
		if power >= 18 then
			if humanoidRootPartSpeed < power / 50 * 47 * 0.925 then
				local Velocity = (targetPosition - humanoidRootPart.Position).Unit * (power / 50 * 47 * 0.925)
				momentum:SetBodyVelocity(Velocity)
				self.movementSpeedMultiplier = power / 50 * 47 * 0.925
			else
				local Velocity = (targetPosition - humanoidRootPart.Position).Unit * humanoidRootPartSpeed
				momentum:SetBodyVelocity(Velocity)
				self.movementSpeedMultiplier = humanoidRootPartSpeed
			end
		elseif power > 35 then
			if humanoidRootPartSpeed < power / 50 * 47 * 1.135 then
				local Velocity = (targetPosition - humanoidRootPart.Position).Unit * (power / 50 * 47 * 1.2)
				momentum:SetBodyVelocity(Velocity)
				self.movementSpeedMultiplier = power / 50 * 47 * 1.2
			else
				local Velocity = (targetPosition - humanoidRootPart.Position).Unit * humanoidRootPartSpeed
				momentum:SetBodyVelocity(Velocity)
				self.movementSpeedMultiplier = humanoidRootPartSpeed
			end
		end
	end
end

function CheckState:Tick(dt: number)
	local time = tick() - self.timestamp

	local humanoid = self.stickController.humanoid
	local momentum = self.stickController.momentum
	local moveDirection = humanoid.MoveDirection

	if time < 0.5 then
		if (tick() - self.lastVelocityUpdate) >= (1 / 60) and humanoid.MoveDirection.Magnitude > 0.1 then
			local velocity = momentum:GetBodyVelocity()
			velocity = velocity:Lerp(moveDirection * self.movementSpeedMultiplier, 0.8 * dt)
			momentum:SetBodyVelocity(velocity)
			self.lastVelocityUpdate = tick()
		end
	end

	if time > 0.5 then
		momentum:SetMoving(false)
	end

	if time < 0.75 then
		return
	end

	self.stickController.state_machine:ChangeState(
		self.stickController.state_machine.states.DefaultState.New(self.stickController)
	)
end

function CheckState:Exit()
	self.stickController.animator:StopAnimationByName("Check", Constants.FADE_TIME)

	self.name = nil
	self.timestamp = nil
	setmetatable(self, nil)
	self = nil
end

return CheckState
