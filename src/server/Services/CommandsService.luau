local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local PlayerSessionService = require(script.Parent.PlayerSessionService)
local TeamsService = require(script.Parent.TeamsService)

local Net = ReplicatedStorage:WaitForChild("Net") :: Folder
local Bench = Net:WaitForChild("Bench") :: RemoteEvent
local TextMessageEvent = Net:WaitForChild("TextMessage") :: RemoteEvent

local Commands = TextChatService:WaitForChild("Commands")

local homeTeamCommand = Commands:WaitForChild("HomeTeamCommand") :: TextChatCommand
local awayTeamCommand = Commands:WaitForChild("AwayTeamCommand") :: TextChatCommand

local function CreateTeamTextMessage(player: Player, targetPlayer: Player, team: Team)
	-- Chat Message
	local assignedTeamColor = team.TeamColor.Color:ToHex()
	local playerTeamColor = player.Team.TeamColor.Color:ToHex()
	local targetPlayerTeamColor = targetPlayer.Team.TeamColor.Color:ToHex()

	local payload = ("<b><font color='#%s'>%s</font></b> teamed <b><font color='#%s'>%s</font></b> to <b><font color='#%s'>%s</font></b> "):format(
		playerTeamColor,
		player.DisplayName,
		targetPlayerTeamColor,
		targetPlayer.DisplayName,
		assignedTeamColor,
		team.Name
	)
	if player == targetPlayer then
		payload = ("<b><font color='#%s'>%s</font></b> teamed to <b><font color='#%s'>%s</font></b> "):format(
			playerTeamColor,
			player.DisplayName,
			assignedTeamColor,
			team.Name
		)
	end

	TextMessageEvent:FireAllClients(payload)
end

local CommandsService = {}

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

	homeTeamCommand.Triggered:Connect(function(source: TextSource, message: string)
		local player = Players:GetPlayerByUserId(source.UserId)
		if not player then
			return
		end

		message = message:lower()
		local words = string.split(message, " ")
		local target = words[2]

		if target == "me" then
			target = source.Name
		end

		local targetPlayer = Players:FindFirstChild(target) :: Player
		if not targetPlayer then
			return
		end

		local team = TeamsService.homeTeam
		CreateTeamTextMessage(player, targetPlayer, team)
		targetPlayer.Team = team
	end)

	awayTeamCommand.Triggered:Connect(function(source: TextSource, message: string)
		local player = Players:GetPlayerByUserId(source.UserId)
		if not player then
			return
		end

		message = message:lower()
		local words = string.split(message, " ")
		local target = words[2]

		if target == "me" then
			target = source.Name
		end

		local targetPlayer = Players:FindFirstChild(target) :: Player
		if not targetPlayer then
			return
		end

		local team = TeamsService.awayTeam
		CreateTeamTextMessage(player, targetPlayer, team)
		targetPlayer.Team = team
	end)
end

return CommandsService
