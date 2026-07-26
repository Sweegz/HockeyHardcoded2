local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Chrono = require(ReplicatedStorage.ModdedPackages.Chrono)

local ChronoClient = {}

function ChronoClient:Load()
	if not Workspace:GetAttribute("CustomReplication") then
		return
	end

	Chrono.Start()
end

script:Destroy()

return ChronoClient
