local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PuckService = require(script.Parent.PuckService)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

local HitIndex = 0
local Capacity = 13

type HitData = {
	player: Player,
	hitPlayer: Player,
	hitPart: BasePart,
	power: number,
	distanceHit: number,
	distanceFromPuck: number,
	penalty: boolean,
}

local Channel = nil

local HitRegisterService = {}

function HitRegisterService:Load()
	Channel = Synchronizer:Create("HitTracker", {
		Hits = {},
	})

	for _, player in ipairs(Players:GetPlayers()) do
		Channel:AddListener(player)
	end

	Players.PlayerAdded:Connect(function(player: Player)
		Channel:AddListener(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		Channel:RemoveListener(player)
	end)
end

function HitRegisterService:Start() end

function HitRegisterService:Add(data: HitData)
	HitIndex += 1
	Channel:InsertOnDictionary("Hits", HitIndex, data)

	if HitIndex - Capacity >= 1 then
		Channel:RemoveFromDictionary("Hits", HitIndex - Capacity)
	end
end

function HitRegisterService:Register(
	player: Player,
	hitPlayer: Player,
	hitPart: BasePart,
	power: number,
	duration: number,
	shove: boolean
)
	local hitCharacter = hitPlayer.Character
	if not hitCharacter then
		return
	end

	local humanoidRootPart = hitCharacter:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	local puck = PuckService:GetPuckInstance()
	if not puck then
		return
	end

	local puckPosition: Vector3 = puck.Position * Vector3.new(1, 0, 1)
	local hitPartPosition: Vector3 = hitPart.Position * Vector3.new(1, 0, 1)
	local distanceFromPuck: number = math.round((hitPartPosition - puckPosition).Magnitude)

	local startPosition = humanoidRootPart.Position * Vector3.new(1, 0, 1)

	task.delay(duration + 0.25, function()
		if not humanoidRootPart then
			return
		end
		local endPosition: Vector3 = humanoidRootPart.Position * Vector3.new(1, 0, 1)

		local distanceHit: number = math.round((startPosition - endPosition).Magnitude)

		local penalty = distanceHit > 40 or distanceFromPuck > 25

		local data: HitData = {
			player = player,
			hitPlayer = hitPlayer,
			hitPart = hitPart,
			power = math.round(power),
			distanceHit = distanceHit,
			distanceFromPuck = distanceFromPuck,
			penalty = penalty,
		}

		HitRegisterService:Add(data)
	end)
end

return HitRegisterService
