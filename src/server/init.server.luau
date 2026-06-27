local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

Players.PlayerAdded:Connect(function(player: Player)
	local playerChannel = Synchronizer:Wait(player.UserId)

	if not playerChannel then
		player:Kick("Error while loading data.")
		return
	end
end)

local ServicesFolder = script:FindFirstChild("Services")
if not ServicesFolder then
	ServicesFolder = ReplicatedStorage:WaitForChild("Controllers")
end

local LoadedModules = {}
local modulesRequiredCount = 0
local modulesLoadedCount = 0

for _, module in ServicesFolder:GetChildren() do
	if module:IsA("ModuleScript") then
		LoadedModules[module.Name] = require(module)
		modulesRequiredCount += 1
	end
end

for _, module in LoadedModules do
	if module.Load then
		module.Load()
		modulesLoadedCount += 1
	end
end

for _, module in LoadedModules do
	if module.Start then
		module.Start()
	end
end
