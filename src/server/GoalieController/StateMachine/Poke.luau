local Constants = require(script.Parent.Parent.Constants)

local Poke = {}

Poke.__index = Poke

function Poke.New(ctx)
	local self = {
		name = "Poke",
		ctx = ctx,
		timeElapsed = 0,
	}
	setmetatable(self, Poke)

	return self
end

function Poke:Enter()
	print("Entered Poke")
	self.ctx.animator:PlayAnimationByName("Poke", Constants.FADE_TIME)
end

function Poke:Tick(dt: number)
	self.timeElapsed += dt
end

function Poke:Exit()
	print("Exited Poke")
	self.ctx.animator:StopAnimationByName("Poke", Constants.FADE_TIME)
end

function Poke:Destroy()
	self.name = nil
	self.ctx = nil
	setmetatable(self, nil)
	self = nil
end

return Poke
