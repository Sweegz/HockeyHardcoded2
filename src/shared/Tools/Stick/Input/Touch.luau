local Touch = {}

function Touch.InputBegan(_input: InputObject, _commands) end

function Touch.InputEnded(_input: InputObject, _commands) end

function Touch.InputBeganFixed(input: InputObject, _commands)
	print(input.KeyCode)
end

function Touch.InputEndedFixed(_input: InputObject, _commands) end

return Touch
