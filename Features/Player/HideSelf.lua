local HideSelf = {}
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

function HideSelf:Enable()
    if Enabled then return end
    Enabled = true
    if LocalPlayer and LocalPlayer.Character then
        hideCharacter(LocalPlayer.Character)
    end
    if LocalPlayer then
        table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(character)
            if Enabled then task.defer(hideCharacter, character) end
        end))
    end
end

function HideSelf:Disable()
    Enabled = false
    disconnectAll()
    for object, value in pairs(Original) do
        if object and object.Parent then
            object.LocalTransparencyModifier = value
        end
    end
    table.clear(Original)
end

function HideSelf:IsEnabled()
    return Enabled
end

function HideSelf:GetState()
    return Enabled and "on" or "off"
end

return HideSelf
