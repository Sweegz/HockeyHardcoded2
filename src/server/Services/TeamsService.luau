local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")

local TeamsService = {
	homeTeam = Instance.new("Team"),
	awayTeam = Instance.new("Team"),
	fansTeam = Instance.new("Team"),
}

function TeamsService:Load()
	local homeTeam = TeamsService.homeTeam
	homeTeam.Parent = Teams
	homeTeam.Name = "Home"
	homeTeam.TeamColor = BrickColor.Blue()

	local awayTeam = TeamsService.awayTeam
	awayTeam.Parent = Teams
	awayTeam.Name = "Away"
	awayTeam.TeamColor = BrickColor.Red()

	local fansTeam = TeamsService.fansTeam
	fansTeam.Parent = Teams
	fansTeam.Name = "Fans"
	fansTeam.TeamColor = BrickColor.Gray()
	fansTeam.AutoAssignable = false
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
