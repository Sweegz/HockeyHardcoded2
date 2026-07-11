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

	--HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(3, 0.3, 0.5)

	character.ChildAdded:Connect(function(child)
		task.wait(0.5)
		character["Right Arm"].CanCollide = true
		character["Left Arm"].CanCollide = true
		character["Head"].CanCollide = true
		--character["Torso"].CanCollide = true

		local BodyAttach = child:FindFirstChild("BodyAttach")
		if child:IsA("Tool") and BodyAttach then
			ToolGrip.Part1 = BodyAttach
		end

		local Front = child:FindFirstChild("Front")
		if child:IsA("Tool") and Front then
			CollectGrip.Part1 = Front
		end

		CollectionService:AddTag(child, "Hittable")
	end)

	character.ChildRemoved:Connect(function(child)
		--[[local BodyAttach = child:FindFirstChild("BodyAttach")
		if child:IsA("Tool") and BodyAttach then
			ToolGrip.Part1 = nil
		end--]]
	end)

	for _, child in character:GetChildren() do
		if child:IsA("BasePart") then
			child.CollisionGroup = "Character"
		end

		CollectionService:AddTag(child, "Hittable")
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.Died:Once(function()
			for _, child in character:GetDescendants() do
				if child:IsA("Tool") then
					child:Destroy()
				end
			end

			local player = Players:GetPlayerFromCharacter(character)
			for _, child in player.Backpack:GetChildren() do
				child:Destroy()
			end
		end)
	end

	local ControllerManager = character:WaitForChild("ControllerManager")

	if ControllerManager then
		local GroundController: GroundController = ControllerManager:WaitForChild("GroundController")
		if GroundController then
			-- Double the move and turn speeds
			--GroundController.MoveSpeedFactor *= 2
			--GroundController.TurnSpeedFactor *= 2
			-- Add slight acceleration and deceleration
			--GroundController.AccelerationTime = 0
			--GroundController.DecelerationTime = 0
			GroundController.Friction = 2
			GroundController.FrictionWeight = 100
			GroundController.MoveSpeedFactor = 1
			GroundController.TurnSpeedFactor = 1
			GroundController.BalanceMaxTorque = 1000000
			GroundController.BalanceSpeed = 10
			--GroundController.BalanceRigidityEnabled = true
			print("Set GroundController")
		end
	end

	--humanoid.EvaluateStateMachine = true
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
