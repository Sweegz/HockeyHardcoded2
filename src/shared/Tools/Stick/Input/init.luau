local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local disconnectAndClear = require(ReplicatedStorage.Shared.Utility.disconnectAndClear)

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

function Input.New(stickController)
	local self = {
		stickController = stickController,
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
	table.insert(
		self.connections,
		UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
			self.commands = getCommands()
			self.preferredInput = UserInputService.PreferredInput
		end)
	)
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

function Input:DisableCommand(command)
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
	disconnectAndClear(self.connections)
end

return Input
