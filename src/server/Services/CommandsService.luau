local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerSessionService = require(script.Parent.PlayerSessionService)
local CommandsService = {}

local Net = ReplicatedStorage:WaitForChild("Net") :: Folder
local Bench = Net:WaitForChild("Bench") :: RemoteEvent

function CommandsService:Load()
	Bench.OnServerEvent:Connect(function(player: Player, targetPlayer: Player, benched: boolean)
		if not player or not targetPlayer then
			return
		end

		PlayerSessionService:SetBenched(targetPlayer, benched)
	end)
end

return CommandsService
