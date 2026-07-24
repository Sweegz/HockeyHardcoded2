--# selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local vide = require(ReplicatedStorage.Packages.vide)

local Container = require(script.Container)

local create = vide.create



local function HitTracker()
	local Enabled = vide.source(false)

	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.H then
			Enabled(not Enabled())
		end
	end)

	return create("ScreenGui")({
		Name = "HitTracker",

		vide.show(Enabled,  function() 
			return Container {
				Enabled = Enabled
			}
		end),
	})
end

return HitTracker
