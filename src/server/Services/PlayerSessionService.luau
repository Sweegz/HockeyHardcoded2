local Players = game:GetService("Players")
local PlayerSessionService = {}

local function setupPlayer(player: Player)
	player:SetAttribute("Stamina", 100)
	player:SetAttribute("Benched", false)
	player:SetAttribute("CollectCooldown", 0)
	player:SetAttribute("CheckCooldown", 0)
end

function PlayerSessionService:Load()
	Players.PlayerAdded:Connect(setupPlayer)

	--Players.PlayerRemoving:Connect(function(_player: Player) end)

	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(setupPlayer, player)
	end
end

function PlayerSessionService:SetStamina(player: Player, value: number)
	if not player then
		return
	end

	player:SetAttribute("Stamina", value)
end

function PlayerSessionService:GetStamina(player: Player): number?
	if not player then
		return nil
	end

	return player:GetAttribute("Stamina") :: number
end

function PlayerSessionService:SetBenched(player: Player, benched: boolean)
	if not player then
		return
	end

	player:SetAttribute("Benched", benched)
end

function PlayerSessionService:GetBenched(player: Player): boolean?
	if not player then
		return nil
	end

	return player:GetAttribute("Benched") :: boolean
end

function PlayerSessionService:SetCollectCooldown(player: Player, duration: number)
	if not player then
		return
	end

	player:SetAttribute("CollectCooldown", time() + duration)
end

function PlayerSessionService:SetCheckCooldown(player: Player, duration: number)
	if not player then
		return
	end

	player:SetAttribute("CheckCooldown", time() + duration)
end

function PlayerSessionService:GetCollectCooldown(player: Player): number?
	if not player then
		return nil
	end

	return player:GetAttribute("CollectCooldown") :: number or 0
end

function PlayerSessionService:GetCheckCooldown(player: Player): number?
	if not player then
		return nil
	end

	return player:GetAttribute("CheckCooldown") :: number or 0
end

function PlayerSessionService:Reset(player: Player)
	if not player then
		return
	end

	player:SetAttribute("CollectCooldown", nil)
	player:SetAttribute("CheckCooldown", nil)
	player:SetAttribute("Stamina", 100)
end

return PlayerSessionService
