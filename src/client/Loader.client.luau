local StarterPlayer = game:GetService("StarterPlayer")

local ControllersFolder = StarterPlayer.StarterPlayerScripts:FindFirstChild("Controllers")

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
