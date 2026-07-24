local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Chrono = require(ReplicatedStorage.Packages.Chrono)
local GhostTransformController = {}

local function GetInterpolated(entity): CFrame?
	local snapshot = entity.snapshot
	if not snapshot then
		return
	end

	local targetTime = Chrono.Entity.GetTargetRenderTime(entity)
	local targetCFrame = snapshot:GetAt(targetTime)

	if not targetCFrame then
		return
	end

	return targetCFrame
end

function GhostTransformController:Start()
	if not Workspace:GetAttribute("CustomReplication") then
		return
	end

	RunService.PreRender:Connect(function(dt)
		local puck = Workspace.Pucks:FindFirstChild("Puck")
		if not puck then
			return
		end

		local entity = Chrono.Holder.GetEntityFromModel(puck)
		if not entity then
			return
		end

		local cf = GetInterpolated(entity)
		if not cf then
			return
		end

		local clientPuck = Workspace.Client:FindFirstChild("Puck")
		if not clientPuck then
			clientPuck = ReplicatedStorage.Models.Pucks.Puck:clone()
			clientPuck.Parent = Workspace.Client
			clientPuck.Anchored = true
			clientPuck.CanCollide = false
			--clientPuck.BrickColor = BrickColor.Green()
			clientPuck.CollisionGroup = "Nothing"

			clientPuck.Transparency = 0
			puck.Transparency = 1
			puck.CollisionGroup = "Nothing"
		end

		local weld = puck:FindFirstChild("weld")
		if weld and weld.Part1 ~= nil then
			Chrono.Entity.Clear(entity)
		else
			clientPuck.CFrame = cf
		end
	end)
end

script:Destroy()

return GhostTransformController
