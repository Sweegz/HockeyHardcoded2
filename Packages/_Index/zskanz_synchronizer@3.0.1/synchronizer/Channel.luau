--!strict
--[[

		Synchronizer v3.0 — Channel
		By: Skanz.
		
		Represents a single synchronized data channel.
		Handles state mutations, event dispatching, listener
		management, and client-side cache synchronization.

]]
--

-- ** Services **

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

-- ** Constants **

local IS_SERVER: boolean = RunService:IsServer()
local SaveConnections: boolean = false

-- ** Dependencies **

-- ** Types **

type SignalMap = { [string]: Signal.Signal<any, any, any> }

type SignalStore = {
	Changed: SignalMap,
	ArrayInsert: SignalMap,
	ArrayRemoved: SignalMap,
	DictionaryInsert: SignalMap,
	DictionaryRemoved: SignalMap,
	[string]: SignalMap,
}

type ActionType = "Changed" | "ArrayInsert" | "ArrayRemoved" | "DictionaryInsert" | "DictionaryRemoved"

type ActionEntry = {
	[number]: any, -- [1] path, [2] actionType, [3] value, [4] extra, [5]? extra
}

export type Channel = {

	-- Attributes
	Index: any,
	ReferenceTable: { [any]: any }?,
	CacheTable: { [any]: any },
	CommunicationRoute: RemoteEvent,
	Queue: { ActionEntry },
	Synchronizer: any,
	Connections: { Signal.Connection | RBXScriptConnection },
	SavedConnections: { Signal.Connection },
	Signals: SignalStore,
	Listeners: { Player },
	OnDestroyed: Signal.Signal<Channel>,

	-- Mutations
	Set: (self: Channel, path: string, value: any) -> Channel,
	Increase: (self: Channel, path: string, value: number) -> Channel,
	InsertOnArray: (self: Channel, path: string, value: any, targetIndex: number?) -> number?,
	RemoveFromArray: (self: Channel, path: string, index: number) -> any?,
	InsertOnDictionary: (self: Channel, path: string, index: any, value: any) -> nil,
	RemoveFromDictionary: (self: Channel, path: string, index: any) -> any?,

	-- Events
	OnChanged: (
		self: Channel,
		path: string,
		callback: (newValue: any, oldValue: any) -> (),
		forceCall: boolean?
	) -> Signal.Connection,
	OnArrayInserted: (self: Channel, path: string, callback: (value: any, index: number) -> ()) -> Signal.Connection,
	OnArrayRemoved: (self: Channel, path: string, callback: (value: any, index: number) -> ()) -> Signal.Connection,
	OnDictionaryInserted: (self: Channel, path: string, callback: (value: any, index: any) -> ()) -> Signal.Connection,
	OnDictionaryRemoved: (self: Channel, path: string, callback: (value: any, index: any) -> ()) -> Signal.Connection,

	-- Listeners
	AddListener: (self: Channel, listener: Player) -> Channel,
	RemoveListener: (self: Channel, listener: Player) -> Channel,
	GetListeners: (self: Channel) -> { Player },

	-- Getters
	Get: (self: Channel, path: string?) -> any,
	GetTable: (self: Channel) -> { [any]: any },
	GetIndex: (self: Channel) -> any,

	-- Cleanup
	ClearSignal: (self: Channel, signalIdentifier: string) -> Channel,
	Destroy: (self: Channel, synchronizerCall: boolean?) -> nil,
}

-- ** Channel Class **

local Channel = {}
Channel.__index = Channel

-- ** Private Helpers **

local function ResolvePath(path: string, source: { [any]: any }): (any, { [any]: any }?, any)
	local segments = string.split(path, ".")
	local current: any = source
	local parent: { [any]: any }? = nil
	local lastKey: any = nil

	for i = 1, #segments do
		local key: any = segments[i]
		parent = current
		current = current[key]
		lastKey = key

		if current == nil and i < #segments then
			return nil, nil, nil
		end
	end

	return current, parent, lastKey
end

local function GetOrCreateSignal(store: SignalMap, path: string): Signal.Signal<any, any, any>
	local signal = store[path]
	if not signal then
		signal = Signal.new()
		store[path] = signal
	end
	return signal
end

local function FireAction(self: Channel, actionEntry: ActionEntry)
	local path: string = actionEntry[1]
	local actionType: string = actionEntry[2]

	if path == "" then
		return
	end

	local signalMap = self.Signals[actionType :: ActionType]
	if not signalMap then
		return
	end

	local targetSignal = signalMap[path]
	if targetSignal then
		targetSignal:Fire(actionEntry[3], actionEntry[4], actionEntry[5])
	end
end

local function InsertOnQueue(self: Channel, actionEntry: ActionEntry)
	local path: string = actionEntry[1]
	local action: string = actionEntry[2]

	-- For simple value changes, deduplicate: keep only the latest per path
	if action == "Changed" then
		for i = #self.Queue, 1, -1 do
			local queued = self.Queue[i]
			if queued[1] == path and queued[2] == "Changed" then
				table.remove(self.Queue, i)
				break
			end
		end
	end

	table.insert(self.Queue, actionEntry)
end

local function DispatchQueuedActions(self: Channel)
	local pending = (self :: any).PendingDispatchSkip

	if #self.Queue == 0 then
		if IS_SERVER and pending then
			for player in pending do
				pending[player] = nil
			end
		end
		return
	end

	-- Fire local signals
	for i = 1, #self.Queue do
		FireAction(self, self.Queue[i])
	end

	-- Replicate to listeners
	if IS_SERVER then
		local queue = self.Queue
		for _, player: Player in self.Listeners do
			if not (pending and pending[player]) then
				self.CommunicationRoute:FireClient(player, queue)
			end
		end
		if pending then
			for player in pending do
				pending[player] = nil
			end
		end
	end

	table.clear(self.Queue)
end

local function ApplyClientAction(self: Channel, data: { any })
	local path: string = data[1]
	local actionType: string = data[2]
	local dataTable = self:GetTable()

	local value, parentTable, key = ResolvePath(path, dataTable)

	if actionType == "Changed" then
		local newValue = data[3]
		-- Store the actual old value from cache (more accurate than server-sent)
		data[4] = value
		if parentTable and key then
			parentTable[key] = newValue
		end
	elseif actionType == "ArrayInsert" then
		if value and typeof(value) == "table" then
			table.insert(value, data[4], data[3])
		end
	elseif actionType == "ArrayRemoved" then
		if value and typeof(value) == "table" then
			table.remove(value, data[4])
		end
	elseif actionType == "DictionaryInsert" then
		if value and typeof(value) == "table" then
			value[data[4]] = data[3]
		end
	elseif actionType == "DictionaryRemoved" then
		if value and typeof(value) == "table" then
			value[data[4]] = nil
		end
	end

	FireAction(self, data)
end

-- ** Constructor **

function Channel.new(
	index: any,
	referenceTable: { [any]: any }?,
	synchronizer: any,
	_,
	settings: { [string]: any }
): Channel
	local self: Channel = setmetatable({}, Channel) :: any

	self.Index = index
	self.Queue = {}
	self.Synchronizer = synchronizer
	self.Connections = {}
	self.SavedConnections = {}
	self.OnDestroyed = Signal.new()

	-- Listeners
	self.Listeners = {}

	-- Signals
	self.Signals = {
		Changed = {},
		ArrayInsert = {},
		ArrayRemoved = {},
		DictionaryInsert = {},
		DictionaryRemoved = {},
	}

	-- Reference Table (server) / Cache Table (client)
	if IS_SERVER then
		self.ReferenceTable = referenceTable or {}
	end

	-- Communication Route
	if IS_SERVER then
		local route = Instance.new("RemoteEvent")
		route.Name = tostring(index)
		route.Parent = script
		self.CommunicationRoute = route
	else
		self.CommunicationRoute = script:WaitForChild(tostring(index)) :: RemoteEvent
	end

	-- Client: fetch initial data and listen for updates
	if not IS_SERVER then
		local RequestData: RemoteFunction = script.Parent:WaitForChild("RequestData") :: RemoteFunction
		local success, result = pcall(function()
			return RequestData:InvokeServer(self:GetIndex())
		end)

		self.CacheTable = if success and result then result else {}

		local clientConnection = self.CommunicationRoute.OnClientEvent:Connect(function(actionList)
			if typeof(actionList) ~= "table" then
				return
			end

			for i = 1, #actionList do
				ApplyClientAction(self, actionList[i])
			end
		end)

		table.insert(self.Connections, clientConnection)
	end

	-- Server: dispatch queued actions every frame
	if IS_SERVER then
		local steppedConnection = RunService.Stepped:Connect(function()
			DispatchQueuedActions(self)
		end)

		table.insert(self.Connections, steppedConnection)
	end

	return self
end

-- ** Mutation Methods **

function Channel.Set(self: Channel, path: string, value: any): Channel
	assert(path and typeof(path) == "string", "[Channel] Path must be a non-empty string.")

	local currentValue, targetTable, key = ResolvePath(path, self:GetTable())
	if not targetTable or key == nil then
		warn(`[Channel] Set failed: path '{path}' could not be resolved.`)
		return self
	end

	targetTable[key] = value
	InsertOnQueue(self, { path, "Changed", value, currentValue })

	return self
end

function Channel.Increase(self: Channel, path: string, value: number): Channel
	assert(path and typeof(path) == "string", "[Channel] Path must be a non-empty string.")
	assert(value and typeof(value) == "number", "[Channel] Increase value must be a number.")

	local currentValue, targetTable, key = ResolvePath(path, self:GetTable())
	if not targetTable or key == nil then
		warn(`[Channel] Increase failed: path '{path}' could not be resolved.`)
		return self
	end

	if typeof(currentValue) ~= "number" then
		warn(`[Channel] Increase failed: value at '{path}' is not a number.`)
		return self
	end

	local newValue = currentValue + value
	targetTable[key] = newValue
	InsertOnQueue(self, { path, "Changed", newValue, currentValue })

	return self
end

function Channel.InsertOnArray(self: Channel, path: string, value: any, targetIndex: number?): number?
	assert(path and typeof(path) == "string", "[Channel] Path must be a non-empty string.")
	assert(value ~= nil, "[Channel] Value cannot be nil.")

	if targetIndex ~= nil then
		assert(typeof(targetIndex) == "number", "[Channel] Target index must be a number.")
	end

	local targetTable = ResolvePath(path, self:GetTable())
	if not targetTable or typeof(targetTable) ~= "table" then
		warn(`[Channel] InsertOnArray failed: path '{path}' is not a table.`)
		return nil
	end

	local insertIndex: number
	if targetIndex then
		table.insert(targetTable, targetIndex, value)
		insertIndex = targetIndex
	else
		table.insert(targetTable, value)
		insertIndex = #targetTable
	end

	InsertOnQueue(self, { path, "ArrayInsert", value, insertIndex })
	return insertIndex
end

function Channel.RemoveFromArray(self: Channel, path: string, targetIndex: number): any?
	assert(path and typeof(path) == "string", "[Channel] Path must be a non-empty string.")
	assert(targetIndex and typeof(targetIndex) == "number", "[Channel] Target index must be a number.")

	local targetTable = ResolvePath(path, self:GetTable())
	if not targetTable or typeof(targetTable) ~= "table" then
		warn(`[Channel] RemoveFromArray failed: path '{path}' is not a table.`)
		return nil
	end

	local removed = table.remove(targetTable, targetIndex)
	InsertOnQueue(self, { path, "ArrayRemoved", removed, targetIndex })

	return removed
end

function Channel.InsertOnDictionary(self: Channel, path: string, index: any, value: any): nil
	assert(path and typeof(path) == "string", "[Channel] Path must be a non-empty string.")
	assert(index ~= nil, "[Channel] Dictionary index cannot be nil.")
	assert(value ~= nil, "[Channel] Value cannot be nil.")

	local targetTable = ResolvePath(path, self:GetTable())
	if not targetTable or typeof(targetTable) ~= "table" then
		warn(`[Channel] InsertOnDictionary failed: path '{path}' is not a table.`)
		return nil
	end

	targetTable[index] = value
	InsertOnQueue(self, { path, "DictionaryInsert", value, index })

	return nil
end

function Channel.RemoveFromDictionary(self: Channel, path: string, index: any): any?
	assert(path and typeof(path) == "string", "[Channel] Path must be a non-empty string.")
	assert(index ~= nil, "[Channel] Dictionary index cannot be nil.")

	local targetTable = ResolvePath(path, self:GetTable())
	if not targetTable or typeof(targetTable) ~= "table" then
		warn(`[Channel] RemoveFromDictionary failed: path '{path}' is not a table.`)
		return nil
	end

	local value = targetTable[index]
	targetTable[index] = nil
	InsertOnQueue(self, { path, "DictionaryRemoved", value, index })

	return value
end

-- ** Event Methods **

function Channel.OnChanged(
	self: Channel,
	path: string,
	callback: (newValue: any, oldValue: any) -> (),
	forceCall: boolean?
): Signal.Connection
	assert(path and typeof(path) == "string", "[Channel] Path must be a non-empty string.")

	local signal = GetOrCreateSignal(self.Signals.Changed, path)

	if forceCall == true then
		task.spawn(callback, self:Get(path), nil)
	end

	local connection = signal:Connect(callback)
	if SaveConnections then
		table.insert(self.SavedConnections, connection)
	end
	return connection
end

function Channel.OnArrayInserted(
	self: Channel,
	path: string,
	callback: (value: any, index: number) -> ()
): Signal.Connection
	assert(path and typeof(path) == "string", "[Channel] Path must be a non-empty string.")
	local connection = GetOrCreateSignal(self.Signals.ArrayInsert, path):Connect(callback)
	if SaveConnections then
		table.insert(self.SavedConnections, connection)
	end
	return connection
end

function Channel.OnArrayRemoved(
	self: Channel,
	path: string,
	callback: (value: any, index: number) -> ()
): Signal.Connection
	assert(path and typeof(path) == "string", "[Channel] Path must be a non-empty string.")
	local connection = GetOrCreateSignal(self.Signals.ArrayRemoved, path):Connect(callback)
	if SaveConnections then
		table.insert(self.SavedConnections, connection)
	end
	return connection
end

function Channel.OnDictionaryInserted(
	self: Channel,
	path: string,
	callback: (value: any, index: any) -> ()
): Signal.Connection
	assert(path and typeof(path) == "string", "[Channel] Path must be a non-empty string.")
	local connection = GetOrCreateSignal(self.Signals.DictionaryInsert, path):Connect(callback)
	if SaveConnections then
		table.insert(self.SavedConnections, connection)
	end
	return connection
end

function Channel.OnDictionaryRemoved(
	self: Channel,
	path: string,
	callback: (value: any, index: any) -> ()
): Signal.Connection
	assert(path and typeof(path) == "string", "[Channel] Path must be a non-empty string.")
	local connection = GetOrCreateSignal(self.Signals.DictionaryRemoved, path):Connect(callback)
	if SaveConnections then
		table.insert(self.SavedConnections, connection)
	end
	return connection
end

-- ** Listener Methods **

function Channel.AddListener(self: Channel, listener: Player): Channel
	if table.find(self.Listeners, listener) then
		return self
	end

	table.insert(self.Listeners, listener)
	local pending = (self :: any).PendingDispatchSkip
	if not pending then
		pending = {}
		(self :: any).PendingDispatchSkip = pending
	end
	pending[listener] = true
	self.Synchronizer.OnChannelListenerAdded:Fire(self, listener)

	return self
end

function Channel.RemoveListener(self: Channel, listener: Player): Channel
	local index = table.find(self.Listeners, listener)
	if not index then
		return self
	end

	table.remove(self.Listeners, index)
	self.Synchronizer.OnChannelListenerRemoved:Fire(self, listener)

	return self
end

function Channel.GetListeners(self: Channel): { Player }
	return self.Listeners
end

-- ** Getter Methods **

function Channel.Get(self: Channel, path: string?): any
	if not path then
		return self:GetTable()
	end
	return (ResolvePath(path, self:GetTable()))
end

function Channel.GetIndex(self: Channel): any
	return self.Index
end

function Channel.GetTable(self: Channel): { [any]: any }
	return (if IS_SERVER then self.ReferenceTable else self.CacheTable) :: { [any]: any }
end

-- ** Cleanup Methods **

function Channel.ClearSignal(self: Channel, signalIdentifier: string): Channel
	for _, signalMap: SignalMap in self.Signals :: any do
		for path, signal in signalMap do
			if string.find(path, signalIdentifier, 1, true) then
				signal:DisconnectAll()
				signal:Destroy()
				signalMap[path] = nil
			end
		end
	end

	return self
end

function Channel.Destroy(self: Channel, synchronizerCall: boolean?): nil
	-- If not called from Synchronizer, delegate to it for proper cleanup
	if synchronizerCall ~= true then
		return self.Synchronizer:Destroy(self:GetIndex())
	end

	-- Remove all listeners first (notifies clients)
	if IS_SERVER then
		for i = #self.Listeners, 1, -1 do
			self:RemoveListener(self.Listeners[i])
		end

		-- Rename and schedule remote destruction to avoid race conditions
		self.CommunicationRoute.Name = HttpService:GenerateGUID(false)
		Debris:AddItem(self.CommunicationRoute, 5)
	end

	-- Fire destroyed signal
	self.OnDestroyed:Fire(self)
	self.OnDestroyed:DisconnectAll()
	self.OnDestroyed:Destroy()

	-- Disconnect all connections
	for _, connection in self.Connections do
		if typeof(connection) == "RBXScriptConnection" then
			(connection :: RBXScriptConnection):Disconnect()
		else
			(connection :: Signal.Connection):Disconnect()
		end
	end

	-- Destroy all signals
	for _, signalMap: SignalMap in self.Signals :: any do
		for _, signal in signalMap do
			signal:DisconnectAll()
			signal:Destroy()
		end
	end

	-- Disconnect saved connections
	for _, connection in self.SavedConnections do
		connection:Disconnect()
	end

	-- Clear internal state
	table.clear(self.SavedConnections)
	table.clear(self.Queue)
	table.clear(self.Connections)
	table.clear(self.Listeners)
	setmetatable(self :: any, nil)

	return nil
end

return Channel
