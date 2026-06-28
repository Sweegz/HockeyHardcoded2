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

	if self.stamina > 0 and input.commands.Sprint then
		self.stamina -= DRAIN_RATE * dt
		self.stickController.humanoid.WalkSpeed = 47
	else
		self.stickController.humanoid.WalkSpeed = 38
		input:DisableCommand("Sprint")
	end
end

function Sprint:Disable()
	self.enabled = false
end

return Sprint
