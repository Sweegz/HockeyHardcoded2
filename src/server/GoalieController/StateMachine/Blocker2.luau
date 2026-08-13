local Constants = require(script.Parent.Parent.Constants)

local Blocker2 = {}

Blocker2.__index = Blocker2

function Blocker2.New(ctx)
	local self = {
		name = "Blocker2",
		ctx = ctx,
		timeElapsed = 0,
	}
	setmetatable(self, Blocker2)

	return self
end

function Blocker2:Enter()
	print("Entered Blocker2")
	self.ctx.animator:PlayAnimationByName("Blocker2", Constants.FADE_TIME)
end

function Blocker2:Tick(dt: number)
	self.timeElapsed += dt
end

function Blocker2:Exit()
	print("Exited Blocker2")
	self.ctx.animator:StopAnimationByName("Blocker2", Constants.FADE_TIME)
end

function Blocker2:Destroy()
	self.name = nil
	self.ctx = nil
	setmetatable(self, nil)
	self = nil
end

return Blocker2
