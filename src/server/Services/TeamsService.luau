local Teams = game:GetService("Teams")

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

return TeamsService
