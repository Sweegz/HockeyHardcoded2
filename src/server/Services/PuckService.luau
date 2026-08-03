local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Chrono = require(ReplicatedStorage.ModdedPackages.Chrono)
local Synchronizer = require(ReplicatedStorage.ModdedPackages.Synchronizer)

local PuckModel = ReplicatedStorage:FindFirstChild("Assets"):FindFirstChild("Pucks"):FindFirstChild("Puck")

local COOLDOWN = 0.5

local Channel = nil

local PuckService = {
	lastShotPosition = Vector3.zero,
}

function PuckService:Load()
	Channel = Synchronizer:Create("Puck", {
		Owner = nil,
		Cooldown = 0,
		Instance = nil,
	})

	for _, player in ipairs(Players:GetPlayers()) do
		Channel:AddListener(player)
	end

	Players.PlayerAdded:Connect(function(player: Player)
		Channel:AddListener(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		Channel:RemoveListener(player)
	end)
end

function PuckService:Start() end

function PuckService:SetOwner(player: Player)
	local character = player.Character
	if not character then
		return
	end

	local front = character:FindFirstChild("Front", true)
	if not front then
		return
	end

	local puck = Channel:Get("Instance")
	if not puck then
		return
	end

	puck.CFrame = front.CFrame * CFrame.Angles(0, 0, 0)
	puck.weld.Part1 = front
	Channel:Set("Owner", player)
	Channel:Set("Cooldown", time() + COOLDOWN)
end

function PuckService:DropPuck()
	local puck = Channel:Get("Instance")
	if not puck then
		return
	end

	puck.weld.Part1 = nil
	puck.Orientation = Vector3.new(0, 0, 0)
	puck:SetNetworkOwner(nil)
	Channel:Set("Owner", nil)
	Channel:Set("Cooldown", time() + COOLDOWN)
end

function PuckService:GetOwner()
	return Channel:Get("Owner")
end

function PuckService:GetCooldown()
	return Channel:Get("Cooldown")
end

function PuckService:GetPuckInstance()
	return Channel:Get("Instance")
end

local conn

function PuckService:Spawn(position: Vector3)
	PuckService:Destroy()
	PuckService.lastShotPosition = Vector3.zero

	local clone = PuckModel:Clone()
	clone.Parent = Workspace:FindFirstChild("Pucks")
	clone.Position = position
	clone:SetNetworkOwner(nil)

	conn = clone.AncestryChanged:Once(function()
		if clone.Parent == nil then
			PuckService:Destroy()
		end
	end)

	if Workspace:GetAttribute("CustomReplication") then
		local ent = Chrono.Entity.new("Default", clone)
	end

	Channel:Set("Instance", clone):Set("Owner", nil):Set("Cooldown", 0)

	return clone
end

function PuckService:Destroy()
	print("Destroyed!")
	local current_puck = PuckService:GetPuckInstance()

	if conn then
		conn:Disconnect()
	end

	if current_puck then
		current_puck:Destroy()

		local ent = Chrono.Holder.GetEntityFromModel(current_puck)
		if ent then
			Chrono.Entity.Destroy(ent)
		end
	end

	Channel:Set("Instance", nil):Set("Owner", nil):Set("Cooldown", 0)
end

return PuckService
