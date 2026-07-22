local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Chrono = require(ReplicatedStorage.Packages.Chrono)
local PuckReplicator = {}

function PuckReplicator:Start()
	print("Hej")
	RunService.Heartbeat:Connect(function(dt)
		local puck = game.Workspace.Pucks:FindFirstChild("Puck")
		if not puck then
			return
		end

		local entity = Chrono.Holder.GetEntityFromModel(puck)
		if not entity then
			return
		end

		--print(entity)

		--print("aaa")
	end)
end

return PuckReplicator
