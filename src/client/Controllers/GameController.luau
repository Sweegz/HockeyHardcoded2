local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Loaded = false
local Callbacks = {}

local GameController = {}

function GameController:Start()
	task.spawn(function()
		while ReplicatedFirst:GetAttribute("ClientLoaded") ~= true do
			task.wait()
		end

		while ReplicatedFirst:GetAttribute("DataLoaded") ~= true do
			task.wait()
		end

		Loaded = true
		for i = 1, #Callbacks do
			local callback = Callbacks[i]
			task.spawn(callback)
		end
		table.clear(Callbacks)
	end)
end

function GameController:OnGameLoaded(callback)
	if Loaded then
		return callback()
	else
		table.insert(Callbacks, callback)
		return
	end
end

return GameController
