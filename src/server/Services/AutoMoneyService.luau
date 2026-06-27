local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local MoneyService = require(ServerScriptService.Services.MoneyService)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)

local AutoMoneyService = {}

function AutoMoneyService:Start()
	task.spawn(function()
		while task.wait(1) do
			for _, player in pairs(Players:GetPlayers()) do
				local playerChannel = Synchronizer:Get(player)
				if not playerChannel then
					continue
				end

				MoneyService:Add(player, 10)
			end
		end
	end)
end

return AutoMoneyService
