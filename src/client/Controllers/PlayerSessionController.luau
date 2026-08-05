local PlayerSessionController = {}

function PlayerSessionController:GetStamina(player: Player): number?
	if not player then
		return nil
	end

	return player:GetAttribute("Stamina") :: number
end

function PlayerSessionController:GetBenched(player: Player): boolean?
	if not player then
		return nil
	end

	return player:GetAttribute("Benched") :: boolean
end

function PlayerSessionController:GetCollectCooldown(player: Player): number?
	if not player then
		return nil
	end

	return player:GetAttribute("CollectCooldown") :: number or 0
end

function PlayerSessionController:GetCheckCooldown(player: Player): number?
	if not player then
		return nil
	end

	return player:GetAttribute("CheckCooldown") :: number or 0
end

return PlayerSessionController
