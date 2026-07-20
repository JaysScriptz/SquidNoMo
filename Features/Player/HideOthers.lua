local HideOthers = {}
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Enabled = false
local Original = {}
local Connections = {}

local function disconnectAll()
    for _, connection in ipairs(Connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(Connections)
end

local function hideObject(object)
    if object:IsA("BasePart") then
        if Original[object] == nil then
            Original[object] = object.LocalTransparencyModifier
        end
        object.LocalTransparencyModifier = 1
    end
end

local function hideCharacter(character)
    for _, object in ipairs(character:GetDescendants()) do
        hideObject(object)
    end
    table.insert(Connections, character.DescendantAdded:Connect(function(object)
        if Enabled then hideObject(object) end
    end))
end

local function watchPlayer(player)
    if player == LocalPlayer then return end
    if player.Character then hideCharacter(player.Character) end
    table.insert(Connections, player.CharacterAdded:Connect(function(character)
        if Enabled then task.defer(hideCharacter, character) end
    end))
end

function HideOthers:Enable()
    if Enabled then return end
    Enabled = true
    for _, player in ipairs(Players:GetPlayers()) do
        watchPlayer(player)
    end
    table.insert(Connections, Players.PlayerAdded:Connect(function(player)
        if Enabled then watchPlayer(player) end
    end))
end

function HideOthers:Disable()
    Enabled = false
    disconnectAll()
    for object, value in pairs(Original) do
        if object and object.Parent then
            object.LocalTransparencyModifier = value
        end
    end
    table.clear(Original)
end

function HideOthers:IsEnabled()
    return Enabled
end

function HideOthers:GetState()
    return Enabled and "on" or "off"
end

return HideOthers
