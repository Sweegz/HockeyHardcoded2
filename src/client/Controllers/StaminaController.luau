local StaminaController = {
	Stamina = 100,
}

function StaminaController:SetStamina(value: number)
	StaminaController.Stamina = value
end

function StaminaController:GetStamina()
	return StaminaController.Stamina
end

return StaminaController
