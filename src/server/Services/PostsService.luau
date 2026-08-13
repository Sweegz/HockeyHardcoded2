local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local random = Random.new(tick())

local PostsService = {}

local PostSounds = SoundService:WaitForChild("SFX"):WaitForChild("Posts") :: Folder

local function get_random_sound(folder: Folder): Sound?
	local sounds = folder:GetChildren()
	if #sounds > 0 then
		local random_index = random:NextInteger(1, #sounds)
		local sound = sounds[random_index]
		if sound:IsA("Sound") then
			return sound
		end
	end
	return nil
end

local function setupPost(part: BasePart)
	part.Touched:Connect(function(hit: BasePart)
		if CollectionService:HasTag(hit, "Puck") then
			PostsService:PlaySound(part)
		end
	end)
end

function PostsService:PlaySound(part: BasePart)
	local postSound = get_random_sound(PostSounds)

	if postSound then
		local clone = postSound:Clone()
		clone.Parent = part
		clone:Play()
		Debris:AddItem(clone, 2)
	end
end

for _, part: BasePart in CollectionService:GetTagged("Post") do
	setupPost(part)
end

CollectionService:GetInstanceAddedSignal("Post"):Connect(function(instance: Instance)
	setupPost(instance :: BasePart)
end)

return PostsService
