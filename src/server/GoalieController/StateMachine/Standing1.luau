local Constants = require(script.Parent.Parent.Constants)

local Standing1 = {}

Standing1.__index = Standing1

function Standing1.New(ctx)
	local self = {
		name = "Standing1",
		ctx = ctx,
		timeElapsed = 0,
	}
	setmetatable(self, Standing1)

	return self
end

function Standing1:Enter()
	print("Entered Standing1")
	self.ctx.animator:PlayAnimationByName("Standing1", Constants.FADE_TIME)
end

function Standing1:Tick(dt: number)
	self.timeElapsed += dt
end

function Standing1:Exit()
	print("Exited Standing1")
	self.ctx.animator:StopAnimationByName("Standing1", Constants.FADE_TIME)
end

function Standing1:Destroy()
	self.name = nil
	self.ctx = nil
	setmetatable(self, nil)
	self = nil
end

return Standing1
