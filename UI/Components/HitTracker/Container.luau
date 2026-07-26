--# selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CloseButton = require(script.Parent.CloseButton)
local EntryContainer = require(script.Parent.EntryContainer)
local Header = require(script.Parent.Header)
local Title = require(script.Parent.Title)
local vide = require(ReplicatedStorage.Packages.vide)

local create = vide.create

local function Container(props: {
    Enabled: (boolean) -> (),
})
	return create "Frame" {
		Name = "Container",

		Size = UDim2.fromScale(0.6, 0.7),

		--Position = UDim2.fromScale(0.2, 0.1),
		Position = UDim2.fromScale(0.5, 0.46),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(43, 43, 43),
		BackgroundTransparency = 0.5,
		BorderColor3 = Color3.fromRGB(27, 42, 53),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 1,

		ClipsDescendants = true,

		Header(),
		EntryContainer(),
		Title {
			Enabled = props.Enabled
		},
		CloseButton { 
            Enabled = props.Enabled
        },
	}
end

return Container