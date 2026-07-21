local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local CollectEvents = require(ReplicatedStorage.Shared.Utility.CollectEvents)
local DisconnectAndClear = require(ReplicatedStorage.Shared.Utility.DisconnectAndClear)

local KeyboardMouse = require(script.KeyboardMouse)
local Touch = require(script.Touch)
local Gamepad = require(script.Gamepad)

local function getHandler(preferredInput: Enum.PreferredInput)
	if preferredInput == Enum.PreferredInput.Gamepad then
		return Gamepad
	end

	if preferredInput == Enum.PreferredInput.KeyboardAndMouse then
		return KeyboardMouse
	end

	if preferredInput == Enum.PreferredInput.Touch then
		return Touch
	end

	return
end

local function getCommands()
	return {
		GlideRight = false,
		GlideLeft = false,
		Aim = false,
		RaiseHand = false,
	}
end

local Input = {}
Input.__index = Input

function Input.New(ctx)
	local self = {
		ctx = ctx,
		connections = {},
		enabled = false,
		commands = getCommands(),
		preferredInput = Enum.PreferredInput.KeyboardAndMouse,
	}
	setmetatable(self, Input)

	self:Initialize()

	return self
end

function Input:Initialize()
	local inputBegan, inputBeganConnection = CollectEvents(UserInputService.InputBegan)
	local inputEnded, inputEndedConnection = CollectEvents(UserInputService.InputEnded)

	-- Event functions
	self.inputBegan = inputBegan
	self.inputEnded = inputEnded

	-- Event connections
	table.insert(self.connections, inputBeganConnection)
	table.insert(self.connections, inputEndedConnection)

	table.insert(
		self.connections,
		UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
			self.commands = getCommands()
			self.preferredInput = UserInputService.PreferredInput
		end)
	)

	-- Non-fixed InputBegan (can poll between ticks)
	table.insert(
		self.connections,
		UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
			if gameProcessedEvent then
				return
			end

			if not self.enabled then
				return
			end

			local handler = getHandler(self.preferredInput)
			if handler then
				handler.InputBegan(input, self.commands)
			end
		end)
	)

	-- Non-fixed InputEnded (can poll between ticks)
	table.insert(
		self.connections,
		UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
			if gameProcessedEvent then
				return
			end

			if not self.enabled then
				return
			end

			local handler = getHandler(self.preferredInput)
			if handler then
				handler.InputEnded(input, self.commands)
			end
		end)
	)
end

function Input:Tick(_dt)
	-- Runs at Fixed Rate

	-- Fixed InputBegan
	for input: InputObject, gameProcessedEvent: boolean in self.inputBegan do
		if gameProcessedEvent then
			return
		end

		if not self.enabled then
			return
		end

		local handler = getHandler(self.preferredInput)
		if handler then
			handler.InputBeganFixed(input, self.commands)
		end
	end

	-- Fixed InputEnded
	for input: InputObject, gameProcessedEvent: boolean in self.inputEnded do
		if gameProcessedEvent then
			return
		end

		if not self.enabled then
			return
		end

		local handler = getHandler(self.preferredInput)
		if handler then
			handler.InputEndedFixed(input, self.commands)
		end
	end
end

function Input:DisableCommand(command)
	print(command, "disabled")
	self.commands[command] = false
end

function Input:Enable()
	self.enabled = true
end

function Input:Disable()
	self.enabled = false
	table.clear(self.commands)
end

function Input:Destroy()
	self:Disable()
	DisconnectAndClear(self.connections)
end

return Input
