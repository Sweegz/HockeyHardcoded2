local Constants = require(script.Parent.Parent.Constants)

local ButterflyState = {}

ButterflyState.__index = ButterflyState

function ButterflyState.New(ctx)
	local self = {
		name = "ButterflyState",
		ctx = ctx,
		timeElapsed = 0,
	}
	setmetatable(self, ButterflyState)

	return self
end

function ButterflyState:Enter()
	print("Entered butterfly")
	self.ctx.animator:PlayAnimationByName("Butterfly", Constants.FADE_TIME)
end

function ButterflyState:Tick(dt: number)
	self.timeElapsed += dt
end

function ButterflyState:Exit()
	print("Exited butterfly")
	self.ctx.animator:StopAnimationByName("Butterfly", Constants.FADE_TIME)
end

function ButterflyState:Destroy()
	self.name = nil
	self.ctx = nil
	setmetatable(self, nil)
	self = nil
end

return ButterflyState
