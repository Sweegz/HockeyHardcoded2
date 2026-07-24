--# selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.Packages.vide)

local create = vide.create
local order = 0

type HitData = {
	player: Player,
	hitPlayer: Player,
	hitPart: BasePart,
	power: number,
	distanceHit: number,
	distanceFromPuck: number,
	penalty: boolean,
}

local function Entry(props: { data: () -> HitData })
	order += 1
	local data: HitData = props.data()

	return create("TextLabel")({
		Name = "Entry",

		Size = UDim2.fromScale(1, 0.066),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = Color3.fromRGB(43, 43, 43),
		BackgroundTransparency = 1,
		ZIndex = 1,
		TextColor3 = function()
			return data.penalty and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
		end,
		TextScaled = true,
		TextStrokeTransparency = 0,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		FontFace = Font.new(Font.fromEnum(Enum.Font.SourceSansItalic).Family, Enum.FontWeight.Regular),
		Text = function()
			return ("%* hit %*'s %* Power %*%%. Hit Distance: %* studs. Distance from puck: %* studs."):format(
				data.player.Name,
				data.hitPlayer.Name,
				data.hitPart.Name,
				data.power,
				data.distanceHit,
				data.distanceFromPuck
			)
		end,
		LayoutOrder = 10000000 - order,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextWrapped = true,
	})
end

return Entry