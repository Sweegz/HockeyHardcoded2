local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DRAIN_RATE = 20
local REGEN_RATE = 10
local MAX_STAMINA = 100

local StaminaController = {
	Stamina = 100,
	Burn = false,
}

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui
local bar = PlayerGui.Stamina.Container.Stamina.Bar

function StaminaController:Start()
	RunService.Heartbeat:Connect(function(dt)
		if StaminaController.Burn and StaminaController.Stamina > 0 then
			StaminaController:SetStamina(StaminaController.Stamina - DRAIN_RATE * dt)
		elseif StaminaController.Stamina < MAX_STAMINA then
			StaminaController:SetStamina(StaminaController.Stamina + REGEN_RATE * dt)
		end
	end)
end

function StaminaController:SetStamina(value: number)
	self.Stamina = math.clamp(value, 0, MAX_STAMINA)
	bar.Size = UDim2.fromScale(self.Stamina / MAX_STAMINA, 1)
end

function StaminaController:GetStamina()
	return self.Stamina
end

function StaminaController:SetBurning(isBurning: boolean)
	self.Burn = isBurning
end

function StaminaController:CanSprint()
	return self.Stamina > 0
end

return StaminaController
