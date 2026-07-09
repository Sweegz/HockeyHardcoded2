local Constants = require(script.Parent.Parent.Constants)

local PokeCheckState = {}

PokeCheckState.__index = PokeCheckState

function PokeCheckState.New(ctx)
	local self = {
		name = "PokeCheckState",
		ctx = ctx,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = true,
		canSprint = true,
	}
	setmetatable(self, PokeCheckState)

	return self
end

function PokeCheckState:Enter()
	self.ctx.animator:PlayAnimationByName("PokeCheck", Constants.FADE_TIME)
end

function PokeCheckState:Tick(dt: number)
	if self.ctx:HasPuck() or self.ctx:IsHit() then
		self.ctx.state_machine:ChangeState(self.ctx.state_machine.states.DefaultState.New(self.ctx))
		return
	end

	if self.timeElapsed > 1 then
		self.ctx.state_machine:ChangeState(self.ctx.state_machine.states.DefaultState.New(self.ctx))
		return
	end

	self.timeElapsed += dt
end

function PokeCheckState:Exit()
	self.ctx.animator:StopAnimationByName("PokeCheck", Constants.FADE_TIME)
	local input = self.ctx.input
	input:DisableCommand("PokeCheck")
end

function PokeCheckState:Destroy()
	self.name = nil
	self.ctx = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	setmetatable(self, nil)
	self = nil
end

return PokeCheckState
