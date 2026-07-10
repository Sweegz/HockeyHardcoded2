local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local PlayerActionController = require(StarterPlayer.StarterPlayerScripts.Controllers.PlayerActionController)
local GetValidMouseHit = require(ReplicatedStorage.Shared.Utility.GetValidMouseHit)
local Constants = require(script.Parent.Parent.Constants)

local LocalPlayer = Players.LocalPlayer

local function makeCheck(hitPart: BasePart, movementDirection: Vector3, power: number)
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

	--[[if hitPlayer.Team == LocalPlayer.Team then
		return
	end--]]

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = hitPartParent:GetDescendants()
	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position,
		(hitPart.Position - humanoidRootPart.Position).Unit * 50,
		raycastParams
	)

	if raycastResult and raycastResult.Instance.Parent.ClassName ~= "Accessory" then
		hitPart = raycastResult.Instance
	end

	PlayerActionController:Check(hitPlayer, hitPart, movementDirection, power * 2)
end

local function checkCollisionDetection(self)
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

	local movementDirection = (self.targetPosition - humanoidRootPart.Position).Unit

	while self.checking do
		RunService.RenderStepped:Wait()
		if not humanoidRootPart then
			return
		end

		local characterMagnitudesList = {}
		for _, nearbyCharacter in pairs(listOfCharacters) do
			if
				nearbyCharacter:FindFirstChild("HumanoidRootPart")
				and nearbyCharacter:FindFirstChild("Right Arm")
				and nearbyCharacter:FindFirstChild("Left Arm")
				and nearbyCharacter:FindFirstChild("Stick")
				and nearbyCharacter.Stick:FindFirstChild("ShaftHitbox")
			then
				local unitVectorToCharacter = (nearbyCharacter.HumanoidRootPart.Position - humanoidRootPart.Position).Unit

				local angleToCharacter = math.deg((math.acos((movementDirection.Unit:Dot(unitVectorToCharacter)))))

				if (angleToCharacter < 95 or self.power < 25) and (angleToCharacter < 120 or self.power >= 25) then
					local magnitudeForwardOffset = (humanoidRootPart.Position - (
						nearbyCharacter.HumanoidRootPart.CFrame * CFrame.new(0, 0, -0.5)
					).Position).Magnitude
					local magnitudeBackwardOffset = (humanoidRootPart.Position - (
						nearbyCharacter.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0.5)
					).Position).Magnitude
					local magnitudeLeftOffset = (humanoidRootPart.Position - (
						nearbyCharacter.HumanoidRootPart.CFrame * CFrame.new(-1, 0, 0)
					).Position).Magnitude
					local magnitudeRightOffset = (humanoidRootPart.Position - (
						nearbyCharacter.HumanoidRootPart.CFrame * CFrame.new(1, 0, 0)
					).Position).Magnitude
					local magnitudeRightArm = (humanoidRootPart.Position - nearbyCharacter["Right Arm"].Position).Magnitude
					local magnitudeRightArmDown = (humanoidRootPart.Position - (
						nearbyCharacter["Right Arm"].CFrame * CFrame.new(0, -1, 0)
					).Position).Magnitude
					local magnitudeLeftArm = (humanoidRootPart.Position - nearbyCharacter["Left Arm"].Position).Magnitude
					local magnitudeLeftArmDown = (humanoidRootPart.Position - (
						nearbyCharacter["Left Arm"].CFrame * CFrame.new(0, -1, 0)
					).Position).Magnitude
					local magnitudeStickShaft = (humanoidRootPart.Position - nearbyCharacter.Stick.Shaft.Position).Magnitude
					local magnitudeStickShaftUp = (humanoidRootPart.Position - (
						nearbyCharacter.Stick.Shaft.CFrame * CFrame.new(0, 2.5, 0)
					).Position).Magnitude
					local magnitudeStickShaftDown = (humanoidRootPart.Position - (
						nearbyCharacter.Stick.Shaft.CFrame * CFrame.new(0, -2.5, 0)
					).Position).Magnitude
					if
						magnitudeForwardOffset <= 20
						and magnitudeBackwardOffset <= 20
						and magnitudeLeftOffset <= 20
						and magnitudeRightOffset <= 20
						and magnitudeRightArm <= 20
						and magnitudeRightArmDown <= 20
						and magnitudeLeftArm <= 20
						and magnitudeLeftArmDown <= 20
						and magnitudeStickShaft <= 20
						and magnitudeStickShaftUp <= 20
						and magnitudeStickShaftDown <= 20
					then
						table.insert(characterMagnitudesList, {
							magnitudeForwardOffset,
							nearbyCharacter,
							4,
						})
						table.insert(characterMagnitudesList, {
							magnitudeBackwardOffset,
							nearbyCharacter,
							4,
						})
						table.insert(characterMagnitudesList, {
							magnitudeLeftOffset,
							nearbyCharacter,
							4,
						})
						table.insert(characterMagnitudesList, {
							magnitudeRightOffset,
							nearbyCharacter,
							4,
						})
						table.insert(characterMagnitudesList, {
							magnitudeRightArm,
							nearbyCharacter,
							4,
						})
						table.insert(characterMagnitudesList, {
							magnitudeRightArmDown,
							nearbyCharacter,
							4,
						})
						table.insert(characterMagnitudesList, {
							magnitudeLeftArm,
							nearbyCharacter,
							4,
						})
						table.insert(characterMagnitudesList, {
							magnitudeLeftArmDown,
							nearbyCharacter,
							4,
						})
						table.insert(characterMagnitudesList, {
							magnitudeStickShaft,
							nearbyCharacter,
							4,
						})
						table.insert(characterMagnitudesList, {
							magnitudeStickShaftUp,
							nearbyCharacter,
							4,
						})
						table.insert(characterMagnitudesList, {
							magnitudeStickShaftDown,
							nearbyCharacter,
							4,
						})
					end
				end
			end
		end

		local closestBasePart = nil

		if #characterMagnitudesList > 0 then
			table.sort(characterMagnitudesList, function(sortValueA, sortValueB) --[[ Line: 588 ]]
				return sortValueA[1] < sortValueB[1]
			end)
			if characterMagnitudesList[1][1] <= characterMagnitudesList[1][3] then
				local spawnLocationContainer = characterMagnitudesList[1][2]
				local closestMagnitude = nil
				for _, childPart in pairs(spawnLocationContainer:GetChildren()) do
					if childPart:IsA("BasePart") then
						local magnitudeToPart = (humanoidRootPart.Position - childPart.Position).Magnitude
						if
							not closestMagnitude and magnitudeToPart <= 10
							or closestMagnitude and magnitudeToPart < closestMagnitude
						then
							closestMagnitude = magnitudeToPart
							closestBasePart = childPart
						end
					end
				end
				if closestBasePart then
					makeCheck(closestBasePart, movementDirection, self.power)
					return
				end
			end
		end
	end
end

local CheckState = {}

CheckState.__index = CheckState

function CheckState.New(ctx)
	local self = {
		name = "CheckState",
		ctx = ctx,
		movementSpeedMultiplier = 0,
		timeElapsed = 0,
		canCollect = true,
		canDropOthersPuck = true,
		canSprint = true,
		checking = false,
		targetPosition = nil,
	}
	setmetatable(self, CheckState)

	return self
end

local FADE_TIME = 0.2

function CheckState:Enter()
	self.ctx.animator:PlayAnimationByName("Check", FADE_TIME)

	self.ctx.animator:StopAnimationByName("Idle", FADE_TIME)
	self.ctx.animator:StopAnimationByName("Left", FADE_TIME)
	self.ctx.animator:StopAnimationByName("Right", FADE_TIME)

	local input = self.ctx.input
	input:DisableCommand("ChargePower")

	self.power = self.ctx.power.chargeValue / 2

	local humanoid = self.ctx.humanoid
	local momentum = self.ctx.momentum
	self.ctx.extended = false

	--[[ Optional (changes stick gameplay)
	local input = self.ctx.input
	input:DisableCommand("GlideRight")
	input:DisableCommand("GlideLeft")
	--]]

	local character = humanoid.Parent
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	self.targetPosition = GetValidMouseHit()

	local hrp_speed = humanoidRootPart.AssemblyLinearVelocity.Magnitude
	if humanoid.WalkSpeed < hrp_speed then
		hrp_speed = humanoid.WalkSpeed
	end

	momentum:SetMoving(true)

	local humanoidRootPartSpeed = humanoidRootPart.AssemblyLinearVelocity.Magnitude
	if humanoid.WalkSpeed < humanoidRootPartSpeed then
		humanoidRootPartSpeed = humanoid.WalkSpeed
	end

	if humanoid.WalkSpeed >= 32 and self.power >= 18.4 then
		if self.power <= 25 then
			if humanoidRootPartSpeed < self.power * 1.335 then
				local Velocity = (self.targetPosition - humanoidRootPart.Position).Unit
					* (self.power / 50 * 47 * 1.40175)
				momentum:SetBodyVelocity(Velocity)
				self.movementSpeedMultiplier = self.power * 1.40175
			else
				local Velocity = (self.targetPosition - humanoidRootPart.Position).Unit * humanoidRootPartSpeed
				momentum:SetBodyVelocity(Velocity)
				self.movementSpeedMultiplier = humanoidRootPartSpeed
			end
		elseif humanoidRootPartSpeed < self.power / 50 * 47 * 1.035 then
			local Velocity = (self.targetPosition - humanoidRootPart.Position).Unit * (self.power / 50 * 47 * 1.086)
			momentum:SetBodyVelocity(Velocity)
			self.movementSpeedMultiplier = self.power / 50 * 47 * 1.086
		else
			local Velocity = (self.targetPosition - humanoidRootPart.Position).Unit * humanoidRootPartSpeed
			momentum:SetBodyVelocity(Velocity)
			self.movementSpeedMultiplier = humanoidRootPartSpeed
		end
		if self.power >= 18 then
			if humanoidRootPartSpeed < self.power / 50 * 47 * 0.925 then
				local Velocity = (self.targetPosition - humanoidRootPart.Position).Unit * (self.power / 50 * 47 * 0.925)
				momentum:SetBodyVelocity(Velocity)
				self.movementSpeedMultiplier = self.power / 50 * 47 * 0.925
			else
				local Velocity = (self.targetPosition - humanoidRootPart.Position).Unit * humanoidRootPartSpeed
				momentum:SetBodyVelocity(Velocity)
				self.movementSpeedMultiplier = humanoidRootPartSpeed
			end
		elseif self.power > 35 then
			if humanoidRootPartSpeed < self.power / 50 * 47 * 1.135 then
				local Velocity = (self.targetPosition - humanoidRootPart.Position).Unit * (self.power / 50 * 47 * 1.2)
				momentum:SetBodyVelocity(Velocity)
				self.movementSpeedMultiplier = self.power / 50 * 47 * 1.2
			else
				local Velocity = (self.targetPosition - humanoidRootPart.Position).Unit * humanoidRootPartSpeed
				momentum:SetBodyVelocity(Velocity)
				self.movementSpeedMultiplier = humanoidRootPartSpeed
			end
		end
	end
end

function CheckState:Tick(dt: number)
	local humanoid = self.ctx.humanoid
	local momentum = self.ctx.momentum
	local moveDirection = humanoid.MoveDirection

	if self.timeElapsed > Constants.FADE_TIME and self.timeElapsed < 0.5 then
		if not self.checking then
			self.checking = true
			task.spawn(function()
				checkCollisionDetection(self)
			end)
		end
	end

	if self.timeElapsed < 0.5 then
		if humanoid.MoveDirection.Magnitude > 0.1 then
			local velocity = momentum:GetBodyVelocity()
			velocity = velocity:Lerp(moveDirection * self.movementSpeedMultiplier, 0.8 * dt)
			momentum:SetBodyVelocity(velocity)
		end
	end

	if self.timeElapsed > 0.5 then
		momentum:SetMoving(false)
	end

	if self.timeElapsed > 0.75 then
		self.ctx.stateMachine:ChangeState(self.ctx.stateMachine.states.DefaultState.New(self.ctx))
		return
	end

	self.timeElapsed += dt
end

function CheckState:Exit()
	self.ctx.animator:StopAnimationByName("Check", Constants.FADE_TIME)
	self.checking = false
end

function CheckState:Destroy()
	self.name = nil
	self.ctx = nil
	self.checking = nil
	self.movementSpeedMultiplier = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return CheckState
