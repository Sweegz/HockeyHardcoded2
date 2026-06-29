local StarterPlayer = game:GetService("StarterPlayer")
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

	if StaminaController:CanSprint() and input.commands.Sprint and state.canSprint then
		StaminaController:SetBurning(true)
		self.stickController.humanoid.WalkSpeed = 47
	else
		StaminaController:SetBurning(false)
		self.stickController.humanoid.WalkSpeed = 38
		input:DisableCommand("Sprint")
	end
end

function Sprint:Disable()
	self.enabled = false
	StaminaController:SetBurning(false)
end

function Sprint:Destroy() end

return Sprint
