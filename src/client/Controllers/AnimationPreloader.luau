local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GoalieAnimations = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Goalie")

local AnimationPreloader = {}

function AnimationPreloader:SetupGoalie(model: Model)
	local humanoid = model:WaitForChild("Humanoid") :: Humanoid
	local animator = humanoid:WaitForChild("Animator") :: Animator

	for _, anim in GoalieAnimations:GetChildren() do
		if not anim:IsA("Animation") then
			continue
		end

		animator:LoadAnimation(anim)
	end

	--print("Loaded animations for", model)
end

function AnimationPreloader:Load()
	for _, model: Model in CollectionService:GetTagged("GoalieModel") do
		AnimationPreloader:SetupGoalie(model)
	end

	CollectionService:GetInstanceAddedSignal("GoalieModel"):Connect(function(instance: Instance)
		AnimationPreloader:SetupGoalie(instance :: Model)
	end)
end

return AnimationPreloader
