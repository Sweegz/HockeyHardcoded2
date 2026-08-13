local Constants = require(script.Parent.Parent.Constants)

local Glove0 = {}

Glove0.__index = Glove0

function Glove0.New(ctx)
	local self = {
		name = "Glove0",
		ctx = ctx,
		timeElapsed = 0,
	}
	setmetatable(self, Glove0)

	return self
end

function Glove0:Enter()
	print("Entered Glove0")
	self.ctx.animator:PlayAnimationByName("Glove0", Constants.FADE_TIME)
end

function Glove0:Tick(dt: number)
	self.timeElapsed += dt
end

function Glove0:Exit()
	print("Exited Glove0")
	self.ctx.animator:StopAnimationByName("Glove0", Constants.FADE_TIME)
end

function Glove0:Destroy()
	self.name = nil
	self.ctx = nil
	setmetatable(self, nil)
	self = nil
end

return Glove0
