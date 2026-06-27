local Touch = {}

function Touch.InputBegan(input: InputObject, commands)
	print(input.KeyCode)
end

function Touch.InputEnded(input: InputObject, commands) end

return Touch
