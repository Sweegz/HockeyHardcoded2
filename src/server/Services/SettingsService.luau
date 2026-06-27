local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Net = ReplicatedStorage.Net
local ToggleSetting = Net:FindFirstChild("ToggleSetting")

local SettingsService = {}

ToggleSetting.OnServerInvoke = function(player: Player, setting: string, new: any)
	local playerChannel = Synchronizer:Get(player)
	if not playerChannel then
		return false, "There was an error getting your data, please rejoin"
	end

	setting = string.format("Settings.%s", setting)

	if new == nil then
		local data = playerChannel:Get(setting)
		new = not data
	end

	playerChannel:Set(setting, new)
	print(new)
	return true
end

return SettingsService
