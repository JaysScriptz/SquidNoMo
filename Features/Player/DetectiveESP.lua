local DetectiveESP = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local RoleService = nil
local Enabled = false
local Connection = nil
local Highlights = {}
local FillColor = Color3.fromRGB(0, 230, 150)
local RefreshElapsed = 0

function DetectiveESP:Initialize(Loader)
    RoleService = Loader.Features and Loader.Features.Shared and Loader.Features.Shared.RoleService
end

local function matches(player)
    return RoleService and type(RoleService.IsDetective) == "function" and RoleService:IsDetective(player)
end

local function removeCharacter(character)
    local highlight = Highlights[character]
    if highlight then
        highlight:Destroy()
        Highlights[character] = nil
    end
end

local function refresh()
    local valid = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and matches(player) and player.Character then
            local character = player.Character
            valid[character] = true
            local highlight = Highlights[character]
            if not highlight or not highlight.Parent then
                highlight = Instance.new("Highlight")
                highlight.Name = "SquidNoMo_DetectiveESP"
                highlight.Adornee = character
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillTransparency = 0.45
                highlight.OutlineTransparency = 0
                highlight.Parent = character
                Highlights[character] = highlight
            end
            highlight.FillColor = FillColor
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        end
    end

    for character in pairs(Highlights) do
        if not valid[character] or not character.Parent then
            removeCharacter(character)
        end
    end
end

local function clear()
    for character in pairs(Highlights) do
        removeCharacter(character)
    end
end

function DetectiveESP:Enable()
    if Enabled then return end
    Enabled = true
    refresh()
    RefreshElapsed = 0
    Connection = RunService.Heartbeat:Connect(function(deltaTime)
        RefreshElapsed = RefreshElapsed + deltaTime
        if RefreshElapsed >= 0.35 then
            RefreshElapsed = 0
            refresh()
        end
    end)
end

function DetectiveESP:Disable()
    Enabled = false
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    clear()
end

function DetectiveESP:IsEnabled()
    return Enabled
end

function DetectiveESP:GetState()
    return Enabled and "on" or "off"
end

function DetectiveESP:SetColor(color)
    if typeof(color) == "Color3" then
        FillColor = color
        if Enabled then refresh() end
    end
end

function DetectiveESP:GetColor()
    return FillColor
end

return DetectiveESP
