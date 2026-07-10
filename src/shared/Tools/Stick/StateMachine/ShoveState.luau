local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local PlayerActionController = require(StarterPlayer.StarterPlayerScripts.Controllers.PlayerActionController)
local Constants = require(script.Parent.Parent.Constants)

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
end

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
				shove(self)
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
