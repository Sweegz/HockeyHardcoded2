local Constants = require(script.Parent.Parent.Constants)

local Glove2 = {}

Glove2.__index = Glove2

function Glove2.New(ctx)
	local self = {
		name = "Glove2",
		ctx = ctx,
		timeElapsed = 0,
	}
	setmetatable(self, Glove2)

	return self
end

function Glove2:Enter()
	print("Entered Glove2")
	self.ctx.animator:PlayAnimationByName("Glove2", Constants.FADE_TIME)
end

function Glove2:Tick(dt: number)
	self.timeElapsed += dt
end

function Glove2:Exit()
	print("Exited Glove2")
	self.ctx.animator:StopAnimationByName("Glove2", Constants.FADE_TIME)
end

function Glove2:Destroy()
	self.name = nil
	self.ctx = nil
	setmetatable(self, nil)
	self = nil
end

return Glove2
