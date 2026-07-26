--!strict
--[[

		Synchronizer v3.0
		By: Skanz.
		
		A high-performance state synchronization library for Roblox.
		Manages server-authoritative data channels with automatic
		client replication, batched networking, and event-driven updates.
		
		Changelog v3.0:
		- Improved security: listener validation on data requests
		- Rate limiting on client requests
		- Fixed WaitAndCall initialization bug
		- Improved cleanup and destroy flow
		- Better error handling with pcall guards
		- Strict typing improvements throughout
		- Removed dead code (unused FireServer on client load)
		- ClearSignal reliability improvements
		- Configurable settings

]]
--

-- ** Services **

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- ** Constants **

local IS_SERVER: boolean = RunService:IsServer()

local Settings = {
	MAX_REQUESTS_PER_SECOND = 10,
	DESTROY_CLEANUP_DELAY = 5,
}

-- ** Dependencies **

local Signal = require(ReplicatedStorage.Packages.Signal)
local Channel = require(script.Channel)

-- ** Remote Setup **

local CommunicationRoute: RemoteEvent
local RequestData: RemoteFunction

if IS_SERVER then
	CommunicationRoute = Instance.new("RemoteEvent")
	CommunicationRoute.Name = "CommunicationRoute"
	CommunicationRoute.Parent = script

	RequestData = Instance.new("RemoteFunction")
	RequestData.Name = "RequestData"
	RequestData.Parent = script
else
	CommunicationRoute = script:WaitForChild("CommunicationRoute") :: RemoteEvent
	RequestData = script:WaitForChild("RequestData") :: RemoteFunction
end

-- ** Private State **

local Channels: { [any]: Channel.Channel } = {}
local RateLimitCache: { [number]: { count: number, lastReset: number } } = {}

-- ** Type Definitions **

export type Channel = Channel.Channel

type Synchronizer = {

	-- Server Only
	Create: (self: Synchronizer, index: any, referenceTable: { [any]: any }?) -> Channel.Channel,
	Destroy: (self: Synchronizer, index: any) -> nil,

	-- Shared
	Get: (self: Synchronizer, index: any) -> Channel.Channel?,
	GetAllChannels: (self: Synchronizer) -> { [any]: Channel.Channel },
	Wait: (self: Synchronizer, index: any) -> Channel.Channel,
	WaitAndCall: (self: Synchronizer, index: any, callback: (channel: Channel.Channel) -> ()) -> nil,
	GetTableFromChannel: (self: Synchronizer, index: any) -> { [any]: any }?,

	-- Events
	OnChannelCreated: Signal.Signal<Channel.Channel>,
	OnChannelDestroyed: Signal.Signal<Channel.Channel>,
	OnChannelListenerAdded: Signal.Signal<Channel.Channel, Player>,
	OnChannelListenerRemoved: Signal.Signal<Channel.Channel, Player>,

	-- Internal
	WaitingList: { any },
}

-- ** Module **

local Synchronizer = {

	-- Signals
	OnChannelCreated = Signal.new(),
	OnChannelDestroyed = Signal.new(),
	OnChannelListenerAdded = Signal.new(),
	OnChannelListenerRemoved = Signal.new(),

	-- Waiting List (initialized upfront to avoid nil bugs)
	WaitingList = {} :: { any },
} :: Synchronizer

-- ** Private Methods **

local function IsRateLimited(player: Player): boolean
	local userId = player.UserId
	local now = os.clock()
	local entry = RateLimitCache[userId]

	if not entry or (now - entry.lastReset) >= 1 then
		RateLimitCache[userId] = { count = 1, lastReset = now }
		return false
	end

	entry.count += 1
	return entry.count > Settings.MAX_REQUESTS_PER_SECOND
end

local function IsPlayerListener(channel: any, player: Player): boolean
	local listeners = channel:GetListeners()
	return table.find(listeners, player) ~= nil
end

-- ** Public Methods **

function Synchronizer.Create(self: Synchronizer, index: any, referenceTable: { [any]: any }?): Channel.Channel
	assert(index ~= nil, "[Synchronizer] Channel index cannot be nil.")

	local channel = Channels[index]
	if not channel then
		local newChannel = Channel.new(index, referenceTable, self, IS_SERVER, Settings)
		Channels[index] = newChannel
		channel = newChannel
		self.OnChannelCreated:Fire(newChannel)
	end

	return channel
end

function Synchronizer.Destroy(self: Synchronizer, index: any): nil
	assert(index ~= nil, "[Synchronizer] Channel index cannot be nil.")

	local channel = Channels[index]
	if channel then
		self.OnChannelDestroyed:Fire(channel)
		channel:Destroy(true)
		Channels[index] = nil
	end

	return nil
end

function Synchronizer.Get(self: Synchronizer, index: any): Channel.Channel?
	assert(index ~= nil, "[Synchronizer] Channel index cannot be nil.")
	return Channels[index]
end

function Synchronizer.GetTableFromChannel(self: Synchronizer, index: any): { [any]: any }?
	local channel = Channels[index]
	if channel then
		return channel:GetTable()
	end
	return nil
end

function Synchronizer.GetAllChannels(self: Synchronizer): { [any]: Channel.Channel }
	return Channels
end

function Synchronizer.Wait(self: Synchronizer, index: any): Channel.Channel
	assert(index ~= nil, "[Synchronizer] Channel index cannot be nil.")

	local channel = Channels[index]
	if channel then
		return channel
	end

	-- Yield until the channel is created
	local thread = coroutine.running()
	local connection: Signal.Connection
	connection = self.OnChannelCreated:Connect(function(createdChannel)
		if createdChannel:GetIndex() == index then
			connection:Disconnect()
			coroutine.resume(thread, createdChannel)
		end
	end)

	return coroutine.yield()
end

function Synchronizer.WaitAndCall(self: Synchronizer, index: any, callback: (channel: Channel.Channel) -> ()): nil
	assert(index ~= nil, "[Synchronizer] Channel index cannot be nil.")
	assert(callback ~= nil, "[Synchronizer] Callback cannot be nil.")

	local channel = Channels[index]
	if channel then
		task.spawn(callback, channel)
		return nil
	end

	table.insert(self.WaitingList, { index, callback })
	return nil
end

-- ** Initialization **

-- Process waiting list when channels are created
Synchronizer.OnChannelCreated:Connect(function(channel)
	for i = #Synchronizer.WaitingList, 1, -1 do
		local waitingData = Synchronizer.WaitingList[i]
		if channel:GetIndex() == waitingData[1] then
			task.spawn(waitingData[2], channel)
			table.remove(Synchronizer.WaitingList, i)
		end
	end
end)

-- ** Network Handlers **

if IS_SERVER then
	RequestData.OnServerInvoke = function(player: Player, index: any): { [any]: any }?
		if index == nil then
			return nil
		end
		if IsRateLimited(player) then
			warn(`[Synchronizer] Rate limited: {player.Name} ({player.UserId})`)
			return nil
		end

		local channel: Channel.Channel? = Channels[index]
		if not channel then
			return nil
		end

		-- Security: only listeners can request channel data
		if not IsPlayerListener(channel :: any, player) then
			warn(`[Synchronizer] Unauthorized data request from {player.Name} for channel '{tostring(index)}'`)
			return nil
		end

		return (channel :: Channel.Channel):GetTable()
	end

	Synchronizer.OnChannelListenerAdded:Connect(function(channel, player)
		local payload = { { "ListenerAdded", channel:GetIndex() } }
		CommunicationRoute:FireClient(player, payload)
	end)

	Synchronizer.OnChannelListenerRemoved:Connect(function(channel, player)
		local payload = { { "ListenerRemoved", channel:GetIndex() } }
		CommunicationRoute:FireClient(player, payload)
	end)
else
	CommunicationRoute.OnClientEvent:Connect(function(data)
		if typeof(data) ~= "table" then
			return
		end

		for _, entry in data do
			local action = entry[1]
			if action == "ListenerAdded" then
				Synchronizer:Create(entry[2])
			elseif action == "ListenerRemoved" then
				Synchronizer:Destroy(entry[2])
			end
		end
	end)
end

return Synchronizer
