local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local CustomLockController = {
	enabled = false,
	MouseLock = false,
}

local function CreateBodyGyro(humanoidRootPart: BasePart)
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.D = 500
	bodyGyro.MaxTorque = Vector3.new(0, 1000000000, 0)
	bodyGyro.P = 10000
	bodyGyro.Parent = humanoidRootPart

	return bodyGyro
end

function CustomLockController:Load() end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then
		return
	end

	if input.KeyCode == Enum.KeyCode.LeftControl and CustomLockController.enabled then
		CustomLockController.MouseLock = not CustomLockController.MouseLock
	end
end)

function CustomLockController:Start()
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

		local bodyGyro = humanoidRootPart:FindFirstChild("BodyGyro")
		if not CustomLockController.enabled then
			if bodyGyro then
				bodyGyro:Destroy()
				humanoid.AutoRotate = true
			end
			return
		end

		if not bodyGyro then
			bodyGyro = CreateBodyGyro(humanoidRootPart)
		end

		local camera = Workspace:FindFirstChild("Camera")
		if not camera then
			return
		end

		if bodyGyro.MaxTorque.Y > 0 then
			humanoid.AutoRotate = false
		else
			humanoid.AutoRotate = true
		end

		local firstPerson = (workspace.CurrentCamera.CFrame.Position - character.Head.Position).Magnitude <= 1

		if CustomLockController.MouseLock or firstPerson then
			local _, cameraOrientationY = camera.CFrame:ToOrientation()
			bodyGyro.CFrame = CFrame.new(camera.CFrame.Position) * CFrame.Angles(0, cameraOrientationY, 0)
		elseif humanoid.MoveDirection.Magnitude > 0 then
			bodyGyro.CFrame = CFrame.new(Vector3.new(0, 0, 0), humanoid.MoveDirection)
		else
			bodyGyro.CFrame = humanoidRootPart.CFrame
		end
	end)
end

function CustomLockController:Enable()
	self.enabled = true
	self.MouseLock = false
end

function CustomLockController:Disable()
	self.enabled = false
	self.MouseLock = false
end

return CustomLockController
