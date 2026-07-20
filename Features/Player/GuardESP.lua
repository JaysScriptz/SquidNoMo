local GuardESP = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local RoleService = nil
local Enabled = false
local Connection = nil
local Highlights = {}
local FillColor = Color3.fromRGB(235, 55, 70)
local RefreshElapsed = 0

function GuardESP:Initialize(Loader)
    RoleService = Loader.Features and Loader.Features.Shared and Loader.Features.Shared.RoleService
end

local function matches(player)
    return RoleService and type(RoleService.IsGuard) == "function" and RoleService:IsGuard(player)
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
                highlight.Name = "SquidNoMo_GuardESP"
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

function GuardESP:Enable()
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

function GuardESP:Disable()
    Enabled = false
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    clear()
end

function GuardESP:IsEnabled()
    return Enabled
end

function GuardESP:GetState()
    return Enabled and "on" or "off"
end

function GuardESP:SetColor(color)
    if typeof(color) == "Color3" then
        FillColor = color
        if Enabled then refresh() end
    end
end

function GuardESP:GetColor()
    return FillColor
end

return GuardESP
