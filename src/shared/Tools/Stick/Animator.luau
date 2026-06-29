local Animator = {}
Animator.__index = Animator

function Animator.New(stickController)
	local self = {
		stickController = stickController,
		enabled = false,
		loadedAnimations = false,
		animationTracks = {},
	}
	setmetatable(self, Animator)

	return self
end

function Animator:PlayAnimationByName(animationName: string, fadeTime: number?)
	if not self.animationTracks[animationName] then
		return
	end
	self.animationTracks[animationName]:Play(fadeTime)
end

function Animator:StopAnimationByName(animationName: string, fadeTime: number?)
	if not self.animationTracks[animationName] then
		return
	end
	self.animationTracks[animationName]:Stop(fadeTime)
end

function Animator:AdjustSpeedByName(animationName: string, speed: number)
	if not self.animationTracks[animationName] then
		return
	end
	self.animationTracks[animationName]:AdjustSpeed(speed)
end

function Animator:AdjustWeightByName(animationName: string, weight: number, fadeTime: number)
	if not self.animationTracks[animationName] then
		return
	end
	self.animationTracks[animationName]:AdjustWeight(weight, fadeTime)
end

function Animator:StopCurrentAnimation(fadeTime: number?)
	for _, animationTrack in self.animationTracks do
		animationTrack:Stop(fadeTime)
	end
end

function Animator:GetAnimationTrack(animationName: string)
	return self.animationTracks[animationName]
end

function Animator:LoadAnimations()
	if self.loadedAnimations then
		return
	end

	self.loadedAnimations = true

	local animationsFolder = self.stickController.tool.Animations
	-- This should only be called when the blaster has been equipped
	local humanoid = self.stickController.tool.Parent:FindFirstChildOfClass("Humanoid")
	assert(humanoid, "Tool is not equipped")
	local animator = humanoid.Animator

	local animationTracks = {}
	for _, animation in animationsFolder:GetChildren() do
		local animationTrack = animator:LoadAnimation(animation)
		animationTracks[animation.Name] = animationTrack

		-- Unlike the ViewModelController, we won't tie any sounds to these animations.
		-- Since we're playing these animations from the client and relying on default replication behavior,
		-- any sounds we played here would overlap the view model sounds and wouldn't replicate.
	end

	self.animationTracks = animationTracks
end

function Animator:Enable()
	if self.enabled then
		return
	end
	self.enabled = true

	-- Load animations if they haven't been loaded already
	if not self.loadedAnimations then
		self:LoadAnimations()
	end

	self.animationTracks.Idle:Play(0)
end

function Animator:Disable()
	if not self.enabled then
		return
	end
	self.enabled = false

	for _, animation in self.animationTracks do
		animation:Stop()
	end
end

function Animator:Destroy()
	self:Disable()
	-- Clear the animationTracks table so we don't keep any references around.
	-- This makes sure the animation tracks get garbage collected correctly and don't cause a memory leak.
	table.clear(self.animationTracks)
end

return Animator
