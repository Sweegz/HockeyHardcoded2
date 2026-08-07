local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local TeamController = require(StarterPlayer.StarterPlayerScripts.Controllers.TeamController)
local TeamMenu = require(script.TeamMenu)
local vide = require(ReplicatedStorage.Packages.vide)

local LocalPlayer = Players.LocalPlayer

local function TeamMenuApp()


    local Team = vide.source(LocalPlayer.Team)
    local TeamColor = vide.source(tostring(LocalPlayer.Team.TeamColor))

    LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function(...)
        Team(LocalPlayer.Team)
        TeamColor(tostring(LocalPlayer.Team.TeamColor))
    end)

    return vide.create("ScreenGui"){
        vide.switch(TeamColor) {
            ["Bright blue"] = function()
                return TeamMenu({Team = Team})
            end,

            ["Bright red"] = function()
                return TeamMenu({Team = Team})
            end,
        }
    }
end

return TeamMenuApp