local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PuckController = require(script.Parent.PuckController)

local GetValidMouseHit = require(ReplicatedStorage.Shared.Utility.GetValidMouseHit)

local Net = ReplicatedStorage.Net
local ShootEvent = Net:FindFirstChild("Shoot") :: RemoteEvent
local SlapshotEvent = Net:FindFirstChild("Slapshot") :: RemoteEvent
local ShoveEvent = Net:FindFirstChild("Shove") :: RemoteEvent
local CheckEvent = Net:FindFirstChild("Check") :: RemoteEvent
local StateEvent = Net:FindFirstChild("State") :: RemoteEvent

local Player = Players.LocalPlayer

local PlayerActionController = {}

function PlayerActionController:Shoot(power: number, flags: {})
	local mouseHit = GetValidMouseHit() * Vector3.new(1, 0, 1)

	local puck = PuckController:GetInstance()
	if not puck then
		return
	end

	local character = Player.Character
	if not character then
		return
	end

	local front = character:FindFirstChild("Front", true)
	if not front then
		return
	end

	local puckPosition = front.Position

	ShootEvent:FireServer(power, mouseHit, puckPosition, flags)
end

function PlayerActionController:Slapshot(power: number, flags: {})
	local mouseHit = GetValidMouseHit()

	local puck = PuckController:GetInstance()
	if not puck then
		return
	end

	local puckPosition = puck.Position

	SlapshotEvent:FireServer(power, mouseHit, puckPosition, flags)
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
