local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local CustomLockController = {
	enabled = true,
	SHIFT_LOCK = false,
}

local function CreateBodyGyro(humanoidRootPart: BasePart)
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.D = 500
	bodyGyro.MaxTorque = Vector3.new(0, 1000000000, 0)
	bodyGyro.P = 10000
	bodyGyro.Parent = humanoidRootPart

	return bodyGyro
end

function CustomLockController:Load()
	--[[LocalPlayer.CharacterAdded:Connect(function()
		CustomLockController.SHIFT_LOCK = false
	end)--]]
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then
		return
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		CustomLockController.SHIFT_LOCK = not CustomLockController.SHIFT_LOCK
	end
end)

function CustomLockController:Start()
	local conn = RunService.Heartbeat:Connect(function(dt)
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

		if CustomLockController.SHIFT_LOCK then
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
	CustomLockController.enabled = true
end

function CustomLockController:Disable()
	CustomLockController.enabled = false
end

return CustomLockController
