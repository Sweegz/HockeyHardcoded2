local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Chrono = require(ReplicatedStorage.Packages.Chrono)

local ChronoServer = {}

function ChronoServer:Load()
	if not Workspace:GetAttribute("CustomReplication") then
		return
	end

	Chrono.Start()
end

return ChronoServer
