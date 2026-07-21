local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local SetupCLientCharacter = {}

local function setupCharacter(character: Model)
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
end

function SetupCLientCharacter:Load()
	if LocalPlayer.Character then
		setupCharacter(LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(setupCharacter)
end

return SetupCLientCharacter
