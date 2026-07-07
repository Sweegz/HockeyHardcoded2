local Players = game:GetService("Players")
local Momentum = {}
Momentum.__index = Momentum

local LocalPlayer = Players.LocalPlayer

local ANGULAR_FRICTION = 0.005
local ANGULAR_FRICTION_GLIDE = 0.04
local ANGULAR_VELOCITY_TRESHOLD = 10
local GLIDE_SPEED_MODIFIER_ACCELERATING = 0.04
local GLIDE_SPEED_MODIFIER_RESISTING = 0.06064
local VELOCITY_DAMP_FACTOR = 0.825
local DIRECTION_LERP_FACTOR = 0.6
local MAX_FORCE = Vector3.new(25000, 0, 25000)
local FRAME_RATE = 1 / 60

local function getHumanoidRootPart()
	local character = LocalPlayer and LocalPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

function Momentum.New(stickController)
	local self = setmetatable({
		stickController = stickController,
		bodyVelocity = nil,
		enabled = false,
		isChangingDirection = false,
		isMoving = false,
		lastVelocityUpdate = 0,
		calculatedVelocity = Vector3.new(0, 0, 0),
	}, Momentum)

	return self
end

function Momentum:Enable()
	self.enabled = true

	local humanoidRootPart = getHumanoidRootPart()
	local bodyVelocity = humanoidRootPart and humanoidRootPart:FindFirstChild("Momentum")
		or Instance.new("BodyVelocity")
	bodyVelocity.Name = "Momentum"
	bodyVelocity.MaxForce = MAX_FORCE
	bodyVelocity.Parent = humanoidRootPart

	self.bodyVelocity = bodyVelocity
end

function Momentum:Tick(dt: number)
	if not self.enabled then
		return
	end

	local humanoid = self.stickController.humanoid
	if not humanoid then
		return
	end

	local humanoidRootPart = getHumanoidRootPart()
	if not humanoidRootPart then
		return
	end

	local bodyVelocity = self.bodyVelocity
	local moveDirection = humanoid.MoveDirection
	local extended = self.stickController.extended ~= nil

	local glideSpeedModifier = nil
	if moveDirection.Magnitude > 0 then
		local maxGlideVelocity = 60
		if humanoid.WalkSpeed > 33 then
			maxGlideVelocity = 80
		end
		if (bodyVelocity.Velocity + moveDirection * humanoid.WalkSpeed).Magnitude <= maxGlideVelocity then
			glideSpeedModifier = GLIDE_SPEED_MODIFIER_ACCELERATING
			if not self.isChangingDirection then
				self.isChangingDirection = true
				local velocityReference = bodyVelocity
				velocityReference.Velocity = velocityReference.Velocity * VELOCITY_DAMP_FACTOR
			end
		else
			if bodyVelocity.Velocity.Magnitude > humanoid.WalkSpeed + 1 and not self.isMoving then
				local velocityReference = bodyVelocity
				velocityReference.Velocity = velocityReference.Velocity * VELOCITY_DAMP_FACTOR
			end
			self.isChangingDirection = false
			glideSpeedModifier = GLIDE_SPEED_MODIFIER_RESISTING
		end
		glideSpeedModifier = glideSpeedModifier
			+ if not extended
				then humanoidRootPart.AssemblyAngularVelocity.Magnitude / 18 * ANGULAR_FRICTION
				else humanoidRootPart.AssemblyAngularVelocity.Magnitude / 18 * ANGULAR_FRICTION_GLIDE
	else
		glideSpeedModifier = 0.1
	end

	if not self.isMoving then
		if self.calculatedVelocity.Magnitude <= 1 then
			if humanoidRootPart.AssemblyAngularVelocity.Magnitude <= ANGULAR_VELOCITY_TRESHOLD then
				if bodyVelocity.Velocity.X ~= (0 / 0) then
					bodyVelocity.Velocity = humanoidRootPart.AssemblyLinearVelocity
				end
				local walkSpeed = humanoid.WalkSpeed
				--local alpha = 1 - (1 - glideSpeedModifier) ^ (dt / FRAME_RATE)
				bodyVelocity.Velocity = bodyVelocity.Velocity:Lerp(moveDirection * walkSpeed, glideSpeedModifier)
			else
				local desiredDirectionVelocity = nil
				if bodyVelocity.Velocity.Magnitude > 0 then
					desiredDirectionVelocity = (bodyVelocity.Velocity / bodyVelocity.Velocity.Magnitude):Lerp(
						moveDirection,
						DIRECTION_LERP_FACTOR
					)
				else
					desiredDirectionVelocity = Vector3.new(0, 0, 0):Lerp(moveDirection, 0.6)
				end

				if desiredDirectionVelocity then
					local walkSpeed = humanoid.WalkSpeed
					--local alpha = 1 - (1 - glideSpeedModifier) ^ (dt / FRAME_RATE)
					bodyVelocity.Velocity =
						bodyVelocity.Velocity:Lerp(desiredDirectionVelocity * walkSpeed, glideSpeedModifier)
				end
			end
		else
			if self.calculatedVelocity.Magnitude >= humanoid.WalkSpeed + 5 then
				self.calculatedVelocity = self.calculatedVelocity / self.calculatedVelocity.Magnitude
				self.calculatedVelocity = self.calculatedVelocity * (humanoid.WalkSpeed + 5)
			end
			bodyVelocity.Velocity = self.calculatedVelocity
		end
	end
end

function Momentum:SetBodyVelocity(velocity: Vector3)
	if self.bodyVelocity then
		self.bodyVelocity.Velocity = velocity
	end
end

function Momentum:SetMoving(isMoving: boolean)
	self.isMoving = isMoving
end

function Momentum:GetBodyVelocity()
	return self.bodyVelocity.Velocity
end

function Momentum:Disable()
	self.enabled = false
	self.isMoving = false
	self.isChangingDirection = false
	self.bodyVelocity.Parent = nil
end

function Momentum:Destroy()
	self:Disable()
	self.enabled = false
	self.isChangingDirection = false
	self.isMoving = false
	if self.bodyVelocity then
		self.bodyVelocity:Destroy()
	end
	self.bodyVelocity = nil
end

return Momentum
