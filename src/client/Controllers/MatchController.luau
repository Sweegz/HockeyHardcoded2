local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

local MatchController = {}

function MatchController.Start()
	Synchronizer:WaitAndCall("Match", function(channel)
		channel:OnChanged("Time", function(newValue: number, oldValue: number)
			print("Time", newValue)
		end)
		channel:OnChanged("Period", function(newValue: number, oldValue: number)
			print("Period", newValue)
		end)
	end)
end

return MatchController
