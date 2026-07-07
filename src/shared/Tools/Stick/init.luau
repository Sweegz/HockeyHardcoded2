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
local CustomLockController = require(script.CustomLockController)
local Sprint = require(script.Sprint)
local Momentum = require(script.Momentum)

local DisconnectAndClear = require(ReplicatedStorage.Shared.Utility.DisconnectAndClear)

local LocalPlayer = Players.LocalPlayer

local StickController = {}
StickController.__index = StickController

function StickController.New(tool: Tool)
	local self = {
		tool = tool,
		equipped = false,
		connections = {},
		extended = nil,
		hasPuck = false,
		lastUpdate = 0,
		accumulatedTime = 0,
	}
	setmetatable(self, StickController)

	print("Created StickController")

	self:Initialize()

	return self
end

local FIXED_RATE = 1 / 60

function StickController:Update(dt: number)
	self.hasPuck = PuckController:GetOwner() == LocalPlayer

	self.collect:Tick(dt)

	-- Systems running at fixed rate
	while self.accumulatedTime >= FIXED_RATE do
		local deltaTime = FIXED_RATE

		self.input:Tick(deltaTime)
		self.power:Tick(deltaTime)
		self.state_machine:Tick(deltaTime)
		self.sprint:Tick(deltaTime)
		self.momentum:Tick(deltaTime)
		self.customLockController:Tick(deltaTime)

		self.accumulatedTime -= FIXED_RATE
	end

	self.accumulatedTime += dt
end

function StickController:Equip()
	if self.equipped then
		return
	end
	self.equipped = true
	self.extended = nil

	self.humanoid = self.tool.Parent:FindFirstChildOfClass("Humanoid")
	self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	self.humanoid.JumpHeight = 0
	self.humanoid.WalkSpeed = 38

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

function StickController:Unequip()
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

function StickController:Initialize()
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
end

function StickController:Destroy()
	print("Destroyed StickController")
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

return StickController
