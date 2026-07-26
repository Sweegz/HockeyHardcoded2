--# selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.Packages.vide)

local create = vide.create

local function CloseButton(props: {
	Enabled: (boolean) -> (),
})
	return create "TextButton" {
		Name = "CloseButton",

		Size = UDim2.fromScale(0.1, 0.06),

		Position = UDim2.fromScale(0.85, 0.02),
		BackgroundColor3 = Color3.fromRGB(173, 0, 0),
		BackgroundTransparency = 0.5,

		ZIndex = 3,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		TextStrokeTransparency = 0,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		Text = "X",



		FontFace = Font.new(Font.fromEnum(Enum.Font.SourceSansBold).Family, Enum.FontWeight.Bold),
		AutoButtonColor = true,

		Activated = function() 
			props.Enabled(false)
		end

	}
end

return CloseButton