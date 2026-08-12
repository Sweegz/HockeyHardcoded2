local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SirenController = {}

local function add_siren(instance: Instance)
	if not instance:IsA("BasePart") then
		return
	end

	local siren = ReplicatedStorage:WaitForChild("Siren")
	if not siren:IsA("Model") then
		return
	end

	local clone = siren:Clone()
	clone.Parent = instance
	clone:PivotTo(instance.CFrame)
end

for _, instance in CollectionService:GetTagged("Alarm") do
	add_siren(instance)
end
CollectionService:GetInstanceAddedSignal("Alarm"):Connect(add_siren)

local function startSiren(siren: BasePart)
	local l1 = siren:FindFirstChild("L1", true)
	local l2 = siren:FindFirstChild("L2", true)
	local motor = siren:FindFirstChild("Motor", true)

	if not l1:IsA("BasePart") or not l2:IsA("BasePart") or not motor:IsA("BasePart") then
		return
	end

	l1.Transparency = 0.3
	l2.Transparency = 0.3
	l1.PointLight.Enabled = true
	l2.PointLight.Enabled = true
	motor.HingeConstraint.MotorMaxTorque = 10000000
end

local function stopSiren(siren: BasePart)
	local l1 = siren:FindFirstChild("L1", true)
	local l2 = siren:FindFirstChild("L2", true)
	local motor = siren:FindFirstChild("Motor", true)

	if not l1:IsA("BasePart") or not l2:IsA("BasePart") or not motor:IsA("BasePart") then
		return
	end

	l1.Transparency = 1
	l2.Transparency = 1
	l1.PointLight.Enabled = false
	l2.PointLight.Enabled = false
	motor.HingeConstraint.MotorMaxTorque = 0
end

for _, part: BasePart in CollectionService:GetTagged("ActiveSiren") do
	startSiren(part)
end

CollectionService:GetInstanceAddedSignal("ActiveSiren"):Connect(function(instance: Instance)
	startSiren(instance :: BasePart)
end)

CollectionService:GetInstanceRemovedSignal("ActiveSiren"):Connect(function(instance: Instance)
	stopSiren(instance :: BasePart)
end)

return SirenController
