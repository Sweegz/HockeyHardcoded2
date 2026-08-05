local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local EntityMap = require(StarterPlayer.StarterPlayerScripts.EntityMap)
local EntityMap2 = require(StarterPlayer.StarterPlayerScripts.EntityMap2)
local PuckController = require(script.Parent.PuckController2)

local LocalPlayer = Players.LocalPlayer

local GhostWeldController = {}

function GhostWeldController:Start()
	if not Workspace:GetAttribute("CustomReplication") then
		return
	end

	RunService.PreRender:Connect(function(dt)
		for _, puck: BasePart in CollectionService:GetTagged("Replicated") and CollectionService:GetTagged("Puck") do
			local clientPuck = EntityMap[puck]
			if not clientPuck then
				continue
			end

			local visualPuck = EntityMap2[puck]
			if not visualPuck then
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
				clientPuck.CFrame = CFrame.new(shot)
				visualPuck.CFrame = CFrame.new(shot)
				return
			end

			if currentState:match("Default") then
				local gluedfront = character:FindFirstChild("GluedFront", true)
				if gluedfront then
					clientPuck.CFrame = gluedfront.CFrame * CFrame.Angles(0, 0, math.rad(90))
					visualPuck.CFrame = clientPuck.CFrame
				end
			else
				local front = character:FindFirstChild("Front", true)
				if front then
					clientPuck.CFrame = front.CFrame
					visualPuck.CFrame = clientPuck.CFrame
				end
			end
		end
	end)
end

return GhostWeldController
