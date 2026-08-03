--# selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local vide = require(ReplicatedStorage.Packages.vide)
local px = require(ReplicatedStorage.UI.px)

local function getMeterColor(value)
	value = math.clamp(value, 0, 1)

	local GREEN = Color3.fromRGB(0, 255, 0)
	local YELLOW = Color3.fromRGB(255, 255, 0)
	local RED = Color3.fromRGB(255, 40, 0)

	local color

	if value < 0.5 then
		color = GREEN:Lerp(YELLOW, value / 0.5)
	else
		color = YELLOW:Lerp(RED, (value - 0.5) / 0.5)
	end

	return color
end

local create = vide.create


function BaseFrame(props: {
    power: () -> (number),
})
   return create("Frame" :: "Frame") {
      Name = "RoundPowerBar",
      Size = UDim2.fromScale(0.1, 0.1),
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.fromScale(0.5, 0.5),
      BackgroundTransparency = 1,
      
      create "UIAspectRatioConstraint" {
         AspectRatio = 1,
      },

      create("Frame" :: "Frame") {
         Name = "Bottom",
         Size = UDim2.fromScale(1, 1),
         AnchorPoint = Vector2.new(0.5, 0.5),
         Position = UDim2.fromScale(0.5, 0.5),
         BackgroundTransparency = 1,
         BackgroundColor3 = Color3.fromRGB(0,0,0),
         ZIndex = 1,

         create("UICorner" :: "UICorner") {
            CornerRadius = UDim.new(1, 0)
         },

         --[[create("UIStroke") {
            Thickness = 0.032,
            StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
            Color = Color3.fromRGB(0,0,0),
            BorderStrokePosition = Enum.BorderStrokePosition.Outer,
         }, --]]
      },

      vide.create("Frame" :: "Frame") {
         Name = "Left",
         Size = UDim2.fromScale(0.5,  1),
         AnchorPoint = Vector2.new(0, 0.5),
         Position = UDim2.fromScale(0, 0.5),
         BackgroundTransparency = 1,
         ClipsDescendants = true,
         ZIndex = 2,

         create("Frame" :: "Frame") {
            Name = "Frame",
            Size = UDim2.fromScale(2, 1),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(1, 0.5),
            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            ZIndex = 3,

            create("UICorner" :: "UICorner") {
               CornerRadius = UDim.new(1, 0)
            },

            vide.create("UIGradient"){
               Rotation = function() 
                  local pwr = props.power()

                  local midpointPower = 75
                  local halfPowerRange = 25

   



                  if pwr <= 50 then
                     return 0
                  end

                  return 90 + ((pwr - midpointPower) / halfPowerRange) * 90
               end, 
               Color = function() 
                  local color = getMeterColor(props.power() / 100) or Color3.fromRGB(255,255,255)
                  return ColorSequence.new(color)
               end,
                  Transparency = NumberSequence.new{
                     NumberSequenceKeypoint.new(0, 1),
                     NumberSequenceKeypoint.new(0.5, 1),
                      NumberSequenceKeypoint.new(0.501, 0),
                     NumberSequenceKeypoint.new(1, 0)
                  },
            },
         },
      },

      vide.create("Frame" :: "Frame") {
         Name = "Right",
         Size = UDim2.fromScale(0.5,  1),
         AnchorPoint = Vector2.new(1, 0.5),
         Position = UDim2.fromScale(1, 0.5),
         BackgroundTransparency = 1,
         ClipsDescendants = true,
         ZIndex = 2,

         create("Frame" :: "Frame") {
            Name = "Frame",
            Size = UDim2.fromScale(2, 1),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0, 0.5),
            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            ZIndex = 3,

            create("UICorner" :: "UICorner") {
               CornerRadius = UDim.new(1, 0)
            },

            vide.create("UIGradient"){
               Rotation = function() 
                  local pwr = props.power()

                  local midpointPower = 25
                  local halfPowerRange = 25


                  
                  if pwr >= 50 then
                     return 0
                  end

                  return -90 + ((pwr - midpointPower) / halfPowerRange) * 90 
               end, 
               Color = function() 
                  local color = getMeterColor(props.power() / 100) or Color3.fromRGB(255,255,255)
                  return ColorSequence.new(color)
               end,
                  Transparency = NumberSequence.new{
                     NumberSequenceKeypoint.new(0, 1),
                     NumberSequenceKeypoint.new(0.5, 1),
                      NumberSequenceKeypoint.new(0.501, 0),
                     NumberSequenceKeypoint.new(1, 0)
                  },
            },
            

         },
      }, 

      create("Frame" :: "Frame") {
         Name = "Top",
         Size = UDim2.fromScale(0.7, 0.7),
         AnchorPoint = Vector2.new(0.5, 0.5),
         Position = UDim2.fromScale(0.5, 0.5),
         BackgroundTransparency = 0,
         BackgroundColor3 = function() 
            local power = props.power()
            local color = power > 0 and getMeterColor(power / 100) or Color3.fromRGB(0,0,0)
            return color:Lerp(Color3.fromRGB(0,0,0), 0.9)
         end,
         ZIndex = 10,

         create("UICorner" :: "UICorner") {
            CornerRadius = UDim.new(1, 0),
         },

         create("UIStroke") {
            Thickness = 0.022,
            StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
            BorderStrokePosition = Enum.BorderStrokePosition.Center,
            Color = Color3.fromRGB(0,0,0),
         },

         create("TextLabel" :: "TextLabel"){
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromScale(2, 2),
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 1,
            --TextScaled = true,
            TextSize = px(16),
            Text = function() 
               local power = math.round(props.power())
               return ("%*%%"):format(power)
            end,
            ZIndex = 10,

         TextColor3 = function() 
            local power = props.power()
            local color = power > 0 and getMeterColor(power / 100) or Color3.fromRGB(0,0,0)
            return color:Lerp(Color3.fromRGB(0,0,0), 0)
         end,

            TextStrokeTransparency = 1,
            --TextColor3 = Color3.fromRGB(255, 255, 255),
            FontFace = Font.new(Font.fromEnum(Enum.Font.ArimoBold).Family, Enum.FontWeight.ExtraBold),

            create("UIStroke") {
               Thickness = 0.032,
               StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
               Color = Color3.fromRGB(0,0,0),
            },
      }

      },


   }
end

return BaseFrame