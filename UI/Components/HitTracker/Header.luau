--# selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.Packages.vide)

local create = vide.create

local function Header()
	return create("Frame")({
		Name = "Header",

		Size = UDim2.fromScale(1, 0.1),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = Color3.fromRGB(43, 43, 43),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(27, 42, 53),
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = 0,
	})
end

return Header