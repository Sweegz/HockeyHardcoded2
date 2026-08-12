local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local GoalService = {
	OnGoal = Signal.new(),
}

local function setupDetector(part: BasePart)
	part.Touched:Connect(function(hit: BasePart)
		if CollectionService:HasTag(hit, "MainPuck") then
			GoalService.OnGoal:Fire(hit, part)
		end
	end)
end

for _, part: BasePart in CollectionService:GetTagged("GoalDetector") do
	setupDetector(part)
end

CollectionService:GetInstanceAddedSignal("GoalDetector"):Connect(function(instance: Instance)
	setupDetector(instance :: BasePart)
end)

return GoalService
