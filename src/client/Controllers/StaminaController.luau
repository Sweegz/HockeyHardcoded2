local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Signal = require(ReplicatedStorage.Packages.Signal)

local DRAIN_RATE = 20
local REGEN_RATE = 10
local MAX_STAMINA = 100

local StaminaController = {
	Stamina = 100,
	Burn = false,
	StaminaChanged = Signal.new(),
}

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
	self.StaminaChanged:Fire(value)
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
