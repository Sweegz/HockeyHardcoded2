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

function Collect:Collect()
	print("Collect!")
end

function Collect:Drop()
	if PuckController:GetOwner() ~= LocalPlayer then
		return
	end

	print("Drop")
end

function Collect:Tick(dt: number)
	if not self.enabled then
		return
	end

	if not MatchController:GetInPlay() then
		return
	end

	if PuckController:GetCooldown() > 0 then
		return
	end

	if PuckController:GetOwner() == LocalPlayer then
		return
	end

	local puck_instance = PuckController:GetInstance()

	if not puck_instance or not puck_instance:IsA("BasePart") then
		return
	end

	for _, part in CollectionService:GetTagged("Collect") do
		local dist = (puck_instance.Position - part.Position).Magnitude

		if dist < 2 then
			self:Collect()
		end
	end
end

function Collect:Disable()
	self:Drop()
	self.enabled = false
end

return Collect
