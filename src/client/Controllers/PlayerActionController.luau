local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PuckController = require(script.Parent.PuckController)

local GetValidMouseHit = require(ReplicatedStorage.Shared.Utility.GetValidMouseHit)

local Net = ReplicatedStorage.Net
local ShootEvent = Net:FindFirstChild("Shoot") :: RemoteEvent

local PlayerActionController = {}

function PlayerActionController:Shoot(power: number, flags: {})
	local mouseHit = GetValidMouseHit() * Vector3.new(1, 0, 1)

	local puck = PuckController:GetInstance()
	if not puck then
		return
	end

	local puckPosition = puck.Position

	ShootEvent:FireServer(power, mouseHit, puckPosition, flags)
end

return PlayerActionController
