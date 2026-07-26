local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")

local ControllersFolder = StarterPlayer.StarterPlayerScripts:FindFirstChild("Controllers")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

for _, gui in ReplicatedStorage:WaitForChild("ReplicatedGui"):GetChildren() do
	gui.Parent = PlayerGui
end

local LoadedModules = {}
local modulesRequiredCount = 0
local modulesLoadedCount = 0

for _, module in ControllersFolder:GetChildren() do
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
