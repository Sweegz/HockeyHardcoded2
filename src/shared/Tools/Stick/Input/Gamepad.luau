local Gamepad = {}

function Gamepad.InputBegan(input: InputObject, commands)
	print(input.KeyCode)
end

function Gamepad.InputEnded(input: InputObject, commands) end

return Gamepad
