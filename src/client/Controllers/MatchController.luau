local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Synchronizer = require(ReplicatedStorage.ModdedPackages.Synchronizer)

local MatchController = {}

local Channel

function MatchController:Start()
	Synchronizer:WaitAndCall("Match", function(channel)
		Channel = channel

		channel:OnChanged("Time", function(newValue: number, _oldValue: number)
			--print("Time", newValue)
		end)
		channel:OnChanged("Period", function(newValue: number, _oldValue: number)
			--print("Period", newValue)
		end)
	end)
end

function MatchController:GetTime(): number
	return Channel:Get("Time")
end

function MatchController:GetPeriod(): number
	return Channel:Get("Period")
end

function MatchController:GetStarted(): boolean
	return Channel:Get("Started")
end

function MatchController:GetInPlay(): boolean
	return Channel:Get("InPlay")
end

return MatchController
