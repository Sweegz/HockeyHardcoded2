local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local StaminaController = require(StarterPlayer.StarterPlayerScripts.Controllers.StaminaController)
local vide = require(ReplicatedStorage.Packages.vide)
local RoundPowerBar = require(script.RoundPowerBar)

local function PowerBarApp()
    local power = vide.source(100)

    StaminaController.StaminaChanged:Connect(function(value: number)
      power(value)
    end)

    return vide.create("ScreenGui"){

      RoundPowerBar({
         power = power,
      })
   }
end

return PowerBarApp