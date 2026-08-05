local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GetValidMouseHit = require(ReplicatedStorage.Shared.Utility.GetValidMouseHit)

local Net = ReplicatedStorage.Net
local ShootEvent = Net:FindFirstChild("Shoot") :: RemoteEvent
local SlapshotEvent = Net:FindFirstChild("Slapshot") :: RemoteEvent
local ShoveEvent = Net:FindFirstChild("Shove") :: RemoteEvent
local CheckEvent = Net:FindFirstChild("Check") :: RemoteEvent
local StateEvent = Net:FindFirstChild("State") :: RemoteEvent

local Player = Players.LocalPlayer

local PlayerActionController = {}

function PlayerActionController:Shoot(puck: BasePart, power: number, flags: {})
	if not puck then
		return
	end
	local mouseHit = GetValidMouseHit() * Vector3.new(1, 0, 1)

	local character = Player.Character
	if not character then
		return
	end

	local front = character:FindFirstChild("Front", true)
	if not front then
		return
	end

	local puckPosition = front.Position

	if not flags.fake then
		puck:SetAttribute("Shot", puckPosition)
	end

	local uuid = puck:GetAttribute("UUID")

	ShootEvent:FireServer(uuid, power, mouseHit, puckPosition, flags)
end

function PlayerActionController:Slapshot(puck: BasePart, power: number, flags: {})
	if not puck then
		return
	end
	local mouseHit = GetValidMouseHit()

	local puckPosition = puck.Position

	local uuid = puck:GetAttribute("UUID")

	SlapshotEvent:FireServer(uuid, power, mouseHit, puckPosition, flags)
end

function PlayerActionController:Shove(hitPlayer: Player, hitPart: BasePart, lookDirection: Vector3)
	ShoveEvent:FireServer(hitPlayer, hitPart, lookDirection)
end

function PlayerActionController:Check(hitPlayer: Player, hitPart, movementDirection: Vector3, power: number)
	CheckEvent:FireServer(hitPlayer, hitPart, movementDirection, power)
end

function PlayerActionController:SendState(stateName: string)
	local previousState = Player:GetAttribute("ClientCurrentState")
	Player:SetAttribute("ClientCurrentState", stateName)
	Player:SetAttribute("ClientPreviousState", previousState)
	StateEvent:FireServer(stateName)
end

return PlayerActionController
