local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local PuckController = require(StarterPlayer.StarterPlayerScripts.Controllers.PuckController)
local Animator = require(script.Animator)
local Input = require(script.Input)
local StateMachine = require(script.StateMachine)
local Power = require(script.Power)
local Collect = require(script.Collect)
local Constants = require(script.Constants)
local CustomLockController = require(script.CustomLockController)
local Sprint = require(script.Sprint)
local Momentum = require(script.Momentum)

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
	}
	setmetatable(self, Stick)

	print("Created Stick")

	self:Initialize()

	return self
end

local FIXED_RATE = 1 / 60

function Stick:Update(dt: number)
	self.hasPuck = PuckController:GetOwner() == LocalPlayer

	self.power:Tick(dt)

	while self.accumulatedTime >= FIXED_RATE do
		local deltaTime = FIXED_RATE
		self.input:Tick(deltaTime)

		self.state_machine:Tick(deltaTime)
		self.collect:Tick(deltaTime)
		self.sprint:Tick(deltaTime)
		self.momentum:Tick(deltaTime)
		self.customLockController:Tick(deltaTime)

		-- Reset time
		self.accumulatedTime -= FIXED_RATE
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
	self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	self.humanoid.JumpHeight = 0
	self.humanoid.WalkSpeed = Constants.WALKSPEED

	self.animator:Enable()
	self.input:Enable()
	self.state_machine:Enable(require(script.StateMachine.DefaultState).New(self))
	self.power:Enable()
	self.collect:Enable()
	self.sprint:Enable()
	self.momentum:Enable()
	self.customLockController:Enable()

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
	self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)

	self.animator:Disable()
	self.input:Disable()
	self.state_machine:Disable()
	self.power:Disable()
	self.collect:Disable()
	self.sprint:Disable()
	self.momentum:Disable()
	self.customLockController:Disable()

	task.spawn(function()
		local temp = self.tool.Parent
		self.tool.Parent = game.Lighting
		task.wait(1.5)
		self.tool.Parent = temp
	end)

	if self.update_connection then
		self.update_connection:Disconnect()
		self.update_connection = nil
	end
end

function Stick:Initialize()
	self.animator = Animator.New(self)
	self.input = Input.New(self)
	self.state_machine = StateMachine.New(require(script.StateMachine.DefaultState).New(self))
	self.power = Power.New(self)
	self.collect = Collect.New(self)
	self.sprint = Sprint.New(self)
	self.momentum = Momentum.New(self)
	self.customLockController = CustomLockController.New(self)

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
		RagdollEvent.OnClientEvent:Connect(function(power: number, velocity: Vector3, duration: number, shove: boolean)
			print("LOLLLL", power, velocity, duration)

			self.momentum.bodyVelocity.Velocity = velocity

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
	self.state_machine:Destroy()
	self.power:Destroy()
	self.collect:Destroy()
	self.sprint:Destroy()
	self.momentum:Destroy()
end

return Stick
