local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local PuckController2 = require(script.Parent.PuckController2)
local Chrono = require(ReplicatedStorage.ModdedPackages.Chrono)

local PuckAsset = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Pucks"):WaitForChild("Puck") :: BasePart

local ClientPuckController = {}

local function GetInterpolated(entity): CFrame?
	local snapshot = entity.snapshot
	if not snapshot then
		return nil
	end

	local targetTime = Chrono.Entity.GetTargetRenderTime(entity)
	local targetCFrame = snapshot:GetAt(targetTime)

	if not targetCFrame then
		return nil
	end

	return targetCFrame :: CFrame
end

local function addPuck(instance: BasePart)
	instance.CanCollide = true
	instance.CollisionGroup = "OnlyBoards"
	instance.Transparency = 1
	local uuid = instance:GetAttribute("UUID")

	local transformPuck = PuckAsset:Clone()
	transformPuck.Name = "Transform"
	transformPuck.Parent = instance
	transformPuck.Anchored = true
	transformPuck.CanCollide = false
	transformPuck.CollisionGroup = "Nothing"
	transformPuck.Transparency = 1
	transformPuck:SetAttribute("UUID", uuid)
	CollectionService:AddTag(transformPuck, "Collectable")

	local attach1 = Instance.new("Attachment")
	attach1.Parent = transformPuck

	local viewPuck = PuckAsset:Clone()
	viewPuck.Name = "View"
	viewPuck.Parent = instance
	viewPuck.Anchored = false
	viewPuck.Parent = instance
	viewPuck.CanCollide = false
	viewPuck.CollisionGroup = "Nothing"
	viewPuck.Transparency = 0
	viewPuck:SetAttribute("UUID", uuid)
	CollectionService:AddTag(viewPuck, "Collectable")

	local attach2 = Instance.new("Attachment")
	attach2.Parent = viewPuck

	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Parent = viewPuck
	alignPosition.Mode = Enum.PositionAlignmentMode.TwoAttachment
	alignPosition.Attachment0 = attach2
	alignPosition.Attachment1 = attach1
	alignPosition.MaxForce = math.huge
	alignPosition.Responsiveness = 180

	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Parent = viewPuck
	alignOrientation.Attachment0 = attach2
	alignOrientation.Attachment1 = attach1
	alignOrientation.MaxTorque = math.huge
	alignOrientation.Responsiveness = 150

	instance.AncestryChanged:Once(function()
		if instance.Parent == nil then
			if transformPuck then
				transformPuck:Destroy()
			end

			if viewPuck then
				viewPuck:Destroy()
			end
		end
	end)
end

CollectionService:GetInstanceAddedSignal("Replicated"):Connect(function(instance: Instance)
	addPuck(instance :: BasePart)
end)

for _, instance in CollectionService:GetTagged("Replicated") do
	addPuck(instance :: BasePart)
end

function ClientPuckController:Start()
	if not Workspace:GetAttribute("CustomReplication") then
		return
	end

	RunService.PreAnimation:Connect(function(dt)
		for _, puck: BasePart in CollectionService:GetTagged("Replicated") and CollectionService:GetTagged("Puck") do
			local entity = Chrono.Holder.GetEntityFromModel(puck)
			if not entity then
				continue
			end

			local cf = GetInterpolated(entity)
			if not cf then
				continue
			end

			local transformPuck = puck:FindFirstChild("Transform")
			if not transformPuck or not transformPuck:IsA("BasePart") then
				continue
			end

			local ownerId = PuckController2:GetOwner(puck)

			if ownerId then
				Chrono.Entity.Clear(entity)
			else
				--transformPuck.CFrame = cf
			end

			puck:SetAttribute("cf", cf)
		end
	end)

	RunService.PreSimulation:Connect(function(dt)
		for _, puck: BasePart in CollectionService:GetTagged("Replicated") and CollectionService:GetTagged("Puck") do
			local transformPuck = puck:FindFirstChild("Transform")
			if not transformPuck or not transformPuck:IsA("BasePart") then
				continue
			end

			local cf = puck:GetAttribute("cf") :: CFrame
			if not cf then
				return
			end

			local ownerId = PuckController2:GetOwner(puck)
			if not ownerId then
				transformPuck.CFrame = cf
			end
		end
	end)
end

script:Destroy()

return ClientPuckController
