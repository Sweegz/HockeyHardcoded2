local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local OutOfBoundsService = {
	OnOutOfBounds = Signal.new(),
}

local function onTouch(hit: BasePart)
	if CollectionService:HasTag(hit, "MainPuck") then
		OutOfBoundsService.OnOutOfBounds:Fire(hit)
	end
end

function OutOfBoundsService:Load()
	for _, part: BasePart in CollectionService:GetTagged("Bounds") do
		part.Touched:Connect(onTouch)
	end
end

function OutOfBoundsService:Start() end

return OutOfBoundsService
