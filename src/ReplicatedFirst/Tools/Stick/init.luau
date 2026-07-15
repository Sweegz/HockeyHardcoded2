local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")

local MouseLockController = require(StarterPlayer.StarterPlayerScripts.Controllers.MouseLockController)
local PuckController = require(StarterPlayer.StarterPlayerScripts.Controllers.PuckController)
local Animator = require(script.Animator)
local Input = require(script.Input)
local StateMachine = require(script.StateMachine)
local Power = require(script.Power)
local Collect = require(script.Collect)
local Constants = require(script.Constants)
--local CustomLock = require(script.CustomLock)
local Sprint = require(script.Sprint)
local Momentum = require(script.Momentum)

local DefaultState = require(script.StateMachine.DefaultState)

local function IsOnIce(humanoidRootPart: BasePart)
	local p = humanoidRootPart.Position

	return p.X >= -84.25 and p.X <= 84.25 and p.Z >= -159.25 and p.Z <= 159.25 and p.Y < 4
end

local Net = ReplicatedStorage.Net
local RagdollEvent = Net:FindFirstChild("Ragdoll") :: RemoteEvent

local DisconnectAndClear = require(ReplicatedStorage.Shared.Utility.DisconnectAndClear)

local LocalPlayer = Players.LocalPlayer

local Stick = {}
Stick.__index = Stick

function Stick.New(tool: Tool)
	local self = {
		tool = tool,
		equipped = false,
		connections = {},
		extended = nil,
		hasPuck = false,
		accumulatedTime = 0,
		isHit = time(),
		movementDisabled = false,
		ragdolled = false,
		customLock = MouseLockController,
	}
	setmetatable(self, Stick)

	print("Created Stick")

	self:Initialize()

	return self
end

local FIXED_RATE = 1 / 60

function Stick:Update(dt: number)
	local character = LocalPlayer.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	self.hasPuck = PuckController:GetOwner() == LocalPlayer

	self.power:Tick(dt)

	while self.accumulatedTime >= FIXED_RATE do
		local deltaTime = FIXED_RATE
		self.input:Tick(deltaTime)

		self.stateMachine:Tick(deltaTime)
		self.collect:Tick(deltaTime)
		self.sprint:Tick(deltaTime)
		self.momentum:Tick(deltaTime)

		-- Reset time
		self.accumulatedTime -= FIXED_RATE
	end

	if IsOnIce(humanoidRootPart) and not self:IsHit() and not self.ragdolled then
		if not self.planeConstraint.Enabled then
			self.planeConstraint.Enabled = true
		end
	else
		if self.planeConstraint.Enabled then
			self.planeConstraint.Enabled = false
		end
	end

	if not self:IsHit() and self.ragdolled then
		self.ragdolled = false
		task.spawn(function()
			task.wait(0.25)
			self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			self.abilityManagerActor.Abilities.FallingDown.SyncedState:SetAttribute("Enabled", false)
			self.abilityManagerActor.Abilities.FallingDown.SyncedState:SetAttribute("Active", false)
			self.abilityManagerActor.Abilities.Running.SyncedState:SetAttribute("Enabled", true)
			self.abilityManagerActor.Abilities.GettingUp.SyncedState:SetAttribute("Enabled", true)
			self.abilityManagerActor.Abilities.GettingUp.SyncedState:SetAttribute("Active", true)

			self.groundController.BalanceSpeed = 10
			self.groundController.BalanceMaxTorque = 1000000
			self.controllerManager.UpDirection = Vector3.new(0, 1, 0)

			local hitAngularVelocity = humanoidRootPart:FindFirstChild("HitRotate")
			if hitAngularVelocity then
				hitAngularVelocity:Destroy()
			end
			self.controllerManager.GroundSensor = humanoidRootPart.FloorSensor

			self.customLock:ResetTorquePower()
			task.wait(0.25)
			self.groundController.BalanceRigidityEnabled = true
		end)
	end

	self.accumulatedTime += dt
end

function Stick:Equip()
	if self.equipped then
		return
	end
	self.equipped = true
	self.extended = nil

	self.humanoid = self.tool.Parent:FindFirstChildOfClass("Humanoid")
	self.humanoid.WalkSpeed = Constants.WALKSPEED
	self.groundController.MoveSpeedFactor = 0
	self.abilityManagerActor.Abilities.Jumping.SyncedState:SetAttribute("Enabled", false)
	self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	self.humanoid.JumpHeight = 0

	self.animator:Enable()
	self.input:Enable()
	self.stateMachine:Enable(DefaultState.New(self))
	self.power:Enable()
	self.collect:Enable()
	self.sprint:Enable()
	self.momentum:Enable()
	self.groundController.BalanceRigidityEnabled = true

	local character = LocalPlayer.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	local planeConstraint = humanoidRootPart:FindFirstChild("PlaneConstraint")
	if not planeConstraint then
		planeConstraint = Instance.new("PlaneConstraint")
		planeConstraint.Parent = humanoidRootPart
		planeConstraint.Attachment0 = Workspace:FindFirstChild("PlanePart"):FindFirstChild("Attachment")
		planeConstraint.Attachment1 = humanoidRootPart:FindFirstChild("RootAttachment")
		planeConstraint.Enabled = false
	end

	self.planeConstraint = planeConstraint

	-- ShaftHitbox keeps reverting back to the Stick CollisionGroup unless there's a delay?
	-- Quick fix: Introduces races conditions of setting the CollisionGroup in functions Equip/Unequip
	task.delay(0.1, function()
		for _, descendant in self.tool:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.CollisionGroup = "ClientStick"
			end

			if descendant.Name == "Blade2" then
				descendant.CollisionGroup = "Blade"
			end
		end
	end)

	self.update_connection = RunService.Heartbeat:Connect(function(dt)
		self:Update(dt)
	end)
end

function Stick:Unequip()
	if not self.equipped then
		return
	end
	self.equipped = false

	self.humanoid.JumpHeight = 7.2
	self.humanoid.WalkSpeed = 16
	self.abilityManagerActor.Abilities.Jumping.SyncedState:SetAttribute("Enabled", true)
	self.groundController.MoveSpeedFactor = 1
	self.groundController.BalanceRigidityEnabled = false

	self.animator:Disable()
	self.input:Disable()
	self.stateMachine:Disable()
	self.power:Disable()
	self.collect:Disable()
	self.sprint:Disable()
	self.momentum:Disable()

	self.planeConstraint.Enabled = false

	task.spawn(function()
		local temp = self.tool.Parent
		self.tool.Parent = game.Lighting
		task.wait(1.5)
		self.tool.Parent = temp
	end)

	for _, descendant in self.tool:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "Default"
		end
	end

	if self.update_connection then
		self.update_connection:Disconnect()
		self.update_connection = nil
	end
end

function FHR2(dir, powr)
	local cffer = CFrame.new(Vector3.new(0, 0, 0), dir)
	local sx, sy, sz, m00, m01, m02, m10, m11, m12, m20, m21, m22 = cffer:components()
	local x, y, z = 0, 0, 0
	local h = math.asin(m02)
	if 0 > dir.z then
		z = h / math.rad(90)
		x = -((math.rad(90) - math.abs(h)) / math.rad(90))
	else
		z = h / math.rad(90)
		x = (math.rad(90) - math.abs(h)) / math.rad(90)
	end
	local mag = (powr - 0.4) * 2
	return Vector3.new(x, 0, z).Unit * (1 + mag * 4)
end

function Stick:Initialize()
	self.animator = Animator.New(self)
	self.input = Input.New(self)
	self.stateMachine = StateMachine.New(DefaultState.New(self))
	self.power = Power.New(self)
	self.collect = Collect.New(self)
	self.sprint = Sprint.New(self)
	self.momentum = Momentum.New(self)
	self.controllerManager = LocalPlayer.Character:WaitForChild("ControllerManager")
	self.groundController = LocalPlayer.Character:WaitForChild("ControllerManager"):WaitForChild("GroundController")
	self.abilityManagerActor = LocalPlayer.Character:WaitForChild("AbilityManagerActor")

	table.insert(
		self.connections,
		self.tool.Equipped:Connect(function()
			self:Equip()
		end)
	)
	table.insert(
		self.connections,
		self.tool.Unequipped:Connect(function()
			self:Unequip()
		end)
	)

	table.insert(
		self.connections,
		RagdollEvent.OnClientEvent:Connect(function(velocity: Vector3, duration: number, shove: boolean, power: number)
			local character = LocalPlayer.Character
			if not character then
				return
			end
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return
			end

			if not shove then
				self.abilityManagerActor.Abilities.GettingUp.SyncedState:SetAttribute("Enabled", false)
				self.abilityManagerActor.Abilities.GettingUp.SyncedState:SetAttribute("Active", false)
				self.abilityManagerActor.Abilities.Running.SyncedState:SetAttribute("Enabled", false)
				self.abilityManagerActor.Abilities.Running.SyncedState:SetAttribute("Active", false)
				self.abilityManagerActor.Abilities.FallingDown.SyncedState:SetAttribute("Enabled", true)
				self.abilityManagerActor.Abilities.FallingDown.SyncedState:SetAttribute("Active", true)
				self.controllerManager.ActiveController = nil

				self.groundController.BalanceSpeed = 0
				self.groundController.BalanceMaxTorque = 0
				self.groundController.BalanceRigidityEnabled = false
			end
			self.momentum.bodyVelocity.Velocity = velocity

			local head = character:FindFirstChild("Head")
			if not head then
				return
			end

			local av = Instance.new("AngularVelocity")
			av.Name = "HitRotate"
			av.Attachment0 = humanoidRootPart:FindFirstChild("RootAttachment")
			av.RelativeTo = Enum.ActuatorRelativeTo.World
			av.AngularVelocity = FHR2(velocity.Unit * Vector3.new(1, 0, 1).Unit, (power / 100))
			av.MaxTorque = 5000000
			av.Parent = humanoidRootPart

			--[[local BF = Instance.new("BodyAngularVelocity")
			BF.Name = "HitRotate"
			BF.MaxTorque = Vector3.new(5000000, 5000000, 5000000)
			BF.P = 2500
			BF.AngularVelocity = FHR2(velocity.Unit * Vector3.new(1, 0, 1).Unit, 1)
			BF.Parent = humanoidRootPart--]]

			task.delay(1, function()
				--av:Destroy()
				--BF:Destroy()
			end)

			--humanoidRootPart.AssemblyAngularVelocity = velocity.Unit

			self.customLock:SetTorquePower(0)

			print("Hit")
			self.isHit = time() + duration
			self.ragdolled = true
		end)
	)
end

function Stick:IsHit()
	return time() < self.isHit
end

function Stick:HasPuck()
	return self.hasPuck
end

function Stick:Destroy()
	print("Destroyed Stick")
	self:Unequip()
	DisconnectAndClear(self.connections)
	self.animator:Destroy()
	self.input:Destroy()
	self.stateMachine:Destroy()
	self.power:Destroy()
	self.collect:Destroy()
	self.sprint:Destroy()
	self.momentum:Destroy()
end

return Stick
