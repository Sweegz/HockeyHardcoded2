local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PuckController2 = require(script.Parent.PuckController2)

local ShadowAsset = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Shadow") :: BasePart

local Shadow = ShadowAsset:Clone()
Shadow.Parent = game.Workspace

local PuckShadowController = {}

function PuckShadowController:Start()
	RunService.PreRender:Connect(function()
		local puck = PuckController2:GetMainPuck()
		if not puck then
			return
		end

		local viewPuck = puck:FindFirstChild("View") :: BasePart

		if viewPuck and viewPuck.Position.Y > 2 then
			if not (Shadow.Transparency == 0.7) then
				Shadow.Transparency = 0.7
			end
		else
			if not (Shadow.Transparency == 1) then
				Shadow.Transparency = 1
			end
		end

		if not viewPuck then
			return
		end

		local cf = viewPuck.CFrame

		Shadow.CFrame = CFrame.new(cf.X, 0.55, cf.Z)
	end)
end

return PuckShadowController
