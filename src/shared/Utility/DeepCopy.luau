local function DeepCopy(Table)
	local NewTable = {}
	for Key, Value in pairs(Table) do
		if type(Value) == "table" then
			NewTable[Key] = DeepCopy(Value)
		else
			NewTable[Key] = Value
		end
	end
	return NewTable
end

return DeepCopy
