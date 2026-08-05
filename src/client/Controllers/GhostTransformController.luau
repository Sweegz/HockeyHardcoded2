local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")

local PuckController2 = require(script.Parent.PuckController2)
local EntityMap = require(StarterPlayer.StarterPlayerScripts.EntityMap)
local EntityMap2 = require(StarterPlayer.StarterPlayerScripts.EntityMap2)
local Chrono = require(ReplicatedStorage.ModdedPackages.Chrono)

local GhostTransformController = {}

local function GetInterpolated(entity): CFrame?
	local snapshot = entity.snapshot
	if not snapshot then
		return
	end

	local targetTime = Chrono.Entity.GetTargetRenderTime(entity)
	local targetCFrame = snapshot:GetAt(targetTime)

	if not targetCFrame then
		return
	end

	return targetCFrame
end

local function addPuck(instance: Instance)
	print(instance)

	instance.CanCollide = true
	instance.CollisionGroup = "OnlyBoards"
	instance.Transparency = 1

	clientPuck = ReplicatedStorage.Assets.Pucks.Puck:clone()
	clientPuck.Parent = instance
	clientPuck.Anchored = true
	clientPuck.CanCollide = false
	--clientPuck.BrickColor = BrickColor.Green()
	clientPuck.CollisionGroup = "Nothing"
	clientPuck.Name = "Transform"

	local visualPuck = clientPuck:Clone()
	visualPuck.Name = "Visual"
	visualPuck.Anchored = false
	visualPuck.Parent = instance
	visualPuck.Transparency = 0

	CollectionService:AddTag(visualPuck, "Collectable")
	CollectionService:AddTag(clientPuck, "Collectable")

	local attach1 = Instance.new("Attachment")
	attach1.Parent = clientPuck

	local attach2 = Instance.new("Attachment")
	attach2.Parent = visualPuck

	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Parent = visualPuck
	alignPosition.Mode = Enum.PositionAlignmentMode.TwoAttachment
	alignPosition.Attachment0 = attach2
	alignPosition.Attachment1 = attach1
	alignPosition.MaxForce = math.huge
	alignPosition.Responsiveness = 180

	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Parent = visualPuck
	alignOrientation.Attachment0 = attach2
	alignOrientation.Attachment1 = attach1
	alignOrientation.MaxTorque = math.huge
	alignOrientation.Responsiveness = 150

	clientPuck.Transparency = 1

	instance.AncestryChanged:Once(function()
		if instance.Parent == nil then
			local client = EntityMap[instance]
			if client then
				visualPuck:Destroy()
				client:Destroy()
			end
			EntityMap[instance] = nil
		end
	end)

	EntityMap[instance] = clientPuck
	EntityMap2[instance] = visualPuck
end

CollectionService:GetInstanceAddedSignal("Replicated"):Connect(function(instance: Instance)
	addPuck(instance)
end)

for _, instance in CollectionService:GetTagged("Replicated") do
	addPuck(instance)
end

function GhostTransformController:Start()
	if not Workspace:GetAttribute("CustomReplication") then
		return
	end

	RunService.PreAnimation:Connect(function(dt)
		for _, puck in CollectionService:GetTagged("Replicated") and CollectionService:GetTagged("Puck") do
			local entity = Chrono.Holder.GetEntityFromModel(puck)
			if not entity then
				continue
			end

			local cf = GetInterpolated(entity)
			if not cf then
				continue
			end

			local clientPuck = EntityMap[puck]
			if not clientPuck then
				continue
			end

			local ownerId = PuckController2:GetOwner(puck)

			local weld = puck:FindFirstChild("weld")
			if ownerId then
				Chrono.Entity.Clear(entity)
			else
				clientPuck.CFrame = cf
			end
		end
	end)
end

script:Destroy()

return GhostTransformController
