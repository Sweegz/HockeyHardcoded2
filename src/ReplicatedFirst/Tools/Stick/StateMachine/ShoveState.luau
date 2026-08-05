local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local PlayerActionController = require(StarterPlayer.StarterPlayerScripts.Controllers.PlayerActionController)
local Constants = require(script.Parent.Parent.Constants)

local LocalPlayer = Players.LocalPlayer

local function shove(hitPart: BasePart)
	local character = LocalPlayer.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	local hitPartParent = hitPart.Parent
	if not hitPartParent:FindFirstChild("Humanoid") then
		return
	end

	local hitPlayer = Players:GetPlayerFromCharacter(hitPartParent)
	if not hitPlayer then
		return
	end

	if hitPlayer.Team == LocalPlayer.Team then
		return
	end

	PlayerActionController:Shove(hitPlayer, hitPart, humanoidRootPart.CFrame.lookVector)
end

local function shoveCollisionDetection(self)
	local character = LocalPlayer.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	local listOfCharacters = {}

	for _, player: Player in Players:getPlayers() do
		if player == LocalPlayer then -- or player.Team == LocalPlayer.Team
			continue
		end

		table.insert(listOfCharacters, player.Character)
	end

	while self.shoving do
		RunService.RenderStepped:Wait()
		if not humanoidRootPart then
			return
		end

		local attackDataList = {}
		local closestPart = nil

		local tool = self.ctx.tool
		local shaft = tool:FindFirstChild("ShaftHitbox")

		local humanoidRootPartLookVector = humanoidRootPart.CFrame.lookVector
		local shaftPositions = {
			shaft.Position,
			(shaft.CFrame * CFrame.new(0, -2, 0)).Position,
			(shaft.CFrame * CFrame.new(0, 2, 0)).Position,
		}

		for _, shaftPosition in pairs(shaftPositions) do
			for _, potentialTarget in pairs(listOfCharacters) do
				if
					potentialTarget:FindFirstChild("HumanoidRootPart")
					and potentialTarget:FindFirstChild("Right Arm")
					and potentialTarget:FindFirstChild("Left Arm")
					and potentialTarget:FindFirstChild("Stick")
					and potentialTarget.Stick:FindFirstChild("Shaft")
				then
					local unitVectorToTarget = (potentialTarget.HumanoidRootPart.Position - humanoidRootPart.Position).Unit
					if math.deg((math.acos((humanoidRootPartLookVector.Unit:Dot(unitVectorToTarget))))) < 95 then
						local magnitudeForward = (shaftPosition - (potentialTarget.HumanoidRootPart.CFrame * CFrame.new(
							0,
							0,
							-0.5
						)).Position).Magnitude
						local magnitudeBackward = (shaftPosition - (
							potentialTarget.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0.5)
						).Position).Magnitude
						local magnitudeLeft = (shaftPosition - (potentialTarget.HumanoidRootPart.CFrame * CFrame.new(
							-1,
							0,
							0
						)).Position).Magnitude
						local magnitudeRight = (shaftPosition - (potentialTarget.HumanoidRootPart.CFrame * CFrame.new(
							1,
							0,
							0
						)).Position).Magnitude
						local magnitudeRightArm = (shaftPosition - potentialTarget["Right Arm"].Position).Magnitude
						local magnitudeRightArmDown = (shaftPosition - (
							potentialTarget["Right Arm"].CFrame * CFrame.new(0, -1, 0)
						).Position).Magnitude
						local magnitudeLeftArm = (shaftPosition - potentialTarget["Left Arm"].Position).Magnitude
						local magnitudeLeftArmDown = (shaftPosition - (potentialTarget["Left Arm"].CFrame * CFrame.new(
							0,
							-1,
							0
						)).Position).Magnitude
						local magnitudeStickShaft = (shaftPosition - potentialTarget.Stick.ShaftHitbox.Position).Magnitude
						local magnitudeStickShaftUp = (shaftPosition - (
							potentialTarget.Stick.ShaftHitbox.CFrame * CFrame.new(0, 2.5, 0)
						).Position).Magnitude
						local magnitudeStickShaftDown = (shaftPosition - (
							potentialTarget.Stick.ShaftHitbox.CFrame * CFrame.new(0, -2.5, 0)
						).Position).Magnitude
						if
							magnitudeForward <= 20
							and magnitudeBackward <= 20
							and magnitudeLeft <= 20
							and magnitudeRight <= 20
							and magnitudeRightArm <= 20
							and magnitudeRightArmDown <= 20
							and magnitudeLeftArm <= 20
							and magnitudeLeftArmDown <= 20
							and magnitudeStickShaft <= 20
							and magnitudeStickShaftUp <= 20
							and magnitudeStickShaftDown <= 20
						then
							table.insert(attackDataList, {
								magnitudeForward,
								potentialTarget,
								3,
							})
							table.insert(attackDataList, {
								magnitudeBackward,
								potentialTarget,
								3,
							})
							table.insert(attackDataList, {
								magnitudeLeft,
								potentialTarget,
								3,
							})
							table.insert(attackDataList, {
								magnitudeRight,
								potentialTarget,
								3,
							})
							table.insert(attackDataList, {
								magnitudeRightArm,
								potentialTarget,
								3,
							})
							table.insert(attackDataList, {
								magnitudeRightArmDown,
								potentialTarget,
								3,
							})
							table.insert(attackDataList, {
								magnitudeLeftArm,
								potentialTarget,
								3,
							})
							table.insert(attackDataList, {
								magnitudeLeftArmDown,
								potentialTarget,
								3,
							})
							table.insert(attackDataList, {
								magnitudeStickShaft,
								potentialTarget,
								3,
							})
							table.insert(attackDataList, {
								magnitudeStickShaftUp,
								potentialTarget,
								3,
							})
							table.insert(attackDataList, {
								magnitudeStickShaftDown,
								potentialTarget,
								3,
							})
						end
					end
				end
			end
			if #attackDataList > 0 then
				table.sort(attackDataList, function(itemA, itemB) --[[ Line: 1803 ]]
					return itemA[1] < itemB[1]
				end)
				if attackDataList[1][1] <= attackDataList[1][3] then
					local characterModel = attackDataList[1][2]
					local closestEnemyMagnitude = nil
					for _, childPart in pairs(characterModel:GetChildren()) do
						if childPart:IsA("BasePart") then
							local distanceToPart = (humanoidRootPart.Position - childPart.Position).Magnitude
							if
								not closestEnemyMagnitude and distanceToPart <= 3.5
								or closestEnemyMagnitude and distanceToPart < closestEnemyMagnitude
							then
								closestEnemyMagnitude = distanceToPart
								closestPart = childPart
							end
						end
					end
					if closestPart then
						shove(closestPart)
						return
					end
				end
			end
		end
	end
end

--[[ GetPartsInPart implementation with ShaftHitbox
local function shove(self)
	while self.shoving do
		RunService.RenderStepped:Wait()
		local shaftHitbox = self.ctx.tool:FindFirstChild("ShaftHitbox")
		local character = self.ctx.humanoid.Parent

		if shaftHitbox and character then
			local box_params = OverlapParams.new()
			box_params.FilterType = Enum.RaycastFilterType.Exclude
			box_params.FilterDescendantsInstances = { character }

			local hits = Workspace:GetPartsInPart(shaftHitbox, box_params)
			for _, part in hits do
				if CollectionService:HasTag(part, "Hittable") and not part:IsDescendantOf(character) then
					print("HIT")
					local humanoidRootPart: BasePart = character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						PlayerActionController:Shove(
							part,
							humanoidRootPart.AssemblyLinearVelocity,
							humanoidRootPart.CFrame.LookVector
						)

						return
					end
				end
			end
		end
	end
end--]]

local ShoveState = {}

local DURATION = 0.8

ShoveState.__index = ShoveState

function ShoveState.New(ctx)
	local self = {
		name = "ShoveState",
		ctx = ctx,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = false,
		canSprint = true,
		shoving = false,
	}
	setmetatable(self, ShoveState)

	return self
end

function ShoveState:Enter()
	self.ctx.animator:PlayAnimationByName("Shove", Constants.FADE_TIME)
end

function ShoveState:Tick(dt: number)
	if self.timeElapsed > Constants.FADE_TIME and self.timeElapsed < (DURATION - Constants.FADE_TIME) then
		if not self.shoving then
			self.shoving = true
			task.spawn(function()
				shoveCollisionDetection(self)
			end)
		end
	end

	if self.ctx:HasPuck() or self.ctx:IsHit() then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	if self.timeElapsed > DURATION then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	self.timeElapsed += dt
end

function ShoveState:Exit()
	self.ctx.animator:StopAnimationByName("Shove", Constants.FADE_TIME)
	self.shoving = false
	local input = self.ctx.input
	input:DisableCommand("Shove")
end

function ShoveState:Destroy()
	self.name = nil
	self.ctx = nil
	self.shoving = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return ShoveState
