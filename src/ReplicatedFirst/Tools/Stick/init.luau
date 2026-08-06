local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")

local CollectController = require(StarterPlayer.StarterPlayerScripts.Controllers.CollectController)
local MouseLockController = require(StarterPlayer.StarterPlayerScripts.Controllers.MouseLockController)
local PuckController = require(StarterPlayer.StarterPlayerScripts.Controllers.PuckController2)

local Animator = require(script.Animator)
local Input = require(script.Input)
local StateMachine = require(script.StateMachine)
local Power = require(script.Power)
local Collect = require(script.Collect)
local Constants = require(script.Constants)
local Sprint = require(script.Sprint)
local Momentum = require(script.Momentum)

local DefaultState = require(script.StateMachine.DefaultState)

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
		hit = {
			velocity = Vector3.zero,
			shove = false,
		},
	}
	setmetatable(self, Stick)

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

	self.hasPuck = PuckController:HasPuck(LocalPlayer)

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

	if not self:IsHit() then
		self.hit.velocity = Vector3.zero
		self.hit.shove = false
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

	self.customLock:FollowMouse(false)

	local character = LocalPlayer.Character
	if not character then
		return
	end

	for _, child in character:GetChildren() do
		if child.Name:match("Collider") then
			child.CanCollide = false
		end
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
	self.ctx.abilityManagerActor.Abilities.FallingDown.SyncedState:SetAttribute("Enabled", true)
	self.groundController.MoveSpeedFactor = 1
	self.groundController.BalanceRigidityEnabled = false

	self.customLock:FollowMouse(false)

	self.animator:Disable()
	self.input:Disable()
	self.stateMachine:Disable()
	self.power:Disable()
	self.collect:Disable()
	self.sprint:Disable()
	self.momentum:Disable()

	if self:HasPuck() then
		CollectController:Drop(self:HasPuck())
	end

	local character = LocalPlayer.Character
	if character then
		local groundSensor = character:FindFirstChild("FloorSensor", true)
		if groundSensor then
			groundSensor.SearchDistance = 3.3
		end
	end

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
			self.hit.velocity = velocity
			self.hit.shove = shove

			LocalPlayer.Character.PrimaryPart.AssemblyAngularVelocity = FHR2(velocity.Unit, power / 100)

			self.momentum:SetMoving(false)
			self.isHit = time() + duration
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
