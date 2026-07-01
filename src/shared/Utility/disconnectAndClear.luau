local function DisconnectAndClear(connections: { RBXScriptConnection })
	for _, connection in connections do
		connection:Disconnect()
	end
	table.clear(connections)
end

return DisconnectAndClear
