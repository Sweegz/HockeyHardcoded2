local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PuckController = require(script.Parent.PuckController2)

local Net = ReplicatedStorage.Net
local CollectEvent = Net:FindFirstChild("Collect") :: RemoteFunction
local DropEvent = Net:FindFirstChild("Drop") :: RemoteEvent

local LocalPlayer = Players.LocalPlayer

local CollectController = {}

function CollectController:Collect(puck: BasePart, pickup: boolean)
	local uuid = puck:GetAttribute("UUID") :: string?
	if not uuid then
		return
	end

	local serverPuck = PuckController:GetPuckViaUUID(uuid)
	if not serverPuck then
		return
	end

	local ownerId = PuckController:GetOwner(serverPuck)

	if ownerId and (ownerId == LocalPlayer.UserId) then
		return
	end

	task.spawn(function()
		CollectEvent:InvokeServer(uuid, pickup)
	end)
end

function CollectController:Drop(puck: BasePart)
	if puck then
		local uuid = puck:GetAttribute("UUID")
		DropEvent:FireServer(uuid, puck.CFrame)
	end
end

return CollectController
