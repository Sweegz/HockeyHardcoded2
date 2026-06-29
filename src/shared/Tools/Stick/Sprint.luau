local StarterPlayer = game:GetService("StarterPlayer")
local StaminaController = require(StarterPlayer.StarterPlayerScripts.Controllers.StaminaController)
local DRAIN_RATE = 20
local REGEN_RATE = 10

local Sprint = {}

Sprint.__index = Sprint

function Sprint.New(stickController)
	local self = {
		stickController = stickController,
		enabled = false,
		stamina = 100,
	}
	setmetatable(self, Sprint)

	return self
end

function Sprint:Enable()
	self.enabled = true
end

function Sprint:Tick(dt: number)
	if not self.enabled then
		return
	end

	local input = self.stickController.input

	local stamina = StaminaController:GetStamina()

	if stamina > 0 and input.commands.Sprint then
		StaminaController:SetStamina(stamina - DRAIN_RATE * dt)
		self.stickController.humanoid.WalkSpeed = 47
	else
		self.stickController.humanoid.WalkSpeed = 38
		input:DisableCommand("Sprint")
		if stamina < 100 then
			StaminaController:SetStamina(stamina + REGEN_RATE * dt)
		end
	end
end

function Sprint:Disable()
	self.enabled = false
end

function Sprint:Destroy() end

return Sprint
