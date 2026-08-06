local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")

local Stick = ReplicatedStorage:WaitForChild("Stick")

local TeamsService = {
	homeTeam = Instance.new("Team"),
	awayTeam = Instance.new("Team"),
	fansTeam = Instance.new("Team"),
}

local function PlayerAdded(player: Player)
	local characterAdded = player.CharacterAdded:Connect(function(character: Model)
		if player.Team == TeamsService.homeTeam or player.Team == TeamsService.awayTeam then
			local stick = Stick:Clone()

			stick.Parent = player.Backpack
		end
	end)
end

function TeamsService:Load()
	local homeTeam = TeamsService.homeTeam
	homeTeam.Parent = Teams
	homeTeam.Name = "Tampa Bay Lightning"
	homeTeam.TeamColor = BrickColor.Blue()

	local awayTeam = TeamsService.awayTeam
	awayTeam.Parent = Teams
	awayTeam.Name = "Florida Panthers"
	awayTeam.TeamColor = BrickColor.Red()

	local fansTeam = TeamsService.fansTeam
	fansTeam.Parent = Teams
	fansTeam.Name = "Fans"
	fansTeam.TeamColor = BrickColor.Gray()
	fansTeam.AutoAssignable = false

	for _, player in Players:GetPlayers() do
		PlayerAdded(player)
	end

	Players.PlayerAdded:Connect(PlayerAdded)
end

function TeamsService:GetSpawn(team: Team): SpawnLocation?
	if team == TeamsService.homeTeam then
		return Workspace:FindFirstChild("HomeSpawn", true) :: SpawnLocation
	elseif team == TeamsService.awayTeam then
		return Workspace:FindFirstChild("AwaySpawn", true) :: SpawnLocation
	else
		return Workspace:FindFirstChild("FansSpawn", true) :: SpawnLocation
	end
end

return TeamsService
