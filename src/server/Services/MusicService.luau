local SoundService = game:GetService("SoundService")

local MusicService = {
	Track = nil :: Sound?,
}

local Music = SoundService:WaitForChild("Music") :: Folder

local function GetRandomTrack(): Sound?
	local size = #Music:GetChildren()
	local track = nil

	local tries = 0

	while not track and tries <= 10 do
		local rng = math.random(1, size)
		local temp = Music:GetChildren()[rng]
		if temp:IsA("Sound") and temp ~= MusicService.Track then
			track = temp
		end
		tries += 1
	end

	return track
end

function MusicService:Play()
	MusicService:Stop()
	local track = GetRandomTrack()
	if track then
		track:Play()
	end
	MusicService.Track = track
end

function MusicService:Stop()
	local track = MusicService.Track
	if track then
		track:Stop()
	end
end

return MusicService
