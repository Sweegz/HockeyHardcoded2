local StarterPlayer = game:GetService("StarterPlayer")
local Constants = require(script.Parent.Constants)
local StaminaController = require(StarterPlayer.StarterPlayerScripts.Controllers.StaminaController)

local Sprint = {}

Sprint.__index = Sprint

function Sprint.New(stickController)
	local self = {
		stickController = stickController,
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

	local input = self.stickController.input
	local state = self.stickController.state_machine.state

	local movingForward = input.commands.MoveForward -- Add (or input.commands.MoveRight or input.commands.MoveLeft) for more flexible gameplay
	local movingBackward = input.commands.MoveBackward

	local movementDisabled = self.stickController.movementDisabled

	if
		StaminaController:CanSprint()
		and input.commands.Sprint
		and state.canSprint
		and (movingForward and not movingBackward)
	then
		StaminaController:SetBurning(true)
		self.stickController.humanoid.WalkSpeed = Constants.SPRINTSPEED
	else
		if not StaminaController:CanSprint() or movingBackward then -- Set to (movingForward and not movingBackward) for more flexible gameplay
			input:DisableCommand("Sprint")
		end

		StaminaController:SetBurning(false)
		if not movementDisabled then
			self.stickController.humanoid.WalkSpeed = Constants.WALKSPEED
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
