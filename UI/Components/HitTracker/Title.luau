--# selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.Packages.vide)

local create = vide.create


local function Title(props: {
	Enabled: (boolean) -> (),
})
	return create "TextLabel" {
		Name = "Title",

		Size = UDim2.fromScale(1, 0.1),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 2,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		TextStrokeTransparency = 0,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		Text = "Hit Tracker",
		FontFace = Font.new(Font.fromEnum(Enum.Font.SourceSans).Family, Enum.FontWeight.Light),

		--[[
		vide.spring(function()
			return if props.Enabled() then 0.5 else 1
		end),
		]]
	}
end

return Title
