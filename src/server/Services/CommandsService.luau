local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerSessionService = require(script.Parent.PlayerSessionService)
local TeamsService = require(script.Parent.TeamsService)
local CommandsService = {}

local Net = ReplicatedStorage:WaitForChild("Net") :: Folder
local Bench = Net:WaitForChild("Bench") :: RemoteEvent

function CommandsService:Load()
	Bench.OnServerEvent:Connect(function(player: Player, targetPlayer: Player, benched: boolean)
		if not player or not targetPlayer then
			return
		end

		PlayerSessionService:SetBenched(targetPlayer, benched)

		if benched == true then
			local character = targetPlayer.Character
			if character then
				local spawnLocation = TeamsService:GetSpawn(targetPlayer.Team)
				if spawnLocation then
					local pos = CFrame.new(spawnLocation.Position + Vector3.new(0, 3, 0))
					character:PivotTo(pos)
				end
			end
		end
	end)
end

return CommandsService
