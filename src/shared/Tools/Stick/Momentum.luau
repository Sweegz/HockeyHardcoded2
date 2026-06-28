local Players = game:GetService("Players")
local Momentum = {}
Momentum.__index = Momentum

local LocalPlayer = Players.LocalPlayer

local Config = {
	AngularFriction = 0.005,
	AngularFrictionGlide = 0.04,
	AngularVelocityThreshold = 10,
	GlideSpeedModifierAccelerating = 0.04,
	GlideSpeedModifierResisting = 0.06064,
	VelocityDampFactor = 0.825,
	DirectionLerpFactor = 0.6,
	MaxForce = Vector3.new(25000, 0, 25000),
	BaseFrameRate = 1 / 60,
}

local function GetHumanoidRootPart()
	local character = LocalPlayer and LocalPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function IsFiniteVector3(value: Vector3)
	return value.X == value.X
end

function Momentum.New(stickController)
	local self = setmetatable({
		stickController = stickController,
		bodyVelocity = nil,
		enabled = false,
		isChangingDirection = false,
	}, Momentum)

	local humanoidRootPart = GetHumanoidRootPart()
	local bodyVelocity = humanoidRootPart and humanoidRootPart:FindFirstChild("Momentum")
		or Instance.new("BodyVelocity")
	bodyVelocity.Name = "Momentum"
	bodyVelocity.MaxForce = Config.MaxForce
	bodyVelocity.Parent = humanoidRootPart

	self.bodyVelocity = bodyVelocity

	return self
end

function Momentum:Enable()
	self.enabled = true

	local humanoidRootPart = GetHumanoidRootPart()
	if humanoidRootPart then
		self.bodyVelocity.Parent = humanoidRootPart
	end
end

function Momentum:Tick(dt: number)
	if not self.enabled then
		return
	end

	local humanoid = self.stickController.humanoid
	if not humanoid then
		return
	end

	local humanoidRootPart = GetHumanoidRootPart()
	if not humanoidRootPart then
		return
	end

	if humanoid.WalkSpeed > 47 then
		humanoid.WalkSpeed = 47
	elseif humanoid.WalkSpeed > 38 then
		humanoid.WalkSpeed = 38
	end

	local bodyVelocity = self.bodyVelocity
	local moveDirection = humanoid.MoveDirection
	local isMoving = moveDirection.Magnitude > 0
	local isExtended = self.stickController.extended ~= nil

	local glideModifier = 0.1
	if isMoving then
		local maxGlideVelocity = humanoid.WalkSpeed > 33 and 80 or 60
		if (bodyVelocity.Velocity + moveDirection * humanoid.WalkSpeed).Magnitude <= maxGlideVelocity then
			if not self.isChangingDirection then
				self.isChangingDirection = true
				bodyVelocity.Velocity *= Config.VelocityDampFactor
			end
			glideModifier = Config.GlideSpeedModifierAccelerating
		else
			if bodyVelocity.Velocity.Magnitude > humanoid.WalkSpeed + 1 then
				bodyVelocity.Velocity *= Config.VelocityDampFactor
			end
			self.isChangingDirection = false
			glideModifier = Config.GlideSpeedModifierResisting
		end

		local angularFactor = humanoidRootPart.AssemblyAngularVelocity.Magnitude / 18
		glideModifier += angularFactor * (isExtended and Config.AngularFrictionGlide or Config.AngularFriction)
	end

	if not IsFiniteVector3(bodyVelocity.Velocity) then
		bodyVelocity.Velocity = humanoidRootPart.AssemblyLinearVelocity
	end

	local alpha = 1 - (1 - glideModifier) ^ (dt / Config.BaseFrameRate)

	if humanoidRootPart.AssemblyAngularVelocity.Magnitude <= Config.AngularVelocityThreshold then
		bodyVelocity.Velocity = bodyVelocity.Velocity:Lerp(moveDirection * humanoid.WalkSpeed, alpha)
		return
	end

	local desiredDirection = Vector3.new()
	if bodyVelocity.Velocity.Magnitude > 0 then
		desiredDirection = bodyVelocity.Velocity.Unit:Lerp(moveDirection, Config.DirectionLerpFactor)
	else
		desiredDirection = Vector3.new():Lerp(moveDirection, Config.DirectionLerpFactor)
	end

	bodyVelocity.Velocity = bodyVelocity.Velocity:Lerp(desiredDirection * humanoid.WalkSpeed, alpha)
end

function Momentum:Disable()
	self.enabled = false
	self.bodyVelocity.Parent = nil
end

return Momentum
