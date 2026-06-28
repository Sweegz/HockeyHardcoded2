local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local PlayerSessionService = require(script.Parent.PlayerSessionService)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

local PuckModel = ReplicatedStorage:FindFirstChild("Models"):FindFirstChild("Pucks"):FindFirstChild("Puck")
local Net = ReplicatedStorage.Net

local CollectEvent = Net:FindFirstChild("Collect") :: RemoteFunction
local DropEvent = Net:FindFirstChild("Drop") :: RemoteEvent

local Channel = nil

local PuckService = {}

local function SetPuckOwner(player: Player)
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
	Channel:Set("Cooldown", tick() + 1)
end

local function DropPuck()
	local puck = Channel:Get("Instance")
	if not puck then
		return
	end

	local owner = Channel:Get("Owner")

	puck.weld.Part1 = nil
	Channel:Set("Owner", nil)
	Channel:Set("Cooldown", tick() + 1)

	if owner then
		PlayerSessionService:SetCooldown(owner, 2)
	end
end

function PuckService:Load()
	Channel = Synchronizer:Create("Puck", {
		Owner = nil,
		Cooldown = 0,
		Enabled = false,
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

function PuckService:Start()
	CollectEvent.OnServerInvoke = function(player)
		local Owner = Channel:Get("Owner")
		local Cooldown = Channel:Get("Cooldown")

		if tick() < Cooldown then
			return
		end

		if tick() < PlayerSessionService:GetCooldown(player) then
			return
		end

		if not Owner then
			SetPuckOwner(player)
		elseif Owner ~= player then
			DropPuck()
		end
	end

	DropEvent.OnServerEvent:Connect(function(player: Player)
		if Channel:Get("Owner") == player then
			DropPuck()
		end
	end)
end

function PuckService:Enable()
	Channel:Set("Enabled", true)
end

function PuckService:Disable()
	Channel:Set("Enabled", false)
end

function PuckService:GetPuckInstance()
	return Channel:Get("Instance")
end

function PuckService:Spawn(position: Vector3)
	PuckService:Destroy()

	local clone = PuckModel:Clone()
	clone.Parent = Workspace:FindFirstChild("Pucks")
	clone.Position = position
	Channel:Set("Instance", clone):Set("Owner", nil):Set("Cooldown", 0)
end

function PuckService:Destroy()
	local current_puck = PuckService:GetPuckInstance()
	if current_puck then
		current_puck:Destroy()
	end

	Channel:Set("Instance", nil):Set("Owner", nil):Set("Cooldown", 0)
end

return PuckService
