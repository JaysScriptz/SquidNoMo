local BoxESP = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Enabled = false
local Color = Color3.fromRGB(255, 58, 145)
local Connection = nil
local Entries = {}
local Elapsed = 0

local function remove(character)
    local highlight = Entries[character]
    if highlight then
        highlight:Destroy()
        Entries[character] = nil
    end
end

local function refresh()
    local valid = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if player ~= LocalPlayer and character and character.Parent then
            valid[character] = true
            local highlight = Entries[character]
            if not highlight or not highlight.Parent then
                highlight = Instance.new("Highlight")
                highlight.Name = "SquidNoMo_BoxESP"
                highlight.Adornee = character
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillTransparency = 1
                highlight.OutlineTransparency = 0
                highlight.Parent = character
                Entries[character] = highlight
            end
            highlight.OutlineColor = Color
            highlight.FillColor = Color
        end
    end

    for character in pairs(Entries) do
        if not valid[character] or not character.Parent then
            remove(character)
        end
    end
end

local function clear()
    for character in pairs(Entries) do
        remove(character)
    end
end

function BoxESP:Enable()
    if Enabled then return end
    Enabled = true
    refresh()
    Elapsed = 0
    Connection = RunService.Heartbeat:Connect(function(deltaTime)
        Elapsed = Elapsed + deltaTime
        if Elapsed >= 0.4 then
            Elapsed = 0
            refresh()
        end
    end)
end

function BoxESP:Disable()
    Enabled = false
    if Connection then Connection:Disconnect() Connection = nil end
    clear()
end

function BoxESP:IsEnabled() return Enabled end
function BoxESP:GetState() return Enabled and "on" or "off" end
function BoxESP:SetColor(color)
    if typeof(color) == "Color3" then
        Color = color
        if Enabled then refresh() end
    end
end
function BoxESP:GetColor() return Color end

return BoxESP
