local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

local MatchController = require(StarterPlayer.StarterPlayerScripts.Controllers.MatchController)
local PuckController = require(StarterPlayer.StarterPlayerScripts.Controllers.PuckController)

local LocalPlayer = Players.LocalPlayer

local Collect = {}

Collect.__index = Collect

function Collect.New(stickController)
	local self = {
		stickController = stickController,
		enabled = false,
	}
	setmetatable(self, Collect)

	return self
end

function Collect:Enable()
	self.enabled = true
end

function Collect:Tick(dt: number)
	if not self.enabled then
		return
	end

	if not MatchController:GetInPlay() then
		return
	end

	--[[if PuckController:GetCooldown() > 0 then
		return
	end--]]

	if PuckController:GetOwner() == LocalPlayer then
		return
	end

	local puck_instance = PuckController:GetInstance()

	if not puck_instance or not puck_instance:IsA("BasePart") then
		return
	end

	local character = LocalPlayer.Character
	if not character then
		return
	end

	for _, part in character:GetDescendants() do
		if not part:HasTag("Collect") then
			continue
		end

		local dist = (puck_instance.Position - part.Position).Magnitude

		if dist < 2 then
			PuckController:Collect()
			break
		end
	end
end

function Collect:Disable()
	PuckController:Drop()
	self.enabled = false
end

return Collect
