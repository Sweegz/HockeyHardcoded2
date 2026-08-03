local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
local PuckService = require(script.Parent.PuckService)

local OutOfBoundsService = {
	OnOutOfBounds = Signal.new(),
}

local function onTouch(hit: BasePart)
	if hit == PuckService:GetPuckInstance() then
		OutOfBoundsService.OnOutOfBounds:Fire(PuckService.lastShotPosition)
	end
end

function OutOfBoundsService:Load()
	for _, part: BasePart in CollectionService:GetTagged("Bounds") do
		part.Touched:Connect(onTouch)
	end
end

function OutOfBoundsService:Start() end

return OutOfBoundsService
