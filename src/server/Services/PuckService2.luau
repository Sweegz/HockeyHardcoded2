local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Chrono = require(ReplicatedStorage.ModdedPackages.Chrono)

local PuckModel = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Pucks"):WaitForChild("Puck")
local PuckFolder = Workspace:WaitForChild("Pucks")

local COOLDOWN = 0.5

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
		Chrono.Entity.new("Default", clone)
		CollectionService:AddTag(clone, "Replicated")
	else
		CollectionService:AddTag(clone, "Collectable")
	end

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

	puck:Destroy()
end

function PuckService:DestroyAllPucks()
	for _, puck in CollectionService:GetTagged("Puck") do
		puck:Destroy()
	end
end

return PuckService
