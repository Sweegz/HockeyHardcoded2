local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local characterAddedConnections = {}

function SetupCharacter(character: Instance)
	local Torso = character:WaitForChild("Torso")
	local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")

	local RightLeg = character:FindFirstChild("Right Leg")
	if RightLeg then
		CollectionService:AddTag(RightLeg, "Collect")
	end

	local LeftLeg = character:FindFirstChild("Left Leg")
	if LeftLeg then
		CollectionService:AddTag(LeftLeg, "Collect")
	end

	local ToolGrip = Instance.new("Motor6D")
	ToolGrip.Name = "ToolGrip"
	ToolGrip.Part0 = Torso
	ToolGrip.Parent = Torso
	ToolGrip.C0 = CFrame.new(0.9, 0, 0)
	ToolGrip.C1 = CFrame.new(-1.1, 0, 0)

	local CollectGrip = Instance.new("Motor6D")
	CollectGrip.Name = "CollectGrip"
	CollectGrip.Part0 = HumanoidRootPart
	CollectGrip.Parent = HumanoidRootPart

	character.ChildAdded:Connect(function(child)
		local BodyAttach = child:FindFirstChild("BodyAttach")
		if child:IsA("Tool") and BodyAttach then
			ToolGrip.Part1 = BodyAttach
		end

		local Front = child:FindFirstChild("Front")
		if child:IsA("Tool") and Front then
			CollectGrip.Part1 = Front
		end
	end)

	character.ChildRemoved:Connect(function(child)
		local BodyAttach = child:FindFirstChild("BodyAttach")
		if child:IsA("Tool") and BodyAttach then
			ToolGrip.Part1 = nil
		end
	end)
end

local SetupCharacterService = {}

function SetupCharacterService:Start()
	Players.PlayerAdded:Connect(function(player: Player)
		local character = player.Character
		if character then
			SetupCharacter(character)
		end
		characterAddedConnections[player.UserId] = player.CharacterAdded:Connect(SetupCharacter)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		local conn = characterAddedConnections[player.UserId]
		if conn then
			conn:Disconnect()
			conn = nil
		end
	end)
end

return SetupCharacterService
