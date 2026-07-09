local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local DisconnectAndClear = require(ReplicatedStorage.Shared.Utility.DisconnectAndClear)

local BODYGYRO_D = 500
local BODYGYRO_MAXTORQUE = Vector3.new(0, 1000000000, 0)
local BODYGYRO_P = 10000

local function CreateBodyGyro(humanoidRootPart: BasePart)
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.D = BODYGYRO_D
	bodyGyro.MaxTorque = BODYGYRO_MAXTORQUE
	bodyGyro.P = BODYGYRO_P
	bodyGyro.Parent = humanoidRootPart

	return bodyGyro
end

local CustomLock = {}

CustomLock.__index = CustomLock

function CustomLock.New(ctx)
	local self = {
		ctx = ctx,
		enabled = false,
		MouseLock = false,
		forcedMouseLock = false,
		connections = {},
		bodyGyro = nil,
	}

	setmetatable(self, CustomLock)

	self:Initialize()

	return self
end

function CustomLock:Tick(dt: number)
	local humanoid = self.ctx.humanoid
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

	if self.MouseLock or self.forcedMouseLock or firstPerson then
		local _, cameraOrientationY = camera.CFrame:ToOrientation()
		self.bodyGyro.CFrame = CFrame.new(camera.CFrame.Position) * CFrame.Angles(0, cameraOrientationY, 0)
	elseif humanoid.MoveDirection.Magnitude > 0 then
		self.bodyGyro.CFrame = CFrame.new(Vector3.new(0, 0, 0), humanoid.MoveDirection)
	else
		self.bodyGyro.CFrame = humanoidRootPart.CFrame
	end
end

function CustomLock:Initialize()
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

function CustomLock:Enable()
	self.enabled = true
	self.MouseLock = false
	self.forcedMouseLock = false
end

function CustomLock:SetTorquePower(value: number)
	self.bodyGyro.P = value
end

function CustomLock:ResetTorquePower()
	self.bodyGyro.P = BODYGYRO_P
end

function CustomLock:Disable()
	self.enabled = false
	self.MouseLock = false
	self.forcedMouseLock = false
	self.bodyGyro:Destroy()
	self.bodyGyro = nil

	self.ctx.humanoid.AutoRotate = true
end

function CustomLock:ForceMouseLock(forced: boolean)
	self.forcedMouseLock = forced
end

function CustomLock:Destroy()
	self:Disable()
	DisconnectAndClear(self.connections)
end

return CustomLock
