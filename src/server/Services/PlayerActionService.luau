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
local CheckEvent = Net:FindFirstChild("Check") :: RemoteEvent

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
			PlayerSessionService:SetCollectCooldown(player, 2)
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

		if time() < PlayerSessionService:GetCheckCooldown(player) then
			return
		end

		local velocityMagnitude = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
		direction = Vector3.new(direction.X, 0, direction.Z)

		--local final_velocity = direction * math.max(30, velocityMagnitude)
		local final_velocity = direction * 20

		RagdollEvent:FireClient(hitPlayer, final_velocity, 0.2, true)

		if PuckService:GetOwner() == hitPlayer then
			PuckService:DropPuck()
		end

		PlayerSessionService:SetCollectCooldown(hitPlayer, 2)
		PlayerSessionService:SetCheckCooldown(player, 0.5)

		print("SHOVE")
	end)

	CheckEvent.OnServerEvent:Connect(
		function(player: Player, hitPlayer: Player, hitPart: BasePart, movementDirection: Vector3, power: number)
			local output = ("%* hit %*'s %* with %* power"):format(player.Name, hitPlayer.Name, hitPart.Name, power)
			print(output)

			if time() < PlayerSessionService:GetCheckCooldown(player) then
				return
			end

			local finalVelocity = movementDirection * (power / 2) * 0.75

			RagdollEvent:FireClient(hitPlayer, finalVelocity, 1, false)

			if PuckService:GetOwner() == hitPlayer then
				PuckService:DropPuck()
			end

			PlayerSessionService:SetCollectCooldown(hitPlayer, 2)
			PlayerSessionService:SetCheckCooldown(player, 0.5)

			print("CHECK")
		end
	)
end

return PlayerActionService
