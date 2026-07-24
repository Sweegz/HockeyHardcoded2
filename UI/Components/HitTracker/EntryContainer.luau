--# selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local vide = require(ReplicatedStorage.Packages.vide)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

local Entry = require(script.Parent.Entry)

local create = vide.create

local Channel

local function EntryContainer()
	local HitEntryTable = vide.source({})

	Synchronizer:WaitAndCall("HitTracker", function(channel)
		Channel = channel

		HitEntryTable(channel:Get("Hits"))

		channel:OnDictionaryInserted("Hits", function(value)
			HitEntryTable(channel:Get("Hits"))
		end)

		channel:OnDictionaryRemoved("Hits", function(value, key)
			HitEntryTable(channel:Get("Hits"))
		end)
	end)

	return create("Frame")({
		Name = "EntryContainer",

		Size = UDim2.fromScale(1, 1.047),
		Position = UDim2.fromScale(0, 0.1),
		BackgroundColor3 = Color3.fromRGB(43, 43, 43),
		BackgroundTransparency = 0.5,
		BorderColor3 = Color3.fromRGB(27, 42, 53),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 0,

		create("UIListLayout")({
			Padding = UDim.new(0, 0),
			FillDirection = Enum.FillDirection.Vertical,
			Wraps = false,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			HorizontalFlex = Enum.UIFlexAlignment.None,
			ItemLineAlignment = Enum.ItemLineAlignment.Automatic,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			VerticalFlex = Enum.UIFlexAlignment.None,
		}),

		vide.indexes(HitEntryTable, function(data)
			return Entry({
				data = data,
			})
		end),
	})
end

return EntryContainer