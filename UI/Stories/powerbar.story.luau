--# selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local vide = require(ReplicatedStorage.Packages.vide)
local RoundPowerBar = require(ReplicatedStorage.UI.Components.PowerBarApp.RoundPowerBar)
local px = require(ReplicatedStorage.UI.px)



return function(target: Instance)
	return vide.mount(function()
            px.mount()

            local power = vide.source(100)

            return RoundPowerBar({
                  power = power,
            })
	end, target)
end

