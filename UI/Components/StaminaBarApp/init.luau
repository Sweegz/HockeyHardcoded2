--# selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local StaminaController = require(StarterPlayer.StarterPlayerScripts.Controllers.StaminaController)
local vide = require(ReplicatedStorage.Packages.vide)
local px = require(ReplicatedStorage.UI.px)

function Bar(props: {
    stamina: (number) -> (),
})
   return vide.create("ImageLabel" :: "ImageLabel"){
      Name = "Bar",
      Size = UDim2.fromScale(1, 1),
      Image = "rbxassetid://116362414877087",
      BackgroundTransparency = 1,
      ZIndex = 2,

      vide.create("UIGradient"){
         Color = ColorSequence.new(Color3.fromRGB(0,170,255)),
            Transparency = NumberSequence.new{
               NumberSequenceKeypoint.new(0, 0),
               NumberSequenceKeypoint.new(0.999, 0),
               NumberSequenceKeypoint.new(1, 1)
            },
         Offset = function() 
            local perc = 1 - props.stamina() / 100
            return Vector2.new(-perc,0)
         end
      },
   }
end

function Background()
   return vide.create("ImageLabel" :: "ImageLabel"){
      Name = "Background",
      Size = UDim2.fromScale(1, 1),
      Image = "rbxassetid://116362414877087",
      BackgroundTransparency = 1,
      ZIndex = 1,


      vide.create("UIGradient"){
         Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(25,25,25)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50,50,50))
         },
      },
   }
end

function Outline()
   return vide.create("ImageLabel" :: "ImageLabel"){
      Name = "Outline",
      Size = UDim2.fromScale(1.01,1.01),
      AnchorPoint = Vector2.new(0.5,0.5),
      Position = UDim2.fromScale(0.5, 0.5),
      Image = "rbxassetid://87988955223466",
      BackgroundTransparency = 1,
      ZIndex = 5,
   }
end

function Texture()
   return vide.create("ImageLabel" :: "ImageLabel"){
      Name = "Texture",
      Size = UDim2.fromScale(1,1),
      AnchorPoint = Vector2.new(0.5,0.5),
      Position = UDim2.fromScale(0.5, 0.5),
      Image = "rbxassetid://127118261426143",
      BackgroundTransparency = 1,
      ZIndex = 4,
   }
end

function TextLabel()
   return vide.create("TextLabel" :: "TextLabel"){
      Size = UDim2.fromScale(1, 1),
      Position = UDim2.fromScale(0.5, 0.45),
      AnchorPoint = Vector2.new(0.5, 0.5),
      BackgroundColor3 = Color3.fromRGB(255, 0, 0),
      BackgroundTransparency = 1,
      ZIndex = 3,
      TextColor3 = Color3.fromRGB(0,0,0),
      --TextScaled = true,
      TextSize = px(36),
      TextTransparency = 0.6,
      TextStrokeColor3 = Color3.fromRGB(0,0,0),
      Text = "Stamina",
      FontFace = Font.new(Font.fromEnum(Enum.Font.ArimoBold).Family, Enum.FontWeight.Bold),
   }
end

function BaseFrame(props: {
    stamina: (number) -> (),
})
   return vide.create("Frame" :: "Frame") {
      Size = px(UDim2.fromOffset(456/1.5, 77/1.5)),
      AnchorPoint = Vector2.new(1, 0.5),
      Position = UDim2.new(0.997, 0, 0.85, 0),
      BackgroundTransparency = 1,

      Background(),
      Outline(),
      Bar({
         stamina = props.stamina,
      }),
      Texture(),
      TextLabel(),
   }
end

local function StaminaApp()
    local stamina = vide.source(100)

    StaminaController.StaminaChanged:Connect(function(value: number)
      stamina(value)
    end)

    return vide.create("ScreenGui"){

      BaseFrame({
         stamina = stamina,
      })
   }
end

return StaminaApp