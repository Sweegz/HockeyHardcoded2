local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local SetupClientCharacter = {}

local function setupClient(character: Model)
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("PVInstance") then
			CollectionService:AddTag(descendant, "Client")
		end
	end

	for _, child in character:GetChildren() do
		if child:IsA("BasePart") then
			child.CollisionGroup = "ClientCharacter"
		end
	end

	local descendantAddedConnection = character.DescendantAdded:Connect(function(descendant: Instance)
		if descendant:IsA("PVInstance") then
			CollectionService:AddTag(descendant, "Client")
		end
	end)

	local descendantRemovingConnection = character.DescendantRemoving:Connect(function(descendant: Instance)
		if descendant:IsA("PVInstance") then
			CollectionService:RemoveTag(descendant, "Client")
		end
	end)

	character.Destroying:Once(function()
		for _, descendant in character:GetDescendants() do
			if descendant:IsA("PVInstance") then
				CollectionService:RemoveTag(descendant, "Client")
			end
		end

		descendantAddedConnection:Disconnect()
		descendantRemovingConnection:Disconnect()
	end)

	local RightArm = character:WaitForChild("Right Arm")
	if RightArm then
		RightArm.CanCollide = false
		RightArm.CustomPhysicalProperties = PhysicalProperties.new(1.4, 0.3, 0.5)
	end

	local LeftArm = character:WaitForChild("Left Arm")
	if LeftArm then
		LeftArm.CanCollide = false
		LeftArm.CustomPhysicalProperties = PhysicalProperties.new(1.4, 0.3, 0.5)
	end

	local RightLeg = character:WaitForChild("Right Leg")
	if not RightLeg then
		return
	end

	local LeftLeg = character:WaitForChild("Left Leg")
	if not LeftLeg then
		return
	end

	local leftLegCollider = Instance.new("Part")
	leftLegCollider.Name = "LeftLegCollider"
	leftLegCollider.Size = Vector3.new(1, 1.8, 1)
	leftLegCollider.Parent = character
	leftLegCollider.CollisionGroup = "Legs"
	leftLegCollider.Transparency = 1

	local llcWeld = Instance.new("Weld")
	llcWeld.Parent = leftLegCollider
	llcWeld.Part0 = leftLegCollider
	llcWeld.Part1 = LeftLeg
	llcWeld.C1 = CFrame.new(0, 0.1, 0)

	local rightLegCollider = Instance.new("Part")
	rightLegCollider.Name = "RightLegCollider"
	rightLegCollider.Size = Vector3.new(1, 1.8, 1)
	rightLegCollider.Parent = character
	rightLegCollider.CollisionGroup = "Legs"
	rightLegCollider.Transparency = 1

	local rlcWeld = Instance.new("Weld")
	rlcWeld.Parent = rightLegCollider
	rlcWeld.Part0 = rightLegCollider
	rlcWeld.Part1 = RightLeg
	rlcWeld.C1 = CFrame.new(0, 0.1, 0)
end

local function setupCharacter(character: Model)
	local RightArm = character:WaitForChild("Right Arm")
	if RightArm then
		RightArm.CanCollide = false
	end

	local LeftArm = character:WaitForChild("Left Arm")
	if LeftArm then
		LeftArm.CanCollide = false
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	if Workspace:GetAttribute("CustomReplication") then
		humanoidRootPart.Anchored = true
	end

	for _, child in character:GetDescendants() do
		if child:IsA("BasePart") then
			child.CanCollide = false
		end
	end

	local torso = character:WaitForChild("Torso") :: BasePart
	torso.CollisionGroup = "Nothing"
	torso:GetPropertyChangedSignal("CanCollide"):Connect(function()
		torso.CanCollide = false
	end)

	local collider = Instance.new("Part")
	collider.Parent = character
	collider.Name = "Collider"
	collider.Transparency = 1
	collider.Size = Vector3.new(4, 5, 2)
	collider.CollisionGroup = "CharacterCollider"
	collider.EnableFluidForces = false
	collider.CustomPhysicalProperties = PhysicalProperties.new(100, 0.2, 0.2)

	local colliderWeld = Instance.new("Weld")
	colliderWeld.Parent = collider
	colliderWeld.Part0 = collider
	colliderWeld.Part1 = humanoidRootPart

	character.ChildAdded:Connect(function(child: Instance)
		if child:IsA("BasePart") then
			child.CanCollide = false
		end

		for _, desc in child:GetDescendants() do
			if desc:IsA("BasePart") then
				desc.CanCollide = false
			end
		end
	end)

	print("Created Hitbox")
end

function SetupClientCharacter:Load()
	for _, player in Players:GetPlayers() do
		if player ~= LocalPlayer then
			player.CharacterAdded:Connect(setupCharacter)
			if player.Character then
				setupCharacter(player.Character)
			end
		end
	end

	if LocalPlayer.Character then
		setupClient(LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(setupClient)

	Players.PlayerAdded:Connect(function(player: Player)
		if player.Character then
			setupCharacter(player.Character)
		end
		player.CharacterAdded:Connect(setupCharacter)
	end)
end

return SetupClientCharacter
