local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PuckService = require(ServerScriptService.Services.PuckService)
local PlayerSessionService = require(script.Parent.PlayerSessionService)

local Net = ReplicatedStorage.Net
local CollectEvent = Net:FindFirstChild("Collect") :: RemoteFunction
local DropEvent = Net:FindFirstChild("Drop") :: RemoteEvent

local CollectService = {}

function CollectService:Start()
	CollectEvent.OnServerInvoke = function(player)
		local owner = PuckService:GetOwner()
		local cooldown = PuckService:GetCooldown()

		if tick() < cooldown then
			return
		end

		if tick() < PlayerSessionService:GetCooldown(player) then
			return
		end

		if not owner then
			PuckService:SetOwner(player)
		elseif owner ~= player then
			PuckService:DropPuck()
		end
	end

	DropEvent.OnServerEvent:Connect(function(player: Player)
		local owner = PuckService:GetOwner()
		if owner == player then
			PuckService:DropPuck()
		end
	end)
end

return CollectService
