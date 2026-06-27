local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

local PuckService = require(ServerScriptService.Services.PuckService)

local MatchService = {}
local Channel = nil

function MatchService:Load()
	Channel = Synchronizer:Create("Match", {
		Started = false,
		Period = 0,
		Time = 0,
		InPlay = true,
	})

	for _, player in ipairs(Players:GetPlayers()) do
		Channel:AddListener(player)
	end

	Players.PlayerAdded:Connect(function(player: Player)
		Channel:AddListener(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		Channel:RemoveListener(player)
	end)
end

function MatchService:Start()
	MatchService:StartMatch()
	PuckService:Spawn(Vector3.new(0, 10, 0))

	task.delay(3, function()
		PuckService:Spawn(Vector3.new(0, 10, 0))
	end)
end

function MatchService:StartMatch()
	if Channel:Get("Started") then
		return
	end

	Channel:Set("Started", true)
	MatchService:StartNewPeriod()

	task.spawn(function()
		while task.wait(1) and Channel:Get("Started") do
			local time = Channel:Get("Time")
			time -= 1
			MatchService:SetTime(time)

			if time == 0 then
				if Channel:Get("Period") == 3 then
					break
				else
					MatchService:StartNewPeriod()
				end
			end
		end

		print("Ended Game")
		Channel:Set("Period", 0):Set("Time", 0):Set("Started", false)
	end)
end

function MatchService:StartNewPeriod()
	local period = Channel:Get("Period")

	MatchService:SetPeriod(period + 1)
	MatchService:SetTime(300)
end

function MatchService:SetTime(time: number)
	Channel:Set("Time", time)
end

function MatchService:SetPeriod(period: number)
	Channel:Set("Period", period)
end

function MatchService:EndMatch()
	Channel:Set("Started", false)
end

return MatchService
