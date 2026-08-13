local Constants = require(script.Parent.Parent.Constants)

local Blocker1 = {}

Blocker1.__index = Blocker1

function Blocker1.New(ctx)
	local self = {
		name = "Blocker1",
		ctx = ctx,
		timeElapsed = 0,
	}
	setmetatable(self, Blocker1)

	return self
end

function Blocker1:Enter()
	print("Entered Blocker1")
	self.ctx.animator:PlayAnimationByName("Blocker1", Constants.FADE_TIME)
end

function Blocker1:Tick(dt: number)
	self.timeElapsed += dt
end

function Blocker1:Exit()
	print("Exited Blocker1")
	self.ctx.animator:StopAnimationByName("Blocker1", Constants.FADE_TIME)
end

function Blocker1:Destroy()
	self.name = nil
	self.ctx = nil
	setmetatable(self, nil)
	self = nil
end

return Blocker1
