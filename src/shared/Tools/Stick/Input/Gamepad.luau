local Gamepad = {}

function Gamepad.InputBegan(input: InputObject, _commands)
	print(input.KeyCode)
end

function Gamepad.InputEnded(_input: InputObject, _commands) end

return Gamepad
