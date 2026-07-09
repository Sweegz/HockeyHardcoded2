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
	local player1Character = player1.Character
	local player2Character = player2.Character

	if not player1Character or not player2Character then
		return
	end

	local player1humanoidRootPart = player1Character:FindFirstChild("HumanoidRootPart")
	local player2humanoidRootPart = player2Character:FindFirstChild("HumanoidRootPart")

	if not player1humanoidRootPart or not player2humanoidRootPart then
		return
	end

	local velocity = (
		player1humanoidRootPart.AssemblyLinearVelocity - player2humanoidRootPart.AssemblyLinearVelocity / 2
	)

	if puck then
		puck.AssemblyLinearVelocity = velocity
	end
end

function CollectService:Start()
	CollectEvent.OnServerInvoke = function(player: Player, pickup: boolean)
		local owner = PuckService:GetOwner()

		if time() < PuckService:GetCooldown() then
			return
		end

		if time() < PlayerSessionService:GetCooldown(player) then
			return
		end

		if not owner and pickup then
			PuckService:SetOwner(player)
		elseif owner and owner ~= player then
			PuckService:DropPuck()
			PlayerSessionService:SetCooldown(owner, PLAYER_COOLDOWN)
			AddPuckVelocity(PuckService:GetPuckInstance(), player, owner)
		end
	end

	DropEvent.OnServerEvent:Connect(function(player: Player)
		local owner = PuckService:GetOwner()

		if owner == player then
			PuckService:DropPuck()
			PlayerSessionService:SetCooldown(owner, PLAYER_COOLDOWN)
			AddPuckVelocity(PuckService:GetPuckInstance(), player, owner)
		end
	end)
end

return CollectService
