local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

local PlayerSessionController = {}

local playerSessionChannel

function PlayerSessionController:Load()
	Synchronizer:WaitAndCall("PlayerSession", function(channel)
		playerSessionChannel = channel
	end)
end

function PlayerSessionController:GetPlayerSession(player: Player)
	local index = ("Players.%*"):format(player.UserId)
	return playerSessionChannel:Get(index)
end

function PlayerSessionController:GetCollectCooldown(player: Player)
	local index = ("Players.%*.CollectCooldown"):format(player.UserId)
	return playerSessionChannel:Get(index)
end

return PlayerSessionController
