local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local PuckController = require(script.Parent.PuckController2)

local LocalPlayer = Players.LocalPlayer

local GhostWeldController = {}

function GhostWeldController:Start()
	if not Workspace:GetAttribute("CustomReplication") then
		return
	end

	RunService.PreRender:Connect(function(dt)
		for _, puck: BasePart in CollectionService:GetTagged("Replicated") and CollectionService:GetTagged("Puck") do
			local transformPuck = puck:FindFirstChild("Transform")
			if not transformPuck then
				continue
			end

			local viewPuck = puck:FindFirstChild("View")
			if not viewPuck then
				return
			end

			local ownerId = PuckController:GetOwner(puck)
			if not ownerId then
				puck:SetAttribute("Shot", nil)
				continue
			end

			local owner = Players:GetPlayerByUserId(ownerId)
			if not owner then
				continue
			end

			local character = owner.Character
			if not character then
				continue
			end

			local currentState = nil

			if owner == LocalPlayer then
				currentState = owner:GetAttribute("ClientCurrentState") or "DefaultState"
			else
				currentState = owner:GetAttribute("CurrentState") or "DefaultState"
			end

			local shot = puck:GetAttribute("Shot")

			if shot then
				transformPuck.CFrame = CFrame.new(shot)
				viewPuck.CFrame = CFrame.new(shot)
				return
			end

			if currentState:match("Default") then
				local gluedfront = character:FindFirstChild("GluedFront", true)
				if gluedfront then
					transformPuck.CFrame = gluedfront.CFrame * CFrame.Angles(0, 0, math.rad(90))
					viewPuck.CFrame = transformPuck.CFrame
				end
			else
				local front = character:FindFirstChild("Front", true)
				if front then
					transformPuck.CFrame = front.CFrame
					viewPuck.CFrame = transformPuck.CFrame
				end
			end
		end
	end)
end

return GhostWeldController
