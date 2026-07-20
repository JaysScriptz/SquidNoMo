local PerformanceHUD = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local Enabled = false
local Gui = nil
local Connection = nil
local Frames = 0
local LastUpdate = os.clock()

local function getParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    local player = Players.LocalPlayer
    return (player and player:FindFirstChildOfClass("PlayerGui")) or CoreGui
end

local function build()
    if Gui and Gui.Parent then return Gui:FindFirstChild("Value", true) end
    Gui = Instance.new("ScreenGui")
    Gui.Name = "SquidNoMo_PerformanceHUD"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 999980
    Gui.Parent = getParent()

    local panel = Instance.new("Frame")
    panel.Position = UDim2.fromOffset(12, 12)
    panel.Size = UDim2.fromOffset(220, 34)
    panel.BackgroundColor3 = Color3.fromRGB(12, 9, 18)
    panel.BackgroundTransparency = 0.12
    panel.BorderSizePixel = 0
    panel.Parent = Gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = panel
    local outline = Instance.new("UIStroke")
    outline.Color = Color3.fromRGB(0, 205, 255)
    outline.Transparency = 0.18
    outline.Parent = panel

    local label = Instance.new("TextLabel")
    label.Name = "Value"
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.fromOffset(8, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = "FPS --  |  PING --  |  PLAYERS --"
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(240, 245, 255)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = panel
    return label
end

function PerformanceHUD:Enable()
    if Enabled then return end
    Enabled = true
    local label = build()
    Gui.Enabled = true
    Frames = 0
    LastUpdate = os.clock()
    Connection = RunService.RenderStepped:Connect(function()
        Frames = Frames + 1
        local now = os.clock()
        if now - LastUpdate >= 1 then
            local fps = math.floor(Frames / math.max(0.001, now - LastUpdate))
            local ping = "--"
            pcall(function()
                ping = tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()))
            end)
            if label and label.Parent then
                label.Text = string.format("FPS %d  |  PING %s ms  |  PLAYERS %d", fps, ping, #Players:GetPlayers())
            end
            Frames = 0
            LastUpdate = now
        end
    end)
end

function PerformanceHUD:Disable()
    Enabled = false
    if Connection then Connection:Disconnect() Connection = nil end
    if Gui then Gui.Enabled = false end
end

function PerformanceHUD:IsEnabled() return Enabled end
function PerformanceHUD:GetState() return Enabled and "on" or "off" end

return PerformanceHUD
