local Gamepad = {}

-- For inputs that can occur between frames
function Gamepad.InputBegan(_input: InputObject, _commands) end

-- For inputs that can occur between frames
function Gamepad.InputEnded(_input: InputObject, _commands) end

-- For inputs that can occur at a fixed rate
function Gamepad.InputBeganFixed(input: InputObject, _commands)
	print(input.KeyCode)
end

-- For inputs that can occur at a fixed rate
function Gamepad.InputEndedFixed(_input: InputObject, _commands) end

return Gamepad
