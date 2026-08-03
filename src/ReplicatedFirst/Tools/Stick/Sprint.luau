local StarterPlayer = game:GetService("StarterPlayer")
local Constants = require(script.Parent.Constants)
local StaminaController = require(StarterPlayer.StarterPlayerScripts.Controllers.StaminaController)

local Sprint = {}

Sprint.__index = Sprint

function Sprint.New(ctx)
	local self = {
		ctx = ctx,
		enabled = false,
	}
	setmetatable(self, Sprint)

	return self
end

function Sprint:Enable()
	self.enabled = true
end

function Sprint:Tick(_dt: number)
	if not self.enabled then
		return
	end

	local input = self.ctx.input
	local state = self.ctx.stateMachine.state

	local movingForward = input.commands.MoveForward -- Add (or input.commands.MoveRight or input.commands.MoveLeft) for more flexible gameplay
	--local movingBackward = input.commands.MoveBackward

	local movementDisabled = self.ctx.movementDisabled

	if StaminaController:CanSprint() and input.commands.Sprint and state.canSprint and movingForward then
		StaminaController:SetBurning(true)
		self.ctx.humanoid.WalkSpeed = Constants.SPRINTSPEED
	else
		if not StaminaController:CanSprint() then -- Set to (movingForward and not movingBackward) for more flexible gameplay
			input:DisableCommand("Sprint")
		end

		StaminaController:SetBurning(false)
		if not movementDisabled then
			self.ctx.humanoid.WalkSpeed = Constants.WALKSPEED
		end
	end
end

function Sprint:Disable()
	self.enabled = false
	StaminaController:SetBurning(false)
end

function Sprint:Destroy()
	self:Disable()
	self.enabled = false
end

return Sprint
