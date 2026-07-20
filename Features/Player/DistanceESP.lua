local DistanceESP = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Enabled = false
local Color = Color3.fromRGB(0, 205, 255)
local Connection = nil
local Entries = {}
local Elapsed = 0

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
    gui.Name = "SquidNoMo_DistanceESP"
    gui.Adornee = head
    gui.Size = UDim2.fromOffset(150, 22)
    gui.StudsOffsetWorldSpace = Vector3.new(0, 2.75, 0)
    gui.AlwaysOnTop = true
    gui.LightInfluence = 0
    gui.MaxDistance = 10000
    gui.Parent = head

    local label = Instance.new("TextLabel")
    label.Name = "Value"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = "-- studs"
    label.TextSize = 11
    label.TextColor3 = Color
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.25
    label.Parent = gui

    Entries[character] = gui
    return gui
end

local function refresh()
    local localCharacter = LocalPlayer and LocalPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    local valid = {}

    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if player ~= LocalPlayer and character and root then
            valid[character] = true
            local gui = Entries[character]
            if not gui or not gui.Parent then
                gui = create(character)
            end
            local label = gui and gui:FindFirstChild("Value")
            if label then
                local distance = localRoot and (localRoot.Position - root.Position).Magnitude or 0
                label.Text = string.format("%d studs", math.floor(distance + 0.5))
                label.TextColor3 = Color
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

function DistanceESP:Enable()
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

function DistanceESP:Disable()
    Enabled = false
    if Connection then Connection:Disconnect() Connection = nil end
    clear()
end

function DistanceESP:IsEnabled() return Enabled end
function DistanceESP:GetState() return Enabled and "on" or "off" end
function DistanceESP:SetColor(color)
    if typeof(color) == "Color3" then
        Color = color
        if Enabled then refresh() end
    end
end
function DistanceESP:GetColor() return Color end

return DistanceESP
