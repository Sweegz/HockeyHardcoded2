local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local PuckController2 = require(script.Parent.PuckController2)
local Chrono = require(ReplicatedStorage.ModdedPackages.Chrono)

local PuckAsset = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Pucks"):WaitForChild("Puck") :: BasePart

local ClientGoalieController = {}

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

CollectionService:GetInstanceAddedSignal("Replicated"):Connect(function(instance: Instance)
	--addPuck(instance :: BasePart)
end)

for _, instance in CollectionService:GetTagged("Replicated") do
	--addPuck(instance :: BasePart)
end

function ClientGoalieController:Start()
	if not Workspace:GetAttribute("CustomReplication") then
		return
	end

	--[[RunService.PreAnimation:Connect(function(dt)
		for _, goalie: Model in CollectionService:GetTagged("GoalieModel") do
			local entity = Chrono.Holder.GetEntityFromModel(goalie)
			if not entity then
				continue
			end

			print(Chrono.Entity.GetPrimaryPart(entity))

			local cf = GetInterpolated(entity)
			if not cf then
				continue
			end

			print(cf)

			goalie.PrimaryPart.CFrame = cf
		end
	end)--]]
end

return ClientGoalieController
