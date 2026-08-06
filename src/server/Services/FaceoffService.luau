local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TeamsService = require(script.Parent.TeamsService)
local Signal = require(ReplicatedStorage.Packages.Signal)

local FACEOFF_TIME = 30

local FaceoffService = {
	OnFaceoffComplete = Signal.new(),
	TimeLeft = 0,
	Active = false,
	HomeReady = false,
	AwayReady = false,
}

local FaceoffModel = Workspace:WaitForChild("Rink"):WaitForChild("Game"):WaitForChild("Faceoff") :: Model
local HomePad = FaceoffModel:WaitForChild("Home") :: BasePart
local AwayPad = FaceoffModel:WaitForChild("Away") :: BasePart
local BillboardGui = FaceoffModel.PrimaryPart:WaitForChild("BillboardGui") :: BillboardGui
local TextLabel = BillboardGui:WaitForChild("TextLabel") :: TextLabel

local function GetFaceoffPositions(team: Team): { BasePart }?
	if team == TeamsService.homeTeam then
		return {
			FaceoffModel:FindFirstChild("H1") :: BasePart,
			FaceoffModel:FindFirstChild("H2") :: BasePart,
			FaceoffModel:FindFirstChild("H3") :: BasePart,
			FaceoffModel:FindFirstChild("H4") :: BasePart,
			FaceoffModel:FindFirstChild("H5") :: BasePart,
		}
	elseif team == TeamsService.awayTeam then
		return {
			FaceoffModel:FindFirstChild("A1") :: BasePart,
			FaceoffModel:FindFirstChild("A2") :: BasePart,
			FaceoffModel:FindFirstChild("A3") :: BasePart,
			FaceoffModel:FindFirstChild("A4") :: BasePart,
			FaceoffModel:FindFirstChild("A5") :: BasePart,
		}
	end

	return nil
end

function FaceoffService:FindClosestSpot(gameModel: Model, position: Vector3)
	position *= Vector3.new(1, 0, 1)
	local zOffset = math.abs(position.Z)

	local dots = gameModel:FindFirstChild("Dots")
	if not dots or not dots:IsA("Model") then
		return Vector3.new(0, 1, 0)
	end

	local blueLines = gameModel:FindFirstChild("BlueLines")
	if not blueLines then
		return Vector3.new(0, 1, 0)
	end

	local behindLine = false

	for _, line in blueLines:GetChildren() do
		if line:IsA("BasePart") then
			local lookVector = line.CFrame.LookVector

			if zOffset - 1 > (line.Position.Z * lookVector.Z) then
				behindLine = true
				break
			end
		end
	end

	if not behindLine then
		return Vector3.new(0, 1, 0)
	end

	local smallestDist = 99999
	local smallestDot = nil

	for _, dot in dots:GetChildren() do
		if dot:IsA("BasePart") then
			local dotPosition = dot.Position * Vector3.new(1, 0, 1)
			local dist = (position - dotPosition).Magnitude

			if dist < smallestDist then
				smallestDist = dist
				smallestDot = dot
			end
		end
	end

	if smallestDot then
		return smallestDot.Position * Vector3.new(1, 0, 1) + Vector3.new(0, 1, 0)
	end

	return Vector3.new(0, 1, 0)
end

local function FillFaceoffPositions(player: Player)
	local team = player.Team

	local positions = GetFaceoffPositions(team)
	if not positions then
		return
	end

	local character = player.Character
	if character then
		character:PivotTo(positions[1].CFrame)
		character.PrimaryPart.Anchored = true
		character.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
		character.PrimaryPart.AssemblyAngularVelocity = Vector3.zero
	end

	local excludedPlayers = {}
	excludedPlayers[player] = true

	for i, pos in positions do
		if i == 1 then
			continue
		end

		local closestDist = 99999999
		local closestPlayer = nil

		for _, p in Players:GetPlayers() do
			if excludedPlayers[p] or p.Team ~= player.Team then
				continue
			end

			local c = p.Character
			if not c then
				continue
			end

			local primaryPart = c.PrimaryPart
			if not primaryPart then
				continue
			end

			local dist = (pos.Position - primaryPart.Position).Magnitude
			if dist < closestDist then
				closestDist = dist
				closestPlayer = p
			end
		end

		if closestPlayer then
			excludedPlayers[closestPlayer] = true
			local c = closestPlayer.Character
			if c then
				c:PivotTo(pos.CFrame)
				c.PrimaryPart.Anchored = true
				c.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
				c.PrimaryPart.AssemblyAngularVelocity = Vector3.zero
			end
		end
	end

	-- yes
end

local function onFaceoffPadTouched() end

function FaceoffService:Create(position: Vector3)
	print("Faceoff created.")

	FaceoffModel:PivotTo(CFrame.new(position))
	HomePad.Transparency = 0.5
	AwayPad.Transparency = 0.5
	TextLabel.TextTransparency = 0
	BillboardGui.Enabled = true

	FaceoffService.HomeReady = false
	FaceoffService.AwayReady = false
	FaceoffService.TimeLeft = FACEOFF_TIME
end

function FaceoffService:End()
	FaceoffService.OnFaceoffComplete:Fire()
	HomePad.Transparency = 1
	AwayPad.Transparency = 1
	TextLabel.TextTransparency = 1
	BillboardGui.Enabled = false
end

function FaceoffService:Load()
	HomePad.Touched:Connect(function(hit: BasePart)
		if FaceoffService.TimeLeft <= 0 or FaceoffService.HomeReady then
			return
		end

		local parent = hit.Parent
		if not parent then
			return
		end

		if not parent:FindFirstChild("Humanoid") then
			return
		end

		local character = parent :: Model
		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		if player.Team ~= TeamsService.homeTeam then
			return
		end

		local positions = GetFaceoffPositions(player.Team)
		if not positions then
			return
		end

		FillFaceoffPositions(player)

		FaceoffService.HomeReady = true

		if #TeamsService.awayTeam:GetPlayers() == 0 then
			FaceoffService.AwayReady = true
		end
		print("Home Ready!")
	end)

	AwayPad.Touched:Connect(function(hit: BasePart)
		if FaceoffService.TimeLeft <= 0 or FaceoffService.AwayReady then
			return
		end

		local parent = hit.Parent
		if not parent then
			return
		end

		if not parent:FindFirstChild("Humanoid") then
			return
		end

		local character = parent :: Model
		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		if player.Team ~= TeamsService.awayTeam then
			return
		end

		local positions = GetFaceoffPositions(player.Team)
		if not positions then
			return
		end

		FillFaceoffPositions(player)

		FaceoffService.AwayReady = true
		if #TeamsService.homeTeam:GetPlayers() == 0 then
			FaceoffService.HomeReady = true
		end
		print("Away Ready!")
	end)
end

function FaceoffService:Start()
	RunService.Heartbeat:Connect(function(dt: number)
		if FaceoffService.TimeLeft > 0 then
			FaceoffService.TimeLeft -= dt

			if FaceoffService.TimeLeft < 1 then
				local transparency = (1 - FaceoffService.TimeLeft / 2)
				HomePad.Transparency = transparency
				AwayPad.Transparency = transparency
				TextLabel.TextTransparency = transparency
			end

			if FaceoffService.TimeLeft > 1 and (FaceoffService.HomeReady and FaceoffService.AwayReady) then
				FaceoffService.TimeLeft = 1
			end

			if FaceoffService.TimeLeft <= 0 then
				FaceoffService.TimeLeft = 0
				FaceoffService:End()
			end

			TextLabel.Text = math.round(FaceoffService.TimeLeft)
		end
	end)
end

return FaceoffService
