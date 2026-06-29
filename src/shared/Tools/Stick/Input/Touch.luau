local Touch = {}

function Touch.InputBegan(input: InputObject, _commands)
	print(input.KeyCode)
end

function Touch.InputEnded(_input: InputObject, _commands) end

return Touch
