local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PostsService = require(script.Parent.PostsService)
local Chrono = require(ReplicatedStorage.ModdedPackages.Chrono)

local PuckModel = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Pucks"):WaitForChild("Puck")
local PuckFolder = Workspace:WaitForChild("Pucks")

local COOLDOWN = 0.5

local PucksCache: { BasePart } = {}

local PuckService = {}

function PuckService:Create(position: Vector3, replicate: boolean)
	local clone = PuckModel:Clone() :: BasePart
	clone.Parent = PuckFolder
	clone.Position = position
	clone:SetNetworkOwner(nil)

	clone:SetAttribute("Owner", nil)
	clone:SetAttribute("Cooldown", 0)
	clone:SetAttribute("Playable", true)
	clone:SetAttribute("UUID", HttpService:GenerateGUID(false))
	CollectionService:AddTag(clone, "Puck")

	if Workspace:GetAttribute("CustomReplication") and replicate then
		print("YES")
		Chrono.Entity.new("Default", clone)
		CollectionService:AddTag(clone, "Replicated")
	else
		CollectionService:AddTag(clone, "Collectable")
	end

	table.insert(PucksCache, clone)

	return clone
end

function PuckService:SetMainPuck(puck: BasePart)
	for _, p in CollectionService:GetTagged("MainPuck") do
		CollectionService:RemoveTag(p, "MainPuck")
	end

	CollectionService:AddTag(puck, "MainPuck")
end

function PuckService:GetMainPuck(): BasePart?
	for _, p in CollectionService:GetTagged("MainPuck") do
		return p :: BasePart
	end

	return nil
end

function PuckService:IsPlayable(puck: BasePart)
	return puck:GetAttribute("Playable")
end

function PuckService:GetPuckViaUUID(uuid: string): BasePart?
	for _, puck in CollectionService:GetTagged("Puck") do
		if puck:GetAttribute("UUID") == uuid then
			return puck :: BasePart
		end
	end

	return nil
end

function PuckService:SetOwner(puck: BasePart, player: Player)
	if not CollectionService:HasTag(puck, "Puck") then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local front = character:FindFirstChild("Front", true)
	if not front or not front:IsA("BasePart") then
		return
	end

	puck.CFrame = front.CFrame * CFrame.Angles(0, 0, 0)
	puck:SetAttribute("Owner", player.UserId)
	puck:SetAttribute("Cooldown", time() + COOLDOWN)

	local weld = puck:FindFirstChild("weld")
	if not weld then
		return
	end
	weld.Part1 = front
end

function PuckService:RemoveOwner(puck: BasePart)
	if not CollectionService:HasTag(puck, "Puck") then
		return
	end

	local weld = puck:FindFirstChild("weld")
	if weld then
		weld.Part1 = nil
	end

	puck:SetAttribute("PreviousOwner", puck:GetAttribute("Owner"))

	puck.Orientation = Vector3.new(0, 0, 0)
	puck:SetNetworkOwner(nil)
	puck:SetAttribute("Owner", nil)
	puck:SetAttribute("Cooldown", time() + COOLDOWN)
end

function PuckService:SetPlayable(puck: BasePart, playable: boolean)
	if not puck then
		return
	end

	puck:SetAttribute("Playable", playable)
end

function PuckService:SetLastShotPosition(puck: BasePart, position: Vector3)
	if not puck then
		return
	end

	puck:SetAttribute("LastShotPosition", position)
end

function PuckService:GetCooldown(puck: BasePart): number?
	if not puck then
		return nil
	end

	return puck:GetAttribute("Cooldown") :: number?
end

function PuckService:GetOwner(puck: BasePart): number?
	if not puck then
		return nil
	end

	return puck:GetAttribute("Owner") :: number?
end

function PuckService:HasPuck(player: Player): BasePart?
	for _, puck in CollectionService:GetTagged("Puck") do
		if puck:GetAttribute("Owner") == player.UserId then
			return puck :: BasePart
		end
	end

	return nil
end

function PuckService:Destroy(puck: BasePart)
	if not puck then
		return
	end

	if puck:GetAttribute("Replicated") then
		local entity = Chrono.Holder.GetEntityFromModel(puck)
		if entity then
			Chrono.Entity.Destroy(entity)
		end
	end

	for i, v in PucksCache do
		if v == puck then
			table.remove(PucksCache, i)
		end
	end

	puck:Destroy()
end

function PuckService:DestroyAllPucks()
	for _, puck in CollectionService:GetTagged("Puck") do
		puck:Destroy()
	end
end

local inclusionTable: { Instance } = CollectionService:GetTagged("RemoveForce")

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Include
params.FilterDescendantsInstances = inclusionTable

CollectionService:GetInstanceAddedSignal("RemoveForce"):Connect(function(instance: Instance)
	table.insert(inclusionTable, instance)
	params.FilterDescendantsInstances = inclusionTable
end)

CollectionService:GetInstanceRemovedSignal("RemoveForce"):Connect(function(instance: Instance)
	for i = #inclusionTable, 1, -1 do
		if inclusionTable[i] == instance then
			table.remove(inclusionTable, i)
			break
		end
	end
	params.FilterDescendantsInstances = inclusionTable
end)

local function blockcast_collision(
	part: BasePart,
	size: Vector3,
	params: RaycastParams,
	dist: number,
	dt: number,
	visualize: boolean
): RaycastResult?
	local velocity = part.AssemblyLinearVelocity
	if velocity.Magnitude > 0 then
		local check_distance = velocity.Magnitude * dt * dist
		local direction = velocity.Unit

		if (direction * check_distance).Magnitude > 1020 then
			return nil
		end

		local result = Workspace:Blockcast(part.CFrame, size, direction * check_distance, params)

		return result
	end
	return nil
end

function PuckService:Start()
	-- Run raycasts
	RunService.PreSimulation:Connect(function(dt: number)
		for _, puck: BasePart in PucksCache do
			local result = blockcast_collision(puck, Vector3.new(1, 0.3, 1), params, 1.25, dt, false)
			if result then
				local upwardsForce = puck:FindFirstChild("VectorForce")
				if upwardsForce then
					upwardsForce:Destroy()
				end

				if CollectionService:HasTag(result.Instance, "Post") then
					PostsService:PlaySound(result.Instance)
				end
			end
		end
	end)
end

return PuckService
