local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local FaceoffService = require(script.Parent.FaceoffService)
local MusicService = require(script.Parent.MusicService)
local OutOfBoundsService = require(script.Parent.OutOfBoundsService)
local Synchronizer = require(ReplicatedStorage.ModdedPackages.Synchronizer)

local PuckService = require(ServerScriptService.Services.PuckService2)

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

	OutOfBoundsService.OnOutOfBounds:Connect(function(hit: BasePart)
		MatchService:OutOfPlay(hit)
	end)

	FaceoffService.OnFaceoffComplete:Connect(function()
		MatchService:StartPlay()
	end)
end

function MatchService:StartPlay()
	MatchService:SetPlay(true)
	local puck = PuckService:GetMainPuck()
	MusicService:Stop()
	if puck then
		task.wait(0.5)
		puck.Anchored = false
		puck:SetNetworkOwner(nil)

		for _, player in Players:GetPlayers() do
			local character = player.Character
			if character then
				character.PrimaryPart.Anchored = false
			end
		end
	end
end

function MatchService:OutOfPlay(puck: BasePart)
	if MatchService:IsInPlay() then
		print("Out of Play!")
		MatchService:SetPlay(false)
		MusicService:Play()

		local position: Vector3 = puck:GetAttribute("LastShotPosition") or Vector3.zero
		PuckService:SetPlayable(puck, false)

		local spot = FaceoffService:FindClosestSpot(Workspace.Rink.Game, position)
		spot *= Vector3.new(1, 0, 1)

		task.wait(5)

		local newPuck = PuckService:Create(spot + Vector3.new(0, 8, 0), true)
		PuckService:SetMainPuck(newPuck)
		newPuck.Anchored = true
		FaceoffService:Create(spot + Vector3.new(0, 1, 0))

		puck:Destroy()
	end
end

function MatchService:Start()
	MatchService:StartMatch()
	local puck = PuckService:Create(Vector3.new(0, 10, 0), true)
	PuckService:SetMainPuck(puck)
end

function MatchService:StartMatch()
	--[[if MatchService:IsStarted() then
		return
	end

	MatchService:SetStarted(true)
	MatchService:StartNewPeriod()

	task.spawn(function()
		while MatchService:IsStarted() do
			RunService.Heartbeat:Wait()
			if MatchService:IsInPlay() then
				local time = MatchService:GetTime()
				time -= 1
				MatchService:SetTime(time)
				print(MatchService:GetTime())

				if time == 0 then
					if MatchService:GetPeriod() == 3 then
						break
					else
						MatchService:StartNewPeriod()
					end
				end
				task.wait(1)
			end
		end

		print("Ended Game")
		MatchService:SetPeriod(0)
		MatchService:SetTime(0)
		MatchService:SetStarted(false)
	end)--]]
end

function MatchService:StartNewPeriod()
	local period = Channel:Get("Period")

	MatchService:SetPeriod(period + 1)
	MatchService:SetTime(300)
end

function MatchService:IsInPlay()
	return Channel:Get("InPlay") == true
end

function MatchService:IsStarted()
	return Channel:Get("Started") == true
end

function MatchService:GetTime()
	return Channel:Get("Time")
end

function MatchService:GetPeriod()
	return Channel:Get("Period")
end

function MatchService:SetPlay(inPlay: boolean)
	print("Set play to", inPlay)
	Channel:Set("InPlay", inPlay)
end

function MatchService:SetStarted(started: boolean)
	Channel:Set("Started", started)
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
