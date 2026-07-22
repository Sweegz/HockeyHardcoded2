local Players = game:GetService("Players")

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PuckController = require(script.Parent.PuckController)

local GhostWeldController = {}

function GhostWeldController:Start()
	if not Workspace:GetAttribute("CustomReplication") then
		return
	end

	RunService.PreRender:Connect(function(dt)
		local puck = Workspace.Pucks:FindFirstChild("Puck")
		if not puck then
			return
		end

		local clientPuck = Workspace.Client:FindFirstChild("Puck")
		if not clientPuck then
			return
		end

		local owner = PuckController:GetOwner()
		if not owner then
			return
		end

		local character = owner.Character
		if not character then
			return
		end

		local currentState = nil

		if owner == Players.LocalPlayer then
			currentState = owner:GetAttribute("ClientCurrentState") or "DefaultState"
		else
			currentState = owner:GetAttribute("CurrentState") or "DefaultState"
		end

		if currentState:match("Default") then
			local gluedfront = character:FindFirstChild("GluedFront", true)
			if gluedfront then
				clientPuck.CFrame = gluedfront.CFrame * CFrame.Angles(0, 0, math.rad(90))
			end
		else
			local front = character:FindFirstChild("Front", true)
			if front then
				clientPuck.CFrame = front.CFrame
			end
		end
	end)
end

return GhostWeldController
