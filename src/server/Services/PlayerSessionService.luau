local PlayerSessionService: any = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local DeepCopy = require(ReplicatedStorage.Shared.Utility.DeepCopy)

local playerSessionChannel

local SESSION_DATA_TEMPLATE = {
	Stamina = 100,
	Benched = false,
	CollectCooldown = 0,
	CheckCooldown = 0,
	Stats = {},
}

local function setupPlayer(player: Player)
	if PlayerSessionService:GetPlayerSession(player) then
		return
	end

	local sessionData = DeepCopy(SESSION_DATA_TEMPLATE)

	playerSessionChannel:InsertOnDictionary("Players", tostring(player.UserId), sessionData)

	playerSessionChannel:AddListener(player)

	return
end

function PlayerSessionService:Load()
	playerSessionChannel = Synchronizer:Create("PlayerSession", {
		Players = {},
	})

	Players.PlayerAdded:Connect(setupPlayer)

	--Players.PlayerRemoving:Connect(function(_player: Player) end)

	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(setupPlayer, player)
	end
end

function PlayerSessionService:GetPlayerSession(player: Player)
	local path = ("Players.%*"):format(player.UserId)
	return playerSessionChannel:Get(path)
end

function PlayerSessionService:SetCollectCooldown(player: Player, duration: number)
	local path = ("Players.%*.CollectCooldown"):format(player.UserId)
	return playerSessionChannel:Set(path, time() + duration)
end

function PlayerSessionService:GetCollectCooldown(player: Player)
	local path = ("Players.%*.CollectCooldown"):format(player.UserId)
	return playerSessionChannel:Get(path)
end

function PlayerSessionService:SetCheckCooldown(player: Player, duration: number)
	local path = ("Players.%*.CheckCooldown"):format(player.UserId)
	return playerSessionChannel:Set(path, time() + duration)
end

function PlayerSessionService:GetCheckCooldown(player: Player)
	local path = ("Players.%*.CheckCooldown"):format(player.UserId)
	return playerSessionChannel:Get(path)
end

function PlayerSessionService:Reset()
	playerSessionChannel:Set("Players", {})
	for _, player in Players:GetPlayers() do
		setupPlayer(player)
	end
end

return PlayerSessionService
