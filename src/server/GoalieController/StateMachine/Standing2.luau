local Constants = require(script.Parent.Parent.Constants)

local Standing2 = {}

Standing2.__index = Standing2

function Standing2.New(ctx)
	local self = {
		name = "Standing2",
		ctx = ctx,
		timeElapsed = 0,
	}
	setmetatable(self, Standing2)

	return self
end

function Standing2:Enter()
	print("Entered Standing2")
	self.ctx.animator:PlayAnimationByName("Standing2", Constants.FADE_TIME)
end

function Standing2:Tick(dt: number)
	self.timeElapsed += dt
end

function Standing2:Exit()
	print("Exited Standing2")
	self.ctx.animator:StopAnimationByName("Standing2", Constants.FADE_TIME)
end

function Standing2:Destroy()
	self.name = nil
	self.ctx = nil
	setmetatable(self, nil)
	self = nil
end

return Standing2
