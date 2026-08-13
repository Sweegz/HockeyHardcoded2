local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Signal = require(ReplicatedStorage.Packages.Signal)
local HitRegisterService = require(script.Parent.HitRegisterService)
local PuckService = require(ServerScriptService.Services.PuckService2)
local PlayerSessionService = require(ServerScriptService.Services.PlayerSessionService)
local Shots = require(ServerScriptService.Shots)

local Net = ReplicatedStorage:WaitForChild("Net") :: Folder
local ShootEvent = Net:FindFirstChild("Shoot") :: RemoteEvent
local SlapshotEvent = Net:FindFirstChild("Slapshot") :: RemoteEvent
local ShoveEvent = Net:FindFirstChild("Shove") :: RemoteEvent
local RagdollEvent = Net:FindFirstChild("Ragdoll") :: RemoteEvent
local CheckEvent = Net:FindFirstChild("Check") :: RemoteEvent
local StateEvent = Net:FindFirstChild("State") :: RemoteEvent

local sound_folder = SoundService.SFX:FindFirstChild("Shots")
local SHOT_SOUND = sound_folder:FindFirstChild("Shot")
local SLAPSHOT_SOUND = sound_folder:FindFirstChild("Slapshot")

local planes = CollectionService:GetTagged("NetZone")
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Include
params.FilterDescendantsInstances = planes
params.IgnoreWater = true

CollectionService:GetInstanceAddedSignal("NetZone"):Connect(function(instance: Instance)
	table.insert(planes, instance)
	params.FilterDescendantsInstances = planes
end)

CollectionService:GetInstanceRemovedSignal("NetZone"):Connect(function(instance: Instance)
	for i = #planes, 1, -1 do
		if planes[i] == instance then
			table.remove(planes, i)
			break
		end
	end
	params.FilterDescendantsInstances = planes
end)

local PlayerActionService = {
	OnShotTowardsNet = Signal.new(),
}

local function preventShooterCollisions(player: Player, puck: BasePart)
	local constraints = {}

	local character = player.Character
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") and descendant.CanCollide then
			local constraint = Instance.new("NoCollisionConstraint")
			constraint.Parent = puck

			constraint.Part0 = puck
			constraint.Part1 = descendant

			table.insert(constraints, constraint)
		end
	end

	task.delay(0.5, function()
		for _, constraint in constraints do
			constraint:Destroy()
		end

		constraints = {}
	end)
end

local function blockcast_collision(
	part: BasePart,
	size: Vector3,
	params: RaycastParams,
	dir: Vector3,
	visualize: boolean
): RaycastResult?
	local result = Workspace:Blockcast(part.CFrame, size, dir, params)

	return result
end

function PlayerActionService:Start()
	ShootEvent.OnServerEvent:Connect(
		function(player: Player, uuid: string, power: number, mouseHit: Vector3, puckPosition: Vector3, flags)
			local puck = PuckService:GetPuckViaUUID(uuid)
			if not puck then
				return
			end

			local owner = PuckService:GetOwner(puck)
			if owner ~= player.UserId then
				return
			end

			power = math.clamp(power, 0, 100)
			local dir = (mouseHit - puckPosition).Unit
			dir = Vector3.new(dir.X, 0, dir.Z)

			local velocity, force, time = Shots.calculate_vel_and_force(power, dir, flags)

			if flags.chip then
				print("Chip")
			end

			if flags.fake then
				return
			end

			local Sound = nil

			if power >= 50 then
				Sound = SLAPSHOT_SOUND:Clone()
			else
				Sound = SHOT_SOUND:Clone()
			end

			if Sound then
				Sound.Parent = puck
				Sound:Play()
				Sound.Parent = puck
				Sound.Ended:Once(function()
					Sound:Destroy()
				end)
			end

			preventShooterCollisions(player, puck)

			PuckService:RemoveOwner(puck)
			PuckService:SetLastShotPosition(puck, puckPosition)
			puck.Position = puckPosition
			Shots.apply_velocity(puck, velocity)
			Shots.apply_force(puck, force, time)
			PlayerSessionService:SetCollectCooldown(player, 1.5)

			local result = blockcast_collision(puck, Vector3.new(1, 0.3, 1), params, velocity, false)
			if result then
				local instance = result.Instance
				if not instance then
					return
				end

				local parent = instance.Parent
				if not parent then
					return
				end

				local net = parent.Parent
				if not net then
					return
				end

				local goalie = net:FindFirstChild("Goalie")
				if not goalie then
					return
				end

				PlayerActionService.OnShotTowardsNet:Fire({
					origin = puck.Position,
					direction = dir,
					rayResult = result,
					goalie = goalie,
					flags = flags,
				})
			end
		end
	)

	SlapshotEvent.OnServerEvent:Connect(
		function(player: Player, uuid: string, power: number, mouseHit: Vector3, puckPosition: Vector3, flags)
			local puck = PuckService:GetPuckViaUUID(uuid)
			if not puck then
				return
			end
			local owner = PuckService:GetOwner(puck)
			if owner and owner ~= player.UserId then
				return
			end

			power = math.clamp(power, 0, 100)

			local dir = (mouseHit - puckPosition).Unit
			dir = Vector3.new(dir.X, 0, dir.Z)

			power = math.max(power, 50)

			local velocity, force, time = Shots.calculate_vel_and_force(power, dir, flags)

			local Sound = nil

			Sound = SLAPSHOT_SOUND:Clone()

			if Sound then
				Sound.Parent = puck
				Sound:Play()
				Sound.Parent = puck
				Sound.Ended:Once(function()
					Sound:Destroy()
				end)
			end

			preventShooterCollisions(player, puck)

			PuckService:RemoveOwner(puck)
			PuckService:SetLastShotPosition(puck, puckPosition)
			puck.Position = puckPosition
			Shots.apply_velocity(puck, velocity)
			Shots.apply_force(puck, force, time)
			PlayerSessionService:SetCollectCooldown(player, 1.5)
		end
	)

	ShoveEvent.OnServerEvent:Connect(
		function(player: Player, hitPlayer: Player, hitPart: BasePart, lookDirection: Vector3)
			if player.Team == hitPlayer.Team then
				return
			end

			if time() < PlayerSessionService:GetCheckCooldown(player) then
				return
			end

			local finalVelocity = lookDirection * 30
			local duration = 0.2
			local power = 20

			RagdollEvent:FireClient(hitPlayer, finalVelocity, duration, true, power)

			local possessedPuck = PuckService:HasPuck(hitPlayer)

			if possessedPuck then
				PuckService:RemoveOwner(possessedPuck)
			end

			PlayerSessionService:SetCollectCooldown(hitPlayer, 1.5)
			PlayerSessionService:SetCheckCooldown(player, 0.5)

			HitRegisterService:Register(player, hitPlayer, hitPart, power, duration, true)
		end
	)

	CheckEvent.OnServerEvent:Connect(
		function(player: Player, hitPlayer: Player, hitPart: BasePart, movementDirection: Vector3, power: number)
			power = math.clamp(power, 0, 100)

			if player.Team == hitPlayer.Team then
				return
			end

			if time() < PlayerSessionService:GetCheckCooldown(player) then
				return
			end

			local finalVelocity = movementDirection * (power / 2)

			local duration = 0.5 + (power / 200)

			RagdollEvent:FireClient(hitPlayer, finalVelocity, duration, false, power)

			local possessedPuck = PuckService:HasPuck(hitPlayer)

			if possessedPuck then
				PuckService:RemoveOwner(possessedPuck)
			end

			PlayerSessionService:SetCollectCooldown(hitPlayer, 1.5)
			PlayerSessionService:SetCheckCooldown(player, 0.5)
			PlayerSessionService:SetCheckCooldown(hitPlayer, 0.5)

			HitRegisterService:Register(player, hitPlayer, hitPart, power, duration, false)
		end
	)

	StateEvent.OnServerEvent:Connect(function(player: Player, stateName: string)
		local previousState = player:GetAttribute("CurrentState")
		player:SetAttribute("CurrentState", stateName)
		player:SetAttribute("PreviousState", previousState)
	end)
end

return PlayerActionService
