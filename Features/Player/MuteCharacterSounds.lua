local MuteCharacterSounds = {}
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

local function mute(object)
    if object:IsA("Sound") then
        if Original[object] == nil then
            Original[object] = object.Volume
        end
        object.Volume = 0
    end
end

local function watchCharacter(character)
    for _, object in ipairs(character:GetDescendants()) do
        mute(object)
    end
    table.insert(Connections, character.DescendantAdded:Connect(function(object)
        if Enabled then mute(object) end
    end))
end

function MuteCharacterSounds:Enable()
    if Enabled then return end
    Enabled = true
    if LocalPlayer and LocalPlayer.Character then
        watchCharacter(LocalPlayer.Character)
    end
    if LocalPlayer then
        table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(character)
            if Enabled then task.defer(watchCharacter, character) end
        end))
    end
end

function MuteCharacterSounds:Disable()
    Enabled = false
    disconnectAll()
    for sound, volume in pairs(Original) do
        if sound and sound.Parent then
            sound.Volume = volume
        end
    end
    table.clear(Original)
end

function MuteCharacterSounds:IsEnabled()
    return Enabled
end

function MuteCharacterSounds:GetState()
    return Enabled and "on" or "off"
end

return MuteCharacterSounds
