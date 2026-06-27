local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

local PuckController = {}

function PuckController.Start()
	Synchronizer:WaitAndCall("Puck", function(channel)
		print(channel:Get("Instance"))
		channel:OnChanged("Instance", function(newValue: BasePart, oldValue: BasePart)
			print("Instance", newValue)
			newValue.Transparency = 0.5
		end)
	end)
end

return PuckController
