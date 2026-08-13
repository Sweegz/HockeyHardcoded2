local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Chrono = require(ReplicatedStorage.ModdedPackages.Chrono)
local MatchService = require(script.Parent.MatchService)
local PlayerActionService = require(script.Parent.PlayerActionService)
local GoalieController = require(ServerScriptService.GoalieController)
local PuckService2 = require(script.Parent.PuckService2)

function line_to_plane_intersection(
	line_point: Vector3,
	line_direction: Vector3,
	plane_point: Vector3,
	plane_normal: Vector3
): Vector3
	local denominator = line_direction:Dot(plane_normal)
	if denominator == 0 then
		return line_point
	end
	local distance = ((plane_point - line_point):Dot(plane_normal)) / denominator
	return line_point + line_direction * distance
end

local ZoneToAnimationMap = {
	["Tar1"] = "Butterfly",
	["Tar2"] = "Glove1",
	["Tar3"] = "Butterfly",
	["Tar4"] = "Blocker1",
	["Tar5"] = "Blocker0",
	["Tar6"] = "Standing3",
	["Tar7"] = "Glove0",
	["Tar8"] = "Blocker0",
	["Tar9"] = "Standing3",
	["Tar10"] = "Glove2",
	["Tar11"] = "Blocker2",
}

local REACT_DURATION = 2

local GoalieService = {
	goalies = {},
}

function GoalieService:SetupGoalie(model: Model)
	model.PrimaryPart:SetNetworkOwner(nil)
	local goalie = GoalieController.New(model)
	GoalieService.goalies[model] = goalie
	--local xd = Chrono.Entity.new("Goalie", model, "NATIVE")
end

function GoalieService:Load()
	for _, model: Model in CollectionService:GetTagged("GoalieModel") do
		GoalieService:SetupGoalie(model)
	end

	CollectionService:GetInstanceAddedSignal("GoalieModel"):Connect(function(instance: Instance)
		GoalieService:SetupGoalie(instance :: Model)
	end)

	PlayerActionService.OnShotTowardsNet:Connect(function(data)
		local goalie = GoalieService.goalies[data.goalie]
		goalie.reacting = tick()
		local hit = data.rayResult.Instance

		local animationName = ZoneToAnimationMap[hit.Name]
		goalie:ChangeState(animationName)

		local pos1 = Vector3.new(goalie.center.CFrame.Position.X, 0, goalie.center.CFrame.Position.Z)
		local pos2 = Vector3.new(data.origin.X, 0, data.origin.Z)
		local look = CFrame.lookAt(pos1, pos2)

		local goalie_plane_intersection = line_to_plane_intersection(
			data.origin,
			data.direction,
			goalie.primaryPart.CFrame.Position, -- + Vector3.new(GOALIE_PLANE_X_OFFSET * primary_part.CFrame.LookVector.X, 0, 0),
			look.LookVector
		)

		local final_pos = CFrame.new(
			goalie_plane_intersection.X,
			goalie.primaryPart.CFrame.Y,
			goalie_plane_intersection.Z
		) * look.Rotation

		goalie.move.CFrame = final_pos
	end)
end

function GoalieService:Start()
	RunService.Heartbeat:Connect(function(dt: number)
		local puck = PuckService2:GetMainPuck()
		if not puck then
			return
		end

		if not PuckService2:IsPlayable(puck) then
			return
		end

		for _, goalie in GoalieService.goalies do
			local center = goalie.center
			local move = goalie.move

			local puckPos = puck.Position * Vector3.new(1, 0, 1)
			local centerPos = center.Position * Vector3.new(1, 0, 1)
			local diffVector = puckPos - centerPos
			local lookAt = CFrame.lookAt(centerPos, puckPos)

			local RADIUS = 8
			local dist = diffVector.Magnitude
			local dir = diffVector.Unit
			local dot = center.CFrame.LookVector:Dot(dir)

			if tick() > goalie.reacting + REACT_DURATION then
				if dist < 35 then
					goalie:ChangeState("Butterfly")
				elseif dist < 60 then
					goalie:ChangeState("Standing1")
				else
					goalie:ChangeState("Standing2")
				end

				if dot > 0 then
					local newPos = (center.Position + dir * RADIUS) * Vector3.new(1, 0, 1) + Vector3.new(0, 3.553, 0)
					move.CFrame = CFrame.new(newPos) * lookAt.Rotation
				end
			end

			--move.CFrame = CFrame.lookAt(newPos * Vector3.new(0, 0, 0), puck.Position * Vector3.new(0, 0, 0))
		end
	end)
end

return GoalieService
