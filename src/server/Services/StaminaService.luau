local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PlayerSessionService = require(script.Parent.PlayerSessionService)

local Net = ReplicatedStorage:WaitForChild("Net") :: Folder
local StaminaRemote = Net:WaitForChild("Stamina") :: RemoteEvent

local DRAIN_RATE = 20
local REGEN_RATE = 10
local MAX_STAMINA = 100

local StaminaService = {}

local PlayerStaminaMap = {}

function StaminaService:Load()
	Players.PlayerAdded:Connect(function(player: Player)
		PlayerStaminaMap[player] = {
			stamina = 100,
			stamming = false,
		}
	end)

	StaminaRemote.OnServerEvent:Connect(function(player: Player, stamming: boolean)
		if not player then
			return
		end

		PlayerStaminaMap[player].stamming = stamming
	end)
end

function StaminaService:Start()
	local interval = 0.5

	local accumulatedTime = 0

	RunService.Heartbeat:Connect(function(dt)
		accumulatedTime += dt
		for player: Player, data in PlayerStaminaMap do
			local stamming = data.stamming
			local stamina = data.stamina

			if stamming then
				local newStamina = stamina - DRAIN_RATE * dt
				if newStamina < 0 then
					newStamina = 0
				end
				PlayerStaminaMap[player].stamina = newStamina
			else
				local newStamina = stamina + REGEN_RATE * dt
				if newStamina > 100 then
					newStamina = 100
				end
				PlayerStaminaMap[player].stamina = newStamina
			end
		end

		if accumulatedTime > interval then
			for player: Player, data in PlayerStaminaMap do
				player:SetAttribute("Stamina", data.stamina)
			end

			accumulatedTime = 0
		end
	end)
end

return StaminaService
