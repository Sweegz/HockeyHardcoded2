local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

local PuckModel = ReplicatedStorage:FindFirstChild("Models"):FindFirstChild("Pucks"):FindFirstChild("Puck")

local Channel = nil

local PuckService = {}

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

function PuckService:Start() end

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
