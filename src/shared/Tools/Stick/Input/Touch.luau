local Touch = {}

-- For inputs that can occur between frames
function Touch.InputBegan(_input: InputObject, _commands) end

-- For inputs that can occur between frames
function Touch.InputEnded(_input: InputObject, _commands) end

-- For inputs that can occur at a fixed rate
function Touch.InputBeganFixed(input: InputObject, _commands)
	print(input.KeyCode)
end

-- For inputs that can occur at a fixed rate
function Touch.InputEndedFixed(_input: InputObject, _commands) end

return Touch
