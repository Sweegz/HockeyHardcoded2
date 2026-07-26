local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PuckService = require(ServerScriptService.Services.PuckService)
local PlayerSessionService = require(script.Parent.PlayerSessionService)

local Net = ReplicatedStorage.Net
local CollectEvent = Net:FindFirstChild("Collect") :: RemoteFunction
local DropEvent = Net:FindFirstChild("Drop") :: RemoteEvent

local CollectService = {}

local PLAYER_COOLDOWN = 1.5

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

	if puck.AssemblyLinearVelocity.Magnitude < 10 then
		puck.AssemblyLinearVelocity = puck.AssemblyLinearVelocity / 3
	else
		puck.AssemblyLinearVelocity = player1humanoidRootPart.AssemblyLinearVelocity / 3
	end

	--puck.AssemblyLinearVelocity = velocity
end

function CollectService:Start()
	CollectEvent.OnServerInvoke = function(player: Player, pickup: boolean)
		local owner = PuckService:GetOwner()

		if time() < PuckService:GetCooldown() then
			return
		end

		if time() < PlayerSessionService:GetCollectCooldown(player) then
			return
		end

		local puck = PuckService:GetPuckInstance()
		if not puck then
			return
		end

		if puck:FindFirstChildOfClass("VectorForce") then
			return
		end

		if not owner and pickup then
			PuckService:SetOwner(player)
		elseif owner and owner ~= player then
			PuckService:DropPuck()
			PlayerSessionService:SetCollectCooldown(owner, PLAYER_COOLDOWN)
			AddPuckVelocity(PuckService:GetPuckInstance(), player, owner)
		end
	end

	DropEvent.OnServerEvent:Connect(function(player: Player)
		local owner = PuckService:GetOwner()

		if owner == player then
			PuckService:DropPuck()
			PlayerSessionService:SetCollectCooldown(owner, PLAYER_COOLDOWN)
			AddPuckVelocity(PuckService:GetPuckInstance(), player, owner)
		end
	end)
end

return CollectService
