local HealthESP = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Enabled = false
local Connection = nil
local Entries = {}
local Elapsed = 0

local function healthColor(alpha)
    if alpha > 0.65 then
        return Color3.fromRGB(45, 232, 98)
    elseif alpha > 0.30 then
        return Color3.fromRGB(255, 196, 64)
    end
    return Color3.fromRGB(255, 63, 86)
end

local function remove(character)
    local gui = Entries[character]
    if gui then
        gui:Destroy()
        Entries[character] = nil
    end
end

local function create(character)
    local head = character:FindFirstChild("Head")
    if not head then return nil end

    local gui = Instance.new("BillboardGui")
    gui.Name = "SquidNoMo_HealthESP"
    gui.Adornee = head
    gui.Size = UDim2.fromOffset(150, 20)
    gui.StudsOffsetWorldSpace = Vector3.new(0, 2.12, 0)
    gui.AlwaysOnTop = true
    gui.LightInfluence = 0
    gui.MaxDistance = 10000
    gui.Parent = head

    local label = Instance.new("TextLabel")
    label.Name = "Value"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = "100% HP"
    label.TextSize = 10
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.25
    label.Parent = gui

    Entries[character] = gui
    return gui
end

local function refresh()
    local valid = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if player ~= LocalPlayer and character and humanoid then
            valid[character] = true
            local gui = Entries[character]
            if not gui or not gui.Parent then
                gui = create(character)
            end
            local label = gui and gui:FindFirstChild("Value")
            if label then
                local alpha = humanoid.MaxHealth > 0 and math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1) or 0
                label.Text = string.format("%d%% HP", math.floor(alpha * 100 + 0.5))
                label.TextColor3 = healthColor(alpha)
            end
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

function HealthESP:Enable()
    if Enabled then return end
    Enabled = true
    refresh()
    Elapsed = 0
    Connection = RunService.Heartbeat:Connect(function(deltaTime)
        Elapsed = Elapsed + deltaTime
        if Elapsed >= 0.18 then
            Elapsed = 0
            refresh()
        end
    end)
end

function HealthESP:Disable()
    Enabled = false
    if Connection then Connection:Disconnect() Connection = nil end
    clear()
end

function HealthESP:IsEnabled() return Enabled end
function HealthESP:GetState() return Enabled and "on" or "off" end

return HealthESP
