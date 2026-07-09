local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PuckService = require(ServerScriptService.Services.PuckService)
local PlayerSessionService = require(ServerScriptService.Services.PlayerSessionService)
local Shots = require(ServerScriptService.Shots)

local Net = ReplicatedStorage.Net
local ShootEvent = Net:FindFirstChild("Shoot") :: RemoteEvent
local ShoveEvent = Net:FindFirstChild("Shove") :: RemoteEvent
local RagdollEvent = Net:FindFirstChild("Ragdoll") :: RemoteEvent

local PlayerActionService = {}

function PlayerActionService:Start()
	ShootEvent.OnServerEvent:Connect(
		function(player: Player, power: number, mouseHit: Vector3, puckPosition: Vector3, flags)
			local owner = PuckService:GetOwner()
			if owner ~= player then
				return
			end

			local puck = PuckService:GetPuckInstance()
			if not puck then
				return
			end

			local dir = (mouseHit - puckPosition).Unit
			dir = Vector3.new(dir.X, 0, dir.Z)

			local velocity, force, time = Shots.calculate_vel_and_force(power, dir, flags)

			if flags.chip then
				print("Chip")
			end

			if flags.fake then
				return
			end

			PuckService:DropPuck()
			Shots.apply_velocity(puck, velocity)
			Shots.apply_force(puck, force, time)
			PlayerSessionService:SetCooldown(player, 2)
		end
	)

	ShoveEvent.OnServerEvent:Connect(function(player: Player, hit: BasePart, velocity: Vector3, direction: Vector3)
		local parent = hit.Parent
		if not parent then
			return
		end

		local hitPlayer = Players:GetPlayerFromCharacter(parent)
		if not hitPlayer then
			return
		end

		local velocityMagnitude = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
		direction = Vector3.new(direction.X, 0, direction.Z)

		local final_velocity = direction * math.max(30, velocityMagnitude)

		RagdollEvent:FireClient(hitPlayer, 20, final_velocity, 0.2, true)

		if PuckService:GetOwner() == hitPlayer then
			PuckService:DropPuck()
		end

		PlayerSessionService:SetCooldown(hitPlayer, 2)
	end)
end

return PlayerActionService
