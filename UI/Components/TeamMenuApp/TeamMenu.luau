--# selene: allow(mixed_table)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local CommandsController = require(StarterPlayer.StarterPlayerScripts.Controllers.CommandsController)
local StaminaController = require(StarterPlayer.StarterPlayerScripts.Controllers.StaminaController)
local vide = require(ReplicatedStorage.Packages.vide)
local LocalPlayer = Players.LocalPlayer

local create = vide.create


function Button(props:{
    Name: string,
    Text: string,
    Position: UDim2,
    Color: ColorSequence,
    Activated: () -> (),
})
    return create ("Frame" :: "Frame"){
        Name = props.Name,
        Position = props.Position,
        Size = UDim2.fromScale(0.5, 0.4),
        BackgroundColor3 = Color3.fromRGB(255,255,255),

        create ("UIGradient" :: "UIGradient"){
            Color = props.Color,
            Rotation = 90,
        },

        create ("TextButton" :: "TextButton"){
            Text = props.Text,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            TextScaled = true,
            TextColor3 = Color3.fromRGB(255,255,255),
            FontFace = Font.new(Font.fromEnum(Enum.Font.ArimoBold).Family, Enum.FontWeight.Bold),
            Activated = props.Activated,            

        },
    }
end

local function GetBenchColor(benched: boolean?): ColorSequence
    if benched == true then
        return ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(212, 20, 56)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40))
        }
    elseif benched == false then
        return ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 165, 92)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40))
        }
    else
        return ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 200, 200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40))
        }
    end
end


function Entry(props: {
    player: Player
})

    print(props.player.Team)

    local Stamina = vide.source()

    local connections = {}


    if props.player == LocalPlayer then
        Stamina(StaminaController:GetStamina())

        table.insert(connections, StaminaController.StaminaChanged:Connect(function(value: number)
            Stamina(value)
        end))
    else
        Stamina(props.player:GetAttribute("Stamina"))
    end

    local Benched = vide.source(props.player:GetAttribute("Benched"))

    table.insert(connections, props.player.AttributeChanged:Connect(function(attributeName: string)
        if attributeName == "Stamina" and not (props.player == LocalPlayer) then
            Stamina(props.player:GetAttribute("Stamina"))
        end

        if attributeName == "Benched" then
            Benched(props.player:GetAttribute("Benched"))
        end
    end))

    vide.cleanup(function()
        for _, conn in connections do
            conn:Disconnect()
        end
    end)

    return create ("Frame" :: "Frame"){
        Name = "Entry",
        BackgroundColor3 = Color3.fromRGB(43,43,43),
        BackgroundTransparency = 0,
        LayoutOrder = function()
            return props.player == LocalPlayer and 0 or 1
        end,

        create ("TextLabel" :: "TextLabel"){
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.fromScale(0.9, 0.45),
            BackgroundTransparency = 1,
            ZIndex = 5,

            Text = props.player.Name,
            TextColor3 = Color3.fromRGB(255,255,255),
            TextScaled = true,
            FontFace = Font.new(Font.fromEnum(Enum.Font.Arimo).Family, Enum.FontWeight.ExtraBold),

            create ("UIStroke" :: "UIStroke"){
                Thickness = 0.03,
                StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
                BorderStrokePosition = Enum.BorderStrokePosition.Outer,
                Color = Color3.fromRGB(0,0,0),
                Transparency = 0,
            },

            
        },

        create ("Frame" :: "Frame"){
            Name = "Status",
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.fromScale(1, 0.5),
            BackgroundColor3 = Color3.fromRGB(255,255,255),

            create ("UIGradient" :: "UIGradient"){
                Color = function()
                    return GetBenchColor(Benched())
                end, 
            },
        },

        Button({
            Name = "Unbench",
            Text = "UB",
            Position = UDim2.fromScale(0, 0.5),
            Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(51,237,155)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(51/2,237/2,155/2))
            },
            Activated = function() 
                CommandsController:Bench(props.player, false)
            end,
        }),

        Button({
            Name = "Bench",
            Text = "B",
            Position = UDim2.fromScale(0.5, 0.5),
            Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(246, 55, 90)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(246/2, 55/2, 90/2))
            },
            Activated = function() 
                CommandsController:Bench(props.player, true)
            end,
        }),


        create ("UIStroke" :: "UIStroke"){
            Thickness = 0.027,
            StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
            BorderStrokePosition = Enum.BorderStrokePosition.Outer,
            Color = Color3.fromRGB(0,0,0),
        },

        create ("Frame" :: "Frame"){
            Name = "Stamina",
            Size = UDim2.fromScale(1, 0.1),
            Position = UDim2.fromScale(0, 0.9),

            BackgroundTransparency = 1,


            
            create ("Frame" :: "Frame"){
                Name = "Bar",
                Size = function()
                    local size = Stamina() / 100 

                    return UDim2.fromScale(size, 1)
                end, 
                BackgroundColor3 = Color3.fromRGB(255,255,255),

                vide.create("UIGradient"){
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,170/1.5,255/1.5)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,170,255)),
                    },
                },
            },
        }
    }
end


function Team(props: {
    Team: () -> (Team)
})

    local playersTable = {}
    local PlayerList = vide.source({})
    
    for _, player in props.Team():GetPlayers() do
        table.insert(playersTable, player)
    end

    PlayerList(playersTable)

    props.Team().PlayerAdded:Connect(function(player: Player)
        table.insert(playersTable, player)
        PlayerList(playersTable)
    end)

    props.Team().PlayerRemoved:Connect(function(player: Player)
        table.insert(playersTable, player)
        PlayerList(playersTable)
    end)

    return create ("Frame" :: "Frame") {
        Name = "Team",
        Size = UDim2.fromScale(0.203, 0.603),
        Position = UDim2.fromScale(0.009, 0.3),
        BackgroundTransparency = 1,

        --[[
        create ("UIAspectRatioConstraint" :: "UIAspectRatioConstraint"){
            AspectRatio = 0.595,
        },--]]

        create ("UIGridLayout" :: "UIGridLayout"){
            CellPadding = UDim2.fromScale(0, 0.0072),
            CellSize = UDim2.fromScale(0.4, 0.12),
            FillDirection = Enum.FillDirection.Vertical,
            FillDirectionMaxCells = 0,
            SortOrder = Enum.SortOrder.LayoutOrder,
            StartCorner = Enum.StartCorner.TopLeft,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Top,
        },

        vide.values(PlayerList, function(player: Player)
            return Entry({
                player = player
            })
        end),
    }
end

return Team