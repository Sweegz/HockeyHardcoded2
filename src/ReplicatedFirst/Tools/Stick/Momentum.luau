local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local PlayerSessionController = require(StarterPlayer.StarterPlayerScripts.Controllers.PlayerSessionController)

local Momentum = {}
Momentum.__index = Momentum

local LocalPlayer = Players.LocalPlayer

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { game.Workspace.Rink.Game.Collisions }

local ANGULAR_FRICTION = 0.005
local ANGULAR_FRICTION_GLIDE = 0.04
local ANGULAR_VELOCITY_TRESHOLD = 10
local GLIDE_SPEED_MODIFIER_ACCELERATING = 0.04
local GLIDE_SPEED_MODIFIER_RESISTING = 0.06064
local VELOCITY_DAMP_FACTOR = 0.825
local DIRECTION_LERP_FACTOR = 0.6
local MAX_FORCE = Vector3.new(25000, 0, 25000)

local function getHumanoidRootPart()
	local character = LocalPlayer and LocalPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function IsOnIce(humanoidRootPart: BasePart)
	local p = humanoidRootPart.Position

	return p.X >= -84.25 and p.X <= 84.25 and p.Z >= -159.25 and p.Z <= 159.25 and p.Y < 4
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

	if not self.ctx:IsHit() or self.ctx.hit.velocity.Magnitude <= 1 then
		-- Balance when player is not hit and UpRight
		if humanoidRootPart.CFrame.UpVector.Y == 1 then
			self.ctx.groundController.BalanceRigidityEnabled = true
		end

		-- Limit Y position when player is OnIce and NotHit
		if
			humanoidRootPart.Position.Y > 3.55
			and IsOnIce(humanoidRootPart)
			and not PlayerSessionController:GetBenched(LocalPlayer)
		then
			self.ctx.planeConstraint.Enabled = true
		end

		-- Prevent Upwards velocity while player is not hit
		if humanoidRootPart.AssemblyLinearVelocity.Y > 1 then
			humanoidRootPart.AssemblyLinearVelocity *= Vector3.new(1, 0, 1)
		end

		if self.ctx.ragdolled then
			self.ctx.ragdolled = false
			coroutine.wrap(function()
				task.wait(0.25)
				self.ctx.abilityManagerActor.Abilities.FallingDown.SyncedState:SetAttribute("Enabled", false)
				self.ctx.abilityManagerActor.Abilities.FallingDown.SyncedState:SetAttribute("Active", false)
				self.ctx.abilityManagerActor.Abilities.Running.SyncedState:SetAttribute("Enabled", true)
				self.ctx.abilityManagerActor.Abilities.GettingUp.SyncedState:SetAttribute("Enabled", true)
				self.ctx.abilityManagerActor.Abilities.GettingUp.SyncedState:SetAttribute("Active", true)

				self.ctx.groundController.BalanceSpeed = 10
				self.ctx.groundController.BalanceMaxTorque = 1000000
				self.ctx.controllerManager.GroundSensor = humanoidRootPart.FloorSensor

				local character = LocalPlayer.Character
				if character then
					for _, descendant in character:GetChildren() do
						if descendant:IsA("BasePart") and descendant.Name:match("Collider") then
							descendant.CanCollide = false
						end
					end
				end

				self.ctx.customLock:ResetTorquePower()
			end)()
		end

		bodyVelocity.MaxForce = MAX_FORCE
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
	else
		if not self.ctx.hit.shove then
			self.ctx.ragdolled = true

			self.ctx.abilityManagerActor.Abilities.GettingUp.SyncedState:SetAttribute("Enabled", false)
			self.ctx.abilityManagerActor.Abilities.GettingUp.SyncedState:SetAttribute("Active", false)
			self.ctx.abilityManagerActor.Abilities.Running.SyncedState:SetAttribute("Enabled", false)
			self.ctx.abilityManagerActor.Abilities.Running.SyncedState:SetAttribute("Active", false)
			self.ctx.abilityManagerActor.Abilities.FallingDown.SyncedState:SetAttribute("Enabled", true)
			self.ctx.abilityManagerActor.Abilities.FallingDown.SyncedState:SetAttribute("Active", true)
			self.ctx.controllerManager.ActiveController = nil

			self.ctx.groundController.BalanceSpeed = 0
			self.ctx.groundController.BalanceMaxTorque = 0
			self.ctx.groundController.BalanceRigidityEnabled = false
			self.ctx.planeConstraint.Enabled = false

			local character = LocalPlayer.Character
			if character then
				for _, descendant in character:GetChildren() do
					if descendant:IsA("BasePart") and descendant.Name:match("Collider") then
						descendant.CanCollide = true
					end
				end
			end
		end

		self:SetBodyVelocity(self.ctx.hit.velocity)

		-- Adjust the BodyVelocity upon rink collision
		local raycastResult =
			workspace:Raycast(humanoidRootPart.Position, bodyVelocity.Velocity * Vector3.new(1, 0, 1), raycastParams)

		if raycastResult and raycastResult.Distance <= 2 then
			local velocity = bodyVelocity.Velocity
			local normal = raycastResult.Normal

			local slideVelocity = velocity - normal * velocity:Dot(normal)

			bodyVelocity.Velocity = slideVelocity
		end
	end

	--print(self.bodyVelocity.Velocity)
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
