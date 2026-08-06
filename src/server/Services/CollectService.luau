local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PuckService = require(ServerScriptService.Services.PuckService2)
local PlayerSessionService = require(script.Parent.PlayerSessionService)

local Net = ReplicatedStorage.Net
local CollectEvent = Net:FindFirstChild("Collect") :: RemoteFunction
local DropEvent = Net:FindFirstChild("Drop") :: RemoteEvent

local CollectService = {}

local PLAYER_COOLDOWN = 1.5

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

local function AddPuckVelocity(puck: BasePart, player1: Player, player2: Player)
	if not puck then
		return
	end

	local player1Character = player1.Character
	local player2Character = player2.Character

	if not player1Character or not player2Character then
		return
	end

	local player1humanoidRootPart = player1Character:FindFirstChild("HumanoidRootPart")
	local player2humanoidRootPart = player2Character:FindFirstChild("HumanoidRootPart")

	if
		not player1humanoidRootPart
		or not player2humanoidRootPart
		or not player1humanoidRootPart:IsA("BasePart")
		or not player2humanoidRootPart:IsA("BasePart")
	then
		return
	end

	--[[local velocity = (
		player1humanoidRootPart.AssemblyLinearVelocity - player2humanoidRootPart.AssemblyLinearVelocity / 5
	) --]]

	--[[local dir = (puck.Position - player1humanoidRootPart.Position).Unit
	local speed = player1humanoidRootPart.AssemblyLinearVelocity.Magnitude

	local velocity = dir * speed --]]

	preventShooterCollisions(player2, puck)
	preventShooterCollisions(player1, puck)

	if puck.AssemblyLinearVelocity.Magnitude < 10 then
		puck.AssemblyLinearVelocity = player1humanoidRootPart.AssemblyLinearVelocity.Unit * 25
	else
		puck.AssemblyLinearVelocity = puck.AssemblyLinearVelocity / 1.5
	end

	--puck.AssemblyLinearVelocity = velocity
end

function CollectService:Start()
	CollectEvent.OnServerInvoke = function(player: Player, uuid: string, pickup: boolean)
		local puck = PuckService:GetPuckViaUUID(uuid)

		if not puck then
			return
		end

		if not PuckService:IsPlayable(puck) then
			return
		end

		local ownerId = PuckService:GetOwner(puck)
		local owner = nil
		if ownerId then
			owner = Players:GetPlayerByUserId(ownerId)
		end

		if owner and owner.Team == player.Team then
			return
		end

		local cooldown = PuckService:GetCooldown(puck)

		if cooldown and time() < cooldown then
			return
		end

		if time() < PlayerSessionService:GetCollectCooldown(player) then
			return
		end

		if puck:FindFirstChildOfClass("VectorForce") then
			return
		end

		if not owner and pickup then
			puck.AssemblyLinearVelocity = Vector3.zero
			puck.AssemblyAngularVelocity = Vector3.zero
			PuckService:SetOwner(puck, player)
		elseif owner and owner ~= player then
			PuckService:RemoveOwner(puck)
			PlayerSessionService:SetCollectCooldown(owner, PLAYER_COOLDOWN)
			AddPuckVelocity(puck, player, owner)
		end
	end

	DropEvent.OnServerEvent:Connect(function(player: Player, uuid: string, position: CFrame)
		local puck = PuckService:GetPuckViaUUID(uuid)
		if not puck then
			return
		end

		if not PuckService:IsPlayable(puck) then
			return
		end

		local owner = PuckService:GetOwner(puck)

		if owner == player.UserId then
			PuckService:RemoveOwner(puck)

			PlayerSessionService:SetCollectCooldown(player, PLAYER_COOLDOWN)

			-- ANTI CHEAT to make sure the drop disrespancy isn't too far
			local distBetweenClientandServer = (puck.Position - position.Position).Magnitude
			if distBetweenClientandServer < 20 then
				puck.CFrame = position
			end

			puck.AssemblyLinearVelocity = Vector3.zero
			puck.AssemblyAngularVelocity = Vector3.zero

			preventShooterCollisions(player, puck)
		end
	end)
end

return CollectService
