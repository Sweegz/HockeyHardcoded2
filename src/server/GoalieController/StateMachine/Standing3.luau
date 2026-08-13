local Constants = require(script.Parent.Parent.Constants)

local Standing3 = {}

Standing3.__index = Standing3

function Standing3.New(ctx)
	local self = {
		name = "Standing3",
		ctx = ctx,
		timeElapsed = 0,
	}
	setmetatable(self, Standing3)

	return self
end

function Standing3:Enter()
	print("Entered Standing3")
	self.ctx.animator:PlayAnimationByName("Standing3", Constants.FADE_TIME)
end

function Standing3:Tick(dt: number)
	self.timeElapsed += dt
end

function Standing3:Exit()
	print("Exited Standing3")
	self.ctx.animator:StopAnimationByName("Standing3", Constants.FADE_TIME)
end

function Standing3:Destroy()
	self.name = nil
	self.ctx = nil
	setmetatable(self, nil)
	self = nil
end

return Standing3
