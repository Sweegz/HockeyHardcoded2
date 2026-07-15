local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Tools = require(ReplicatedFirst.Tools)

local LocalPlayer = Players.LocalPlayer

local ToolController = {}

local function hookTool(tool: Tool)
	if tool:GetAttribute("Initialized") then
		return
	end

	local toolController = Tools[tool.Name]
	if not toolController then
		return
	end

	tool:SetAttribute("Initialized", true)
	local controller = toolController.New(tool)

	local ancestryChangedConnection
	local destroyingConnection

	ancestryChangedConnection = tool.AncestryChanged:Connect(function()
		if not tool:IsDescendantOf(game) then
			controller:Destroy()
			ancestryChangedConnection:Disconnect()
			destroyingConnection:Disconnect()
		end
	end)

	destroyingConnection = tool.Destroying:Once(function()
		controller:Destroy()
		ancestryChangedConnection:Disconnect()
	end)
end

local backpackChildAddedConnection

local function setup()
	-- Check if tool is in Character
	local character = LocalPlayer.Character
	if character then
		for _, child in character:GetChildren() do
			if child:IsA("Tool") then
				hookTool(child)
			end
		end
	end

	-- Check if tool is in Backpack
	for _, child in LocalPlayer.Backpack:GetChildren() do
		if child:IsA("Tool") then
			hookTool(child)
		end
	end

	-- Disconnect existing connection
	if backpackChildAddedConnection then
		backpackChildAddedConnection:Disconnect()
	end

	-- Check if tool gets added to Backpack
	backpackChildAddedConnection = LocalPlayer.Backpack.ChildAdded:Connect(function(child: Instance)
		if child:IsA("Tool") then
			hookTool(child)
		end
	end)
end

function ToolController:Start()
	setup()
	LocalPlayer.CharacterAdded:Connect(setup)

	LocalPlayer.CharacterRemoving:Connect(function(_character: Model)
		if backpackChildAddedConnection then
			backpackChildAddedConnection:Disconnect()
		end
	end)
end

script:Destroy()

return ToolController
