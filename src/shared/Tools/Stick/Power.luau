local Power = {}

Power.__index = Power

function Power.New(stickController)
	local self = {
		stickController = stickController,
		enabled = false,
		current = 0,
		max = 100,
		rate = 100 / 1.15,
	}
	setmetatable(self, Power)

	return self
end

function Power:Enable()
	self.enabled = true
end

function Power:Tick(dt: number)
	if not self.enabled then
		return
	end

	if not self.stickController.input.commands.ChargePower then
		self.current = 0
		return
	end

	if not (self.stickController.state_machine.state.name == "DefaultState") then
		self.stickController.input.commands.ChargePower = false
		return
	end

	self.current = math.min(self.current + self.rate * dt, self.max)
	print(self.current)
end

function Power:Disable()
	self.enabled = false
end

function Power:Destroy() end

return Power
