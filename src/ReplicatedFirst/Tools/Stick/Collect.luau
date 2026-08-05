local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

local CollectController = require(StarterPlayer.StarterPlayerScripts.Controllers.CollectController)
local MatchController = require(StarterPlayer.StarterPlayerScripts.Controllers.MatchController)
local PuckController = require(StarterPlayer.StarterPlayerScripts.Controllers.PuckController2)

local LocalPlayer = Players.LocalPlayer

local Collect = {}

Collect.__index = Collect

function Collect.New(ctx)
	local self = {
		ctx = ctx,
		enabled = false,
	}
	setmetatable(self, Collect)

	return self
end

function Collect:Enable()
	self.enabled = true
end

function Collect:Tick(_dt: number)
	if not self.enabled then
		return
	end

	if not MatchController:GetInPlay() then
		return
	end

	local character = LocalPlayer.Character
	if not character then
		return
	end

	if self.ctx:HasPuck() then
		return
	end

	local collectedPuck = nil

	for _, puck: BasePart in CollectionService:GetTagged("Collectable") do
		for _, part: BasePart in character:GetDescendants() do
			if not part:HasTag("Collect") then
				continue
			end

			local dist = (puck.Position - part.Position).Magnitude

			if dist < 2 then
				collectedPuck = puck
				break
			end
		end
	end

	local state = self.ctx.stateMachine.state

	if collectedPuck then
		if state.canCollect then
			CollectController:Collect(collectedPuck, true)
		elseif state.canDropOthersPuck then
			CollectController:Collect(collectedPuck, false)
		end
	end
end

function Collect:Disable()
	CollectController:Drop()
	self.enabled = false
end

function Collect:Destroy()
	self:Disable()
	self.enabled = false
end

return Collect
