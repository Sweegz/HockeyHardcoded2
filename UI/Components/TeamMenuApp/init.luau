local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TeamMenu = require(script.TeamMenu)
local vide = require(ReplicatedStorage.Packages.vide)

local LocalPlayer = Players.LocalPlayer

local function TeamMenuApp()


    local Team = vide.source(LocalPlayer.Team)

    LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function(...)
        Team(LocalPlayer.Team)
    end)

    local function IsOnTeam()
        local team = Team()

        if team and (team.TeamColor == BrickColor.Blue() or team.TeamColor == BrickColor.Red()) then
            return true
        end

        return false
    end

    return vide.create("ScreenGui"){
        vide.show(IsOnTeam, function()
            return TeamMenu({
                Team = Team
            })
        end),
   }
end

return TeamMenuApp