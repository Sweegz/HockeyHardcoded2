local DataService: any = {}

local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DataStore = DataStoreService:GetDataStore("PlayerData1")
local DefaultStats = require(ServerScriptService.Server.Components.DefaultStats)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

local function DeepCopy(Table)
	local NewTable = {}
	for Key, Value in pairs(Table) do
		if type(Value) == "table" then
			NewTable[Key] = DeepCopy(Value)
		else
			NewTable[Key] = Value
		end
	end
	return NewTable
end

function DataService:SavePlayer(player: Player)
	local playerChannel = Synchronizer:Get(player)
	if not playerChannel then
		return
	end

	local data = playerChannel:Get()
	pcall(function()
		DataStore:SetAsync(player.UserId, data)
	end)
end

function DataService:Start()
	local function setupPlayer(player: Player)
		if Synchronizer:Get(player) then
			return
		end

		local success, savedData = pcall(function()
			return DataStore:GetAsync(player.UserId)
		end)

		if not success then
			return player:Kick("There was an error loading your data, please rejoin")
		end

		local playerData = savedData or DeepCopy(DefaultStats)
		playerData = TableUtil.Reconcile(playerData, DefaultStats)

		for name, data in pairs(DefaultStats) do
			if playerData[name] == nil then
				playerData[name] = data
			end
		end

		playerData.TimesJoined += 1

		local playerChannel = Synchronizer:Create(player, playerData)
		playerChannel:AddListener(player)

		return
	end

	Players.PlayerAdded:Connect(setupPlayer)

	Players.PlayerRemoving:Connect(function(player: Player)
		task.spawn(function()
			DataService:SavePlayer(player)
			Synchronizer:Destroy(player)
		end)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(setupPlayer, player)
	end
end

return DataService
