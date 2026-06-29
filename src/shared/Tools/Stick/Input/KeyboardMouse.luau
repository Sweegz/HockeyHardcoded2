local KeyboardMouse = {}

local lastClickTime = 0
local doubleClickTime = 0.25

function KeyboardMouse.InputBegan(input: InputObject, commands)
	if input.KeyCode == Enum.KeyCode.Space then
		commands.Aim = tick()
	end

	if input.KeyCode == Enum.KeyCode.F then
		commands.GlideLeft = tick()
	end

	if input.KeyCode == Enum.KeyCode.G then
		commands.GlideRight = tick()
	end

	if input.KeyCode == Enum.KeyCode.Space then
		commands.RaiseHand = tick()
	end

	if input.KeyCode == Enum.KeyCode.Q then
		commands.Shove = tick()
	end

	if input.KeyCode == Enum.KeyCode.R then
		commands.HighTip = tick()
	end

	if input.KeyCode == Enum.KeyCode.E then
		commands.LowTip = tick()
	end

	if input.KeyCode == Enum.KeyCode.X then
		commands.LyingBlock = tick()
	end

	if input.KeyCode == Enum.KeyCode.C then
		commands.KneeBlock = tick()
	end

	if input.KeyCode == Enum.KeyCode.V then
		commands.StandBlock = tick()
	end

	if input.KeyCode == Enum.KeyCode.X then
		commands.LyingBlock = tick()
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		commands.Sprint = tick()
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		commands.ChargePower = tick()
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local clickTime = tick()
		if (clickTime - lastClickTime) < doubleClickTime then
			commands.PokeCheck = tick()
		end
		lastClickTime = clickTime
	end
end

function KeyboardMouse.InputEnded(input: InputObject, commands)
	if input.KeyCode == Enum.KeyCode.Space then
		commands.Aim = false
	end

	if input.KeyCode == Enum.KeyCode.F then
		commands.GlideLeft = false
	end

	if input.KeyCode == Enum.KeyCode.G then
		commands.GlideRight = false
	end

	if input.KeyCode == Enum.KeyCode.Space then
		commands.RaiseHand = false
	end

	if input.KeyCode == Enum.KeyCode.Q then
		commands.Shove = false
	end

	if input.KeyCode == Enum.KeyCode.R then
		commands.HighTip = false
	end

	if input.KeyCode == Enum.KeyCode.E then
		commands.LowTip = false
	end

	if input.KeyCode == Enum.KeyCode.X then
		commands.LyingBlock = false
	end

	if input.KeyCode == Enum.KeyCode.C then
		commands.KneeBlock = false
	end

	if input.KeyCode == Enum.KeyCode.V then
		commands.StandBlock = false
	end

	if input.KeyCode == Enum.KeyCode.X then
		commands.LyingBlock = false
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		commands.Sprint = false
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		commands.ChargePower = false
	end
end

return KeyboardMouse
