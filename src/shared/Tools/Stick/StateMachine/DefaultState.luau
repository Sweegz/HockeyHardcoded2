local Constants = require(script.Parent.Parent.Constants)

function higherThan(source: number?, target: number?): boolean
	if source and target then
		return source > target
	elseif source then
		return true
	end

	return false
end

local DefaultState = {}

DefaultState.__index = DefaultState

function DefaultState.New(stickController)
	local self = {
		name = "DefaultState",
		stickController = stickController,
		timestamp = tick(),
		canCollect = true,
		canDropOthersPuck = true,
		canSprint = true,
		graceTime = 0,
		canCharge = true,
	}
	setmetatable(self, DefaultState)

	return self
end

function DefaultState:Enter()
	local extended = self.stickController.extended
	self.timestamp = tick()

	if extended == "Right" then
		self.stickController.animator:StopAnimationByName("Left", Constants.FADE_TIME)
		self.stickController.animator:PlayAnimationByName("Right", Constants.FADE_TIME)
	elseif extended == "Left" then
		self.stickController.animator:StopAnimationByName("Right", Constants.FADE_TIME)
		self.stickController.animator:PlayAnimationByName("Left", Constants.FADE_TIME)
	else
		self.stickController.animator:StopAnimationByName("Right", Constants.FADE_TIME)
		self.stickController.animator:StopAnimationByName("Left", Constants.FADE_TIME)
	end
end

function DefaultState:Tick(dt: number)
	local commands = self.stickController.input.commands
	local extended = self.stickController.extended
	local time = tick() - self.timestamp

	local next_state = nil

	if time < 0.2 then
		return
	end

	if (extended == "Right" and commands.GlideRight) or (extended == "Left" and commands.GlideLeft) then
		self.graceTime = 0
	else
		self.graceTime += dt
	end

	if extended ~= "Right" and higherThan(commands.GlideRight, commands.GlideLeft) then
		next_state = "Right"
	end

	if extended ~= "Left" and higherThan(commands.GlideLeft, commands.GlideRight) then
		next_state = "Left"
	end

	if extended and not (commands.GlideLeft or commands.GlideRight) and self.graceTime > Constants.GRACE_DURATION then
		next_state = "Default"
	end

	if not extended and not self.stickController.hasPuck then
		if commands.PokeCheck and commands.PokeCheck > tick() - 0.5 then
			next_state = self.stickController.state_machine.states.PokeCheckState
		end

		if commands.HighTip then
			next_state = self.stickController.state_machine.states.HighTipState
		end

		if commands.LowTip then
			next_state = self.stickController.state_machine.states.LowTipState
		end

		if commands.LyingBlock then
			next_state = self.stickController.state_machine.states.LyingBlockState
		end

		if commands.StandBlock then
			next_state = self.stickController.state_machine.states.StandBlockState
		end

		if commands.KneeBlock then
			next_state = self.stickController.state_machine.states.KneeBlockState
		end

		if commands.Shove then
			next_state = self.stickController.state_machine.states.ShoveState
		end
	end

	if not extended and commands.SlapShot then
		next_state = self.stickController.state_machine.states.SlapShotState
	end

	if not extended and commands.RaiseHand then
		next_state = self.stickController.state_machine.states.RaiseHandState
	end

	if next_state then
		if next_state == "Default" then
			self.stickController.extended = nil
			self.stickController.state_machine:ChangeState(DefaultState.New(self.stickController))
		elseif next_state == "Left" or next_state == "Right" then
			self.stickController.extended = next_state
			self.stickController.state_machine:ChangeState(DefaultState.New(self.stickController))
		else
			self.stickController.state_machine:ChangeState(next_state.New(self.stickController))
		end
	end
end

function DefaultState:Exit()
	self.name = nil
	self.timestamp = nil
	setmetatable(self, nil)
	self = nil
end

return DefaultState
