local KeyboardMouse = {}

local lastClickTime = 0
local doubleClickTime = 0.25

-- For inputs that can occur between frames
function KeyboardMouse.InputBegan(input: InputObject, commands)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		commands.ChargePower = time()
	end

	if input.KeyCode == Enum.KeyCode.Q then
		commands.Fake = time()
	end

	if input.KeyCode == Enum.KeyCode.E then
		commands.Chip = time()
	end

	if input.KeyCode == Enum.KeyCode.X then
		commands.WristShot = time()
	end

	if input.KeyCode == Enum.KeyCode.X then
		commands.CancelSlapshot = time()
	end
end

-- For inputs that can occur between frames
function KeyboardMouse.InputEnded(input: InputObject, commands)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		commands.ChargePower = false
	end

	if input.KeyCode == Enum.KeyCode.Q then
		commands.Fake = false
	end

	if input.KeyCode == Enum.KeyCode.E then
		commands.Chip = false
	end

	if input.KeyCode == Enum.KeyCode.X then
		commands.WristShot = false
	end

	if input.KeyCode == Enum.KeyCode.X then
		commands.CancelSlapshot = false
	end
end

-- For inputs that can occur at a fixed rate
function KeyboardMouse.InputBeganFixed(input: InputObject, commands)
	if input.KeyCode == Enum.KeyCode.Space then
		commands.Aim = time()
	end

	if input.KeyCode == Enum.KeyCode.F then
		commands.GlideLeft = time()
	end

	if input.KeyCode == Enum.KeyCode.G then
		commands.GlideRight = time()
	end

	if input.KeyCode == Enum.KeyCode.Space then
		commands.RaiseHand = time()
	end

	if input.KeyCode == Enum.KeyCode.Q then
		commands.Shove = time()
	end

	if input.KeyCode == Enum.KeyCode.R then
		commands.HighTip = time()
	end

	if input.KeyCode == Enum.KeyCode.E then
		commands.LowTip = time()
	end

	if input.KeyCode == Enum.KeyCode.X then
		commands.LyingBlock = time()
	end

	if input.KeyCode == Enum.KeyCode.C then
		commands.KneeBlock = time()
	end

	if input.KeyCode == Enum.KeyCode.V then
		commands.StandBlock = time()
	end

	if input.KeyCode == Enum.KeyCode.Z then
		commands.SlapShot = time()
	end

	if input.KeyCode == Enum.KeyCode.Z then
		commands.DropPuck = time()
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		commands.Sprint = time()
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local clickTime = time()
		if (clickTime - lastClickTime) < doubleClickTime then
			commands.PokeCheck = time()
		end
		lastClickTime = clickTime
	end

	-- Move Direction --
	if input.KeyCode == Enum.KeyCode.W then
		commands.MoveForward = time()
	end

	if input.KeyCode == Enum.KeyCode.A then
		commands.MoveLeft = time()
	end

	if input.KeyCode == Enum.KeyCode.S then
		commands.MoveBackward = time()
	end

	if input.KeyCode == Enum.KeyCode.D then
		commands.MoveRight = time()
	end

	if input.KeyCode == Enum.KeyCode.B then
		commands.Toedrag = time()
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

	if input.KeyCode == Enum.KeyCode.Z then
		commands.SlapShot = false
	end

	if input.KeyCode == Enum.KeyCode.Z then
		commands.DropPuck = false
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

	if input.KeyCode == Enum.KeyCode.B then
		commands.Toedrag = false
	end
	-------------------
end

return KeyboardMouse
