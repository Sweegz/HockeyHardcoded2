local RunService = game:GetService("RunService")

local IS_SERVER = RunService:IsServer()
local Config = require(script.Shared.Config)
local HTTPS = game:GetService("HttpService")
local Stats = require(script.Shared.Stats)
local Player = require(script.Server.Player)
local Receiver = require(script.Server.Receiver)
local ServerClock = require(script.Server.ServerClock)
local Entity = require(script.Shared.Entity)
local Events = require(script.Shared.Events)
local Holder = require(script.Shared.Holder)
local ReplicationRules = require(script.Shared.ReplicationRules)
local Snapshots = require(script.Shared.Snapshots)
local Types = require(script.Shared.Types)
local EntityGrid = require(script.Server.EntityGrid)

export type SnapshotData<Value, Velocity> = Types.SnapshotData<Value, Velocity>
export type Signal<fx, T...> = Types.Signal<fx, T...>
export type ClientEntitiesStats = Types.ClientEntitiesStats
export type ServerEntitiesStats = Types.ServerEntitiesStats
export type Connection = Types.Connection
export type Event<fx, T...> = Types.Event<fx, T...>
export type Snapshot<Value, Velocity> = Types.Snapshot<Value, Velocity>
export type MODEL_REPLICATION_MODE = Types.MODEL_REPLICATION_MODE
export type EntityConfig = Types.EntityConfig
export type EntityConfigInput = Types.EntityConfigInput
export type Ticker = Types.Ticker
export type InterpolationBuffer = Types.InterpolationBuffer
export type ClientClock = Types.ClientClock
export type ReplicationRule = Types.ReplicationRule
export type EntityReceivePacket = Types.EntityReceivePacket
export type Entity = Types.Entity
export type PlayerEntityHolder = Types.PlayerEntityHolder

local STARTED = false
return {
	Start = function(config: ModuleScript?)
		if STARTED then
			warn("Chrono: Already Started. Ignoring subsequent calls.")
			return
		end
		STARTED = true
		if config then
			(require)(config)
		end
		if IS_SERVER then
			require(script.Server.Replicate)
		else
			require(script.Client.Replicate)
		end
		Config._Lock()

		--local currentVersion = Config._GetConfig("__VERSION")
		print(`CustomReplication started.`)
	end,

	Holder = Holder,
	Entity = Entity,
	Stats = Stats,
	Config = Config,
	ReplicationRules = ReplicationRules,
	Events = Events,
	Snapshots = Snapshots,

	ServerClock = ServerClock,
	Player = Player,
	ServerReceiver = Receiver,
	EntityGrid = EntityGrid,
}
