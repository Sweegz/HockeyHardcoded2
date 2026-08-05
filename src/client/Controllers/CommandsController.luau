local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommandsController = {}

local Net = ReplicatedStorage:WaitForChild("Net") :: Folder
local Bench = Net:WaitForChild("Bench") :: RemoteEvent

function CommandsController:Load()
	Bench.OnClientEvent:Connect(function()
		print("Got benched")
	end)
end

function CommandsController:Bench(targetPlayer: Player, benched: boolean)
	Bench:FireServer(targetPlayer, benched)
end

return CommandsController
