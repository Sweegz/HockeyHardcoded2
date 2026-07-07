local KeyboardMouse = {}

local lastClickTime = 0
local doubleClickTime = 0.25

-- For inputs that can occur between frames
function KeyboardMouse.InputBegan(input: InputObject, commands)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		commands.ChargePower = tick()
	end
end

-- For inputs that can occur between frames
function KeyboardMouse.InputEnded(input: InputObject, commands)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		commands.ChargePower = false
	end
end

-- For inputs that can occur at a fixed rate
function KeyboardMouse.InputBeganFixed(input: InputObject, commands)
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

	if input.KeyCode == Enum.KeyCode.Z then
		commands.SlapShot = tick()
	end

	if input.KeyCode == Enum.KeyCode.Q then
		commands.Fake = tick()
	end

	if input.KeyCode == Enum.KeyCode.E then
		commands.Chip = tick()
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		commands.Sprint = tick()
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local clickTime = tick()
		if (clickTime - lastClickTime) < doubleClickTime then
			commands.PokeCheck = tick()
		end
		lastClickTime = clickTime
	end

	-- Move Direction --
	if input.KeyCode == Enum.KeyCode.W then
		commands.MoveForward = tick()
	end

	if input.KeyCode == Enum.KeyCode.A then
		commands.MoveLeft = tick()
	end

	if input.KeyCode == Enum.KeyCode.S then
		commands.MoveBackward = tick()
	end

	if input.KeyCode == Enum.KeyCode.D then
		commands.MoveRight = tick()
	end
	-------------------
end

-- For inputs that can occur at a fixed rate
function KeyboardMouse.InputEndedFixed(input: InputObject, commands)
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

	if input.KeyCode == Enum.KeyCode.Z then
		commands.SlapShot = false
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

	if input.KeyCode == Enum.KeyCode.Q then
		commands.Fake = false
	end

	if input.KeyCode == Enum.KeyCode.E then
		commands.Chip = false
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		commands.Sprint = false
	end

	-- Move Direction --
	if input.KeyCode == Enum.KeyCode.W then
		commands.MoveForward = false
	end

	if input.KeyCode == Enum.KeyCode.A then
		commands.MoveLeft = false
	end

	if input.KeyCode == Enum.KeyCode.S then
		commands.MoveBackward = false
	end

	if input.KeyCode == Enum.KeyCode.D then
		commands.MoveRight = false
	end
	-------------------
end

return KeyboardMouse
