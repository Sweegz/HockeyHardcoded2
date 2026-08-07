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
local BODYGYRO_P = 8150

local MouseLockController = {
	enabled = true,
	MouseLock = false,
	forcedMouseLock = false,
	followMouse = false,
	connections = {},
	bodyGyro = nil,
}

local function CreateBodyGyro(humanoidRootPart: BasePart)
	local follower = humanoidRootPart:FindFirstChild("Follower", true)

	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.D = BODYGYRO_D
	bodyGyro.MaxTorque = BODYGYRO_MAXTORQUE
	bodyGyro.P = BODYGYRO_P
	bodyGyro.Parent = follower

	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Attachment0 = humanoidRootPart.RootAttachment
	alignOrientation.Attachment1 = follower.Attachment
	alignOrientation.Parent = humanoidRootPart
	alignOrientation.Responsiveness = math.huge
	alignOrientation.MaxTorque = math.huge

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

function MouseLockController:Start()
	local _conn = RunService.Heartbeat:Connect(function(_dt)
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

		local camera = Workspace:FindFirstChild("Camera")
		if not camera then
			return
		end

		--[[local facingMoveDirection = character:FindFirstChild("FacingMoveDirection", true)
		if not facingMoveDirection then
			return
		end

		local facingMoveDirectionState = facingMoveDirection:FindFirstChild("SyncedState")
		if not facingMoveDirectionState then
			return
		end --]]

		if MouseLockController.bodyGyro.MaxTorque.Y > 0 or humanoidRootPart.Anchored then
			--facingMoveDirectionState:SetAttribute("Enabled", false)
			humanoid.AutoRotate = false
		else
			--facingMoveDirectionState:SetAttribute("Enabled", true)
			humanoid.AutoRotate = true
		end

		local firstPerson = (workspace.CurrentCamera.CFrame.Position - character.Head.Position).Magnitude <= 1

		if not MouseLockController.followMouse then
			if MouseLockController.MouseLock or MouseLockController.forcedMouseLock or firstPerson then
				local _, cameraOrientationY = camera.CFrame:ToOrientation()
				MouseLockController.bodyGyro.CFrame = CFrame.new(camera.CFrame.Position)
					* CFrame.Angles(0, cameraOrientationY, 0)
			elseif humanoid.MoveDirection.Magnitude > 0 then
				MouseLockController.bodyGyro.CFrame = CFrame.new(Vector3.new(0, 0, 0), humanoid.MoveDirection)
			else
				MouseLockController.bodyGyro.CFrame = humanoidRootPart.CFrame
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
	self.bodyGyro:Destroy()
	self.bodyGyro = nil
end

function MouseLockController:Destroy()
	self:Disable()
	DisconnectAndClear(self.connections)
end

return MouseLockController
