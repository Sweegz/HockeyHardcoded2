local StarterPlayer = game:GetService("StarterPlayer")
local CollectController = require(StarterPlayer.StarterPlayerScripts.Controllers.CollectController)
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

function DefaultState.New(ctx)
	local self = {
		name = "DefaultState",
		ctx = ctx,
		timeElapsed = 0,
		canCollect = false,
		canDropOthersPuck = true,
		canSprint = true,
		graceTime = 0,
		canCharge = true,
	}

	setmetatable(self, DefaultState)

	return self
end

function DefaultState:Enter()
	local extended = self.ctx.extended
	local prev = self.ctx.stateMachine.previous_state

	-- If previous state was default or could collect then no need to wait for transition to finish
	if prev and (prev.canCollect or prev.name == "DefaultState") then
		self.canCollect = true
	else
		self.canCollect = false
	end

	if extended == "Right" then
		self.ctx.animator:PlayAnimationByName("Right", Constants.FADE_TIME)
		self.ctx.animator:StopAnimationByName("Left", Constants.FADE_TIME)
		self.ctx.animator:StopAnimationByName("Idle", Constants.FADE_TIME)
	elseif extended == "Left" then
		self.ctx.animator:PlayAnimationByName("Left", Constants.FADE_TIME)
		self.ctx.animator:StopAnimationByName("Right", Constants.FADE_TIME)
		self.ctx.animator:StopAnimationByName("Idle", Constants.FADE_TIME)
	else
		self.ctx.animator:PlayAnimationByName("Idle", Constants.FADE_TIME)
		self.ctx.animator:StopAnimationByName("Left", Constants.FADE_TIME)
		self.ctx.animator:StopAnimationByName("Right", Constants.FADE_TIME)
	end
end

function DefaultState:TransitionFinished()
	return self.timeElapsed > 0.2
end

function DefaultState:Tick(dt: number)
	local commands = self.ctx.input.commands
	local extended = self.ctx.extended
	local hasPuck = self.ctx.hasPuck
	local input = self.ctx.input
	local power = self.ctx.power

	local next_state = nil

	if self:TransitionFinished() and not self.ctx:IsHit() then
		self.canCollect = true

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

		if
			extended
			and not (commands.GlideLeft or commands.GlideRight)
			and self.graceTime > Constants.GRACE_DURATION
		then
			next_state = "Default"
		end

		if not extended and not hasPuck and not power:IsCharging() then
			if commands.PokeCheck and commands.PokeCheck > time() - 0.5 then
				next_state = self.ctx.stateMachine.states.PokeCheckState
			end

			if commands.HighTip then
				next_state = self.ctx.stateMachine.states.HighTipState
			end

			if commands.LowTip then
				next_state = self.ctx.stateMachine.states.LowTipState
			end

			if commands.LyingBlock then
				next_state = self.ctx.stateMachine.states.LyingBlockState
			end

			if commands.StandBlock then
				next_state = self.ctx.stateMachine.states.StandBlockState
			end

			if commands.KneeBlock then
				next_state = self.ctx.stateMachine.states.KneeBlockState
			end

			if commands.Shove then
				next_state = self.ctx.stateMachine.states.ShoveState
			end

			if commands.SlapShot then
				next_state = self.ctx.stateMachine.states.SlapShotState
			end
		end

		-- Make sure this only drops the localplayers puck
		if hasPuck and commands.DropPuck then
			input:DisableCommand("DropPuck")
			input:DisableCommand("SlapShot")
			CollectController:Drop()
		end

		if not extended and commands.RaiseHand then
			next_state = self.ctx.stateMachine.states.RaiseHandState
		end

		if next_state then
			if next_state == "Default" then
				self.ctx.extended = nil
				self.ctx.stateMachine:ChangeState(DefaultState.New(self.ctx))
			elseif next_state == "Left" or next_state == "Right" then
				self.ctx.extended = next_state
				self.ctx.stateMachine:ChangeState(DefaultState.New(self.ctx))
			else
				self.ctx.stateMachine:ChangeState(next_state.New(self.ctx))
			end
			return
		end
	end

	self.timeElapsed += dt
end

function DefaultState:Exit() end

function DefaultState:Destroy()
	self.name = nil
	self.ctx = nil
	self.timeElapsed = nil
	self.canCollect = nil
	self.canDropOthersPuck = nil
	self.canSprint = nil
	self.graceTime = nil
	self.canCharge = nil
	setmetatable(self, nil)
	self = nil
end

return DefaultState
