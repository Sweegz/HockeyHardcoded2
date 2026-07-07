local Gamepad = {}

function Gamepad.InputBegan(_input: InputObject, _commands) end

function Gamepad.InputEnded(_input: InputObject, _commands) end

function Gamepad.InputBeganFixed(input: InputObject, _commands)
	print(input.KeyCode)
end

function Gamepad.InputEndedFixed(_input: InputObject, _commands) end

return Gamepad
