--# selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local vide = require(ReplicatedStorage.Packages.vide)
local TeamMenu = require(ReplicatedStorage.UI.Components.TeamMenuApp.TeamMenu)
local px = require(ReplicatedStorage.UI.px)



return function(target: Instance)
	return vide.mount(function()
            px.mount()


            return TeamMenu({
            })
	end, target)
end

