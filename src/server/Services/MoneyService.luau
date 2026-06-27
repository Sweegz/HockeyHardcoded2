--!strict

local MoneyService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

function MoneyService:CanAfford(player: Player, amount: number): (boolean, number)
	assert(player, "Could not get Player")
	assert(amount, "Could not get amount")

	local playerChannel = Synchronizer:Get(player)
	assert(playerChannel, "Could not get PlayerChannel")

	local currentCoins = playerChannel:Get("Coins")
	assert(currentCoins, "Could not get Coins")

	if currentCoins >= amount then
		return true, 0
	else
		return false, amount - currentCoins
	end
end

function MoneyService:Add(player: Player, amount: number)
	assert(player, "Could not get Player")
	assert(amount, "Could not get amount")

	local playerChannel = Synchronizer:Get(player)
	assert(playerChannel, "Could not get PlayerChannel")

	playerChannel:Increase("Coins", amount)
end

function MoneyService:Set(player: Player, amount: number)
	assert(player, "Could not get Player")
	assert(amount, "Could not get amount")

	local playerChannel = Synchronizer:Get(player)
	assert(playerChannel, "Could not get PlayerChannel")

	playerChannel:Set("Coins", amount)
end

return MoneyService
