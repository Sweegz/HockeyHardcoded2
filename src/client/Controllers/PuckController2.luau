local CollectionService = game:GetService("CollectionService")

local PuckController = {}

function PuckController:GetMainPuck(): BasePart?
	for _, p in CollectionService:GetTagged("MainPuck") do
		return p :: BasePart
	end

	return nil
end

function PuckController:GetPuckViaUUID(uuid: string): BasePart?
	for _, puck in CollectionService:GetTagged("Puck") do
		if puck:GetAttribute("UUID") == uuid then
			return puck :: BasePart
		end
	end

	return nil
end

function PuckController:GetCooldown(puck: BasePart): number?
	if not puck then
		return nil
	end

	return puck:GetAttribute("Cooldown") :: number?
end

function PuckController:GetOwner(puck: BasePart): number?
	if not puck then
		return nil
	end

	return puck:GetAttribute("Owner") :: number?
end

function PuckController:HasPuck(player: Player): BasePart?
	for _, puck in CollectionService:GetTagged("Puck") do
		if puck:GetAttribute("Owner") == player.UserId then
			return puck :: BasePart
		end
	end

	return nil
end

return PuckController
