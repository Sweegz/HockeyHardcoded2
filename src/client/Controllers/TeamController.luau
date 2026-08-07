local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Teams = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer

local TeamController = {}

local SpectatorBlock = Workspace:WaitForChild("Rink"):WaitForChild("SpectatorBlock") :: Model
local BenchBlock = Workspace:WaitForChild("Rink"):WaitForChild("BenchBlock") :: Model

local function SetCollisions(model: Model, block: boolean)
	for _, part: BasePart in model:GetChildren() do
		part.CanCollide = block
	end
end

function TeamController:Load()
	if LocalPlayer.TeamColor ~= BrickColor.Gray() then
		SetCollisions(SpectatorBlock, false)
	else
		SetCollisions(SpectatorBlock, true)
	end

	if LocalPlayer:GetAttribute("Benched") then
		SetCollisions(BenchBlock, true)
	else
		SetCollisions(BenchBlock, false)
	end

	LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
		if LocalPlayer.TeamColor ~= BrickColor.Gray() then
			SetCollisions(SpectatorBlock, false)
		else
			SetCollisions(SpectatorBlock, true)
		end
	end)

	LocalPlayer.AttributeChanged:Connect(function(attributeName: string)
		if attributeName == "Benched" then
			if LocalPlayer:GetAttribute("Benched") then
				SetCollisions(BenchBlock, true)
				local character = LocalPlayer.Character
				if character then
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					if humanoid then
						humanoid:UnequipTools()
					end
				end
			else
				SetCollisions(BenchBlock, false)
			end
		end
	end)
end

function TeamController:GetHomeTeam(): Team?
	for _, team in Teams:GetTeams() do
		if team.TeamColor == BrickColor.Blue() then
			return team
		end
	end
	return nil
end

function TeamController:GetAwayTeam(): Team?
	for _, team in Teams:GetTeams() do
		if team.TeamColor == BrickColor.Red() then
			return team
		end
	end
	return nil
end

return TeamController
