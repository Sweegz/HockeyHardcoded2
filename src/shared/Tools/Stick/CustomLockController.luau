local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local DisconnectAndClear = require(ReplicatedStorage.Shared.Utility.DisconnectAndClear)

local function CreateBodyGyro(humanoidRootPart: BasePart)
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.D = 500
	bodyGyro.MaxTorque = Vector3.new(0, 1000000000, 0)
	bodyGyro.P = 10000
	bodyGyro.Parent = humanoidRootPart

	return bodyGyro
end

local CustomLockController = {}

CustomLockController.__index = CustomLockController

function CustomLockController.New(stickController)
	local self = {
		stickController = stickController,
		enabled = false,
		MouseLock = false,
		connections = {},
		bodyGyro = nil,
	}

	setmetatable(self, CustomLockController)

	self:Initialize()

	return self
end

function CustomLockController:Tick(dt: number)
	local humanoid = self.stickController.humanoid
	local character = humanoid.Parent

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	if not humanoidRootPart:FindFirstChild("BodyGyro") or not self.bodyGyro then
		self.bodyGyro = CreateBodyGyro(humanoidRootPart)
	end

	local camera = Workspace:FindFirstChild("Camera")
	if not camera then
		return
	end

	if self.bodyGyro.MaxTorque.Y > 0 then
		humanoid.AutoRotate = false
	else
		humanoid.AutoRotate = true
	end

	local firstPerson = (workspace.CurrentCamera.CFrame.Position - character.Head.Position).Magnitude <= 1

	if self.MouseLock or firstPerson then
		local _, cameraOrientationY = camera.CFrame:ToOrientation()
		self.bodyGyro.CFrame = CFrame.new(camera.CFrame.Position) * CFrame.Angles(0, cameraOrientationY, 0)
	elseif humanoid.MoveDirection.Magnitude > 0 then
		self.bodyGyro.CFrame = CFrame.new(Vector3.new(0, 0, 0), humanoid.MoveDirection)
	else
		self.bodyGyro.CFrame = humanoidRootPart.CFrame
	end
end

function CustomLockController:Initialize()
	table.insert(
		self.connections,
		UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
			if gameProcessedEvent then
				return
			end

			if input.KeyCode == Enum.KeyCode.LeftControl and self.enabled then
				self.MouseLock = not self.MouseLock
			end
		end)
	)
end

function CustomLockController:Enable()
	self.enabled = true
	self.MouseLock = false
end

function CustomLockController:Disable()
	self.enabled = false
	self.MouseLock = false
	self.bodyGyro:Destroy()
	self.bodyGyro = nil

	self.stickController.humanoid.AutoRotate = true
end

function CustomLockController:Destroy()
	self:Disable()
	DisconnectAndClear(self.connections)
end

return CustomLockController
