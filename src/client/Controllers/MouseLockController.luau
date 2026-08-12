local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local DisconnectAndClear = require(ReplicatedStorage.Shared.Utility.DisconnectAndClear)
local GetValidMouseHit = require(ReplicatedStorage.Shared.Utility.GetValidMouseHit)

local LocalPlayer = Players.LocalPlayer

local BODYGYRO_D = 500
local BODYGYRO_MAXTORQUE = Vector3.new(0, 1000000000, 0)
local BODYGYRO_P = 10000

local RotatorModel = ReplicatedStorage:WaitForChild("Rotator") :: Model

local MouseLockController = {
	enabled = true,
	MouseLock = false,
	forcedMouseLock = false,
	followMouse = false,
	connections = {},
	bodyGyro = nil,
	alignOrientation = nil,
}

local function CreateBodyGyro(humanoidRootPart: BasePart)
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.D = BODYGYRO_D
	bodyGyro.MaxTorque = BODYGYRO_MAXTORQUE
	bodyGyro.P = BODYGYRO_P
	bodyGyro.Parent = humanoidRootPart

	return bodyGyro
end

function MouseLockController:Load() end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then
		return
	end

	if input.KeyCode == Enum.KeyCode.LeftControl and MouseLockController.enabled then
		MouseLockController.MouseLock = not MouseLockController.MouseLock
	end
end)

local accumulatedTime = 0

function MouseLockController:Start()
	local _conn = RunService.PreRender:Connect(function(dt)
		--[[if accumulatedTime < 1 / 60 then
			accumulatedTime += dt
		end

		accumulatedTime = 0--]]

		local character = LocalPlayer.Character
		if not character then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			return
		end

		if not humanoidRootPart:FindFirstChild("BodyGyro", true) or not MouseLockController.bodyGyro then
			MouseLockController.bodyGyro = CreateBodyGyro(humanoidRootPart)
		end

		if not MouseLockController.bodyGyro then
			return
		end

		local camera = Workspace:FindFirstChild("Camera")
		if not camera then
			return
		end

		if MouseLockController.bodyGyro.MaxTorque.Y > 0 or humanoidRootPart.Anchored then
			humanoid.AutoRotate = false
		else
			humanoid.AutoRotate = true
			--MouseLockController.bodyGyro.Parent.Rotation = humanoidRootPart.Rotation * Vector3.new(0, 1, 0)
		end

		local firstPerson = (workspace.CurrentCamera.CFrame.Position - character.Head.Position).Magnitude <= 1

		if not MouseLockController.followMouse then
			if MouseLockController.MouseLock or MouseLockController.forcedMouseLock or firstPerson then
				local _, cameraOrientationY = camera.CFrame:ToOrientation()
				MouseLockController.bodyGyro.CFrame = CFrame.new(camera.CFrame.Position)
					* CFrame.Angles(0, cameraOrientationY, 0)
			elseif humanoid.MoveDirection.Magnitude > 0.001 then
				local moveDirection = humanoid.MoveDirection.Unit

				MouseLockController.bodyGyro.CFrame =
					CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + moveDirection)
			else
				local _, currentYaw = humanoidRootPart.CFrame:ToOrientation()

				MouseLockController.bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position)
					* CFrame.Angles(0, currentYaw, 0)
			end
		else
			local _, yawAngle = CFrame.new(humanoidRootPart.Position, GetValidMouseHit()):ToOrientation()
			--MouseLockController.bodyGyro.MaxTorque = Vector3.new(0, 75, 0)
			MouseLockController.bodyGyro.CFrame = CFrame.Angles(0, yawAngle, 0)
		end
	end)
end

function MouseLockController:Enable()
	self.enabled = true
	self.MouseLock = false
	self.forcedMouseLock = false
end

function MouseLockController:ForceMouseLock(forced: boolean)
	self.forcedMouseLock = forced
end

function MouseLockController:SetTorquePower(value: number)
	self.bodyGyro.P = value
end

function MouseLockController:FollowMouse(followMouse: boolean)
	self.followMouse = followMouse
end

function MouseLockController:ResetTorquePower()
	self.bodyGyro.P = BODYGYRO_P
end

function MouseLockController:Disable()
	self.enabled = false
	self.MouseLock = false
	self.forcedMouseLock = false
	if self.bodyGyro then
		self.bodyGyro:Destroy()
		self.bodyGyro = nil
	end

	if self.alignOrientation then
		self.alignOrientation:Destroy()
		self.alignOrientation = nil
	end
end

function MouseLockController:Destroy()
	self:Disable()
	DisconnectAndClear(self.connections)
end

return MouseLockController
