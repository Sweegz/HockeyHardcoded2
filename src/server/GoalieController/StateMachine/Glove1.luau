local Constants = require(script.Parent.Parent.Constants)

local Glove1 = {}

Glove1.__index = Glove1

function Glove1.New(ctx)
	local self = {
		name = "Glove1",
		ctx = ctx,
		timeElapsed = 0,
	}
	setmetatable(self, Glove1)

	return self
end

function Glove1:Enter()
	print("Entered Glove1")
	self.ctx.animator:PlayAnimationByName("Glove1", Constants.FADE_TIME)
end

function Glove1:Tick(dt: number)
	self.timeElapsed += dt
end

function Glove1:Exit()
	print("Exited Glove1")
	self.ctx.animator:StopAnimationByName("Glove1", Constants.FADE_TIME)
end

function Glove1:Destroy()
	self.name = nil
	self.ctx = nil
	setmetatable(self, nil)
	self = nil
end

return Glove1
