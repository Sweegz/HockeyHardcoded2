local Constants = require(script.Parent.Parent.Constants)

local Blocker0 = {}

Blocker0.__index = Blocker0

function Blocker0.New(ctx)
	local self = {
		name = "Blocker0",
		ctx = ctx,
		timeElapsed = 0,
	}
	setmetatable(self, Blocker0)

	return self
end

function Blocker0:Enter()
	print("Entered Blocker0")
	self.ctx.animator:PlayAnimationByName("Blocker0", Constants.FADE_TIME)
end

function Blocker0:Tick(dt: number)
	self.timeElapsed += dt
end

function Blocker0:Exit()
	print("Exited Blocker0")
	self.ctx.animator:StopAnimationByName("Blocker0", Constants.FADE_TIME)
end

function Blocker0:Destroy()
	self.name = nil
	self.ctx = nil
	setmetatable(self, nil)
	self = nil
end

return Blocker0
