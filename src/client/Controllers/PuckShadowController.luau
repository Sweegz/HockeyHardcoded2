local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local EntityMap2 = require(StarterPlayer.StarterPlayerScripts.EntityMap2)
local PuckController2 = require(script.Parent.PuckController2)

local ShadowAsset = ReplicatedStorage:FindFirstChild("Assets"):FindFirstChild("Shadow")
local PuckFolder = Workspace:FindFirstChild("Client")

if not Workspace:GetAttribute("CustomReplication") then
	PuckFolder = Workspace:FindFirstChild("Pucks")
end

local Shadow = ShadowAsset:Clone()
Shadow.Parent = game.Workspace

local PuckShadowController = {}

function PuckShadowController:Start()
	RunService.PreRender:Connect(function()
		local puck = PuckController2:GetMainPuck()

		local visualPuck = EntityMap2[puck]
		puck = visualPuck

		if puck and puck.Position.Y > 2 then
			if not (Shadow.Transparency == 0.7) then
				Shadow.Transparency = 0.7
			end
		else
			if not (Shadow.Transparency == 1) then
				Shadow.Transparency = 1
			end
		end

		if not puck then
			return
		end

		local cf = puck.CFrame

		Shadow.CFrame = CFrame.new(cf.X, 0.55, cf.Z)
	end)
end

return PuckShadowController
