local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Animator = require(script.Animator)
local Input = require(script.Input)
local StateMachine = require(script.StateMachine)
local Power = require(script.Power)
local Collect = require(script.Collect)
local Momentum = require(script.Momentum)

local disconnectAndClear = require(ReplicatedStorage.Shared.Utility.disconnectAndClear)

local StickController = {}
StickController.__index = StickController

function StickController.New(tool: Tool)
	local self = {
		tool = tool,
		equipped = false,
		connections = {},
		extended = nil,
	}
	setmetatable(self, StickController)

	self:Initialize()

	return self
end

function StickController:Update(dt: number)
	self.state_machine:Tick(dt)
	self.collect:Tick(dt)
	self.power:Tick(dt)
	self.momentum:Tick(dt)
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
	self.momentum:Enable()

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
	self.momentum:Disable()

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
	self.momentum = Momentum.New(self)

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
	self:Unequip()
	disconnectAndClear(self.connections)
	self.animator:Destroy()
	self.input:Destroy()
end

return StickController
