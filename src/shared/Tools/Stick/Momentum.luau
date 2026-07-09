local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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

function Momentum.New(ctx)
	local self = setmetatable({
		ctx = ctx,
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
	self.movementDisabled = false

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

	local humanoid = self.ctx.humanoid
	if not humanoid then
		return
	end

	local humanoidRootPart = getHumanoidRootPart()
	if not humanoidRootPart then
		return
	end

	local bodyVelocity = self.bodyVelocity
	local moveDirection = humanoid.MoveDirection
	local extended = self.ctx.extended ~= nil

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
					self:SetBodyVelocity(humanoidRootPart.AssemblyLinearVelocity)
				end
				local walkSpeed = humanoid.WalkSpeed
				--local alpha = 1 - (1 - glideSpeedModifier) ^ (dt / FRAME_RATE)
				self:SetBodyVelocity(bodyVelocity.Velocity:Lerp(moveDirection * walkSpeed, glideSpeedModifier))
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
					self:SetBodyVelocity(
						bodyVelocity.Velocity:Lerp(desiredDirectionVelocity * walkSpeed, glideSpeedModifier)
					)
				end
			end
		else
			if self.calculatedVelocity.Magnitude >= humanoid.WalkSpeed + 5 then
				self.calculatedVelocity = self.calculatedVelocity / self.calculatedVelocity.Magnitude
				self.calculatedVelocity = self.calculatedVelocity * (humanoid.WalkSpeed + 5)
			end
			self:SetBodyVelocity(self.calculatedVelocity)
		end
	end

	--[[

	local XD = false

	local parts = self.ctx.tool.Blade:GetTouchingParts()
	for _, part in parts do
		if CollectionService:HasTag(part, "PhysicalObject") then
			--self:SetBodyVelocity(Vector3.new(0, 0, 0))
			self.bodyVelocity.MaxForce = Vector3.new
			XD = true
			break
		end
	end

	if not XD then
		self.bodyVelocity.MaxForce = MAX_FORCE
	end]]
end

function Momentum:SetBodyVelocity(velocity: Vector3)
	if self.bodyVelocity then
		self.bodyVelocity.Velocity = velocity
	end
end

RunService.PostSimulation:Connect(function()
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	local stick = character:FindFirstChild("Stick")

	if not stick then
		return
	end

	if humanoidRootPart then
		local pos = humanoidRootPart.Position
		local _, y, z = humanoidRootPart.CFrame:ToEulerAnglesYXZ()

		--humanoidRootPart.AssemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity * Vector3.new(1, 0, 1)

		--[[ KEEPS THE PLAYER UPRIGHT ]]
		humanoidRootPart.CFrame = CFrame.new(pos.X, pos.Y, pos.Z) * CFrame.Angles(0, y, 0)
	end

	local weld = stick:FindFirstChild("AAAA").Weld

	local primaryPart = stick.PrimaryPart
	if primaryPart then
		local pos = primaryPart.Position
		local x, y, z = primaryPart.CFrame:ToEulerAnglesYXZ()

		--[[ STICK CANT HAVE UPWARDS VELOCITY ]]
		if primaryPart.AssemblyLinearVelocity.Y > 0 then
			primaryPart.AssemblyLinearVelocity = primaryPart.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
		end

		local cf = primaryPart.CFrame

		local look = cf.LookVector
		local flatLook = Vector3.new(look.X, 0, look.Z)

		if flatLook.Magnitude > 0 then
			local yawOnlyWorld = CFrame.lookAt(Vector3.zero, flatLook.Unit)

			-- [[ WELD BLADE HITBOX PART ABOVE BLADE NEGATING ORIENTATION ]]
			weld.C0 = primaryPart.CFrame:ToObjectSpace(
				CFrame.new(primaryPart.Position + Vector3.new(0, 1.6, 0)) * yawOnlyWorld
			)
		end

		--AAAA.CFrame = CFrame.new(pos.X, pos.Y + 2, pos.Z) * CFrame.Angles(0, y, 0)
		--primaryPart.CFrame = CFrame.new(pos.X, pos.Y, pos.Z) * CFrame.Angles(0, y, 0)
	end
end)

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
	self.movementDisabled = false
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
