local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ShadowAsset = ReplicatedStorage:FindFirstChild("Models"):FindFirstChild("Shadow")
local PuckFolder = Workspace:FindFirstChild("Client")

local Shadow = ShadowAsset:Clone()
Shadow.Parent = game.Workspace

local PuckShadowController = {}

function PuckShadowController:Start()
	RunService.PreRender:Connect(function()
		local puck = PuckFolder:FindFirstChild("Puck")

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
