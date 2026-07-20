local CompassHUD = {}
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Enabled = false
local Gui = nil
local Connection = nil
local Elapsed = 0

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
    Gui.Name = "SquidNoMo_CompassHUD"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 999976
    Gui.Parent = getParent()

    local panel = Instance.new("Frame")
    panel.AnchorPoint = Vector2.new(0.5, 0)
    panel.Position = UDim2.new(0.5, 0, 0, 12)
    panel.Size = UDim2.fromOffset(180, 34)
    panel.BackgroundColor3 = Color3.fromRGB(12, 9, 18)
    panel.BackgroundTransparency = 0.12
    panel.BorderSizePixel = 0
    panel.Parent = Gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = panel
    local outline = Instance.new("UIStroke")
    outline.Color = Color3.fromRGB(232, 67, 255)
    outline.Transparency = 0.18
    outline.Parent = panel

    local label = Instance.new("TextLabel")
    label.Name = "Value"
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.fromOffset(8, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = "N  000°"
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(240, 245, 255)
    label.Parent = panel
    return label
end

local directions = {"N", "NE", "E", "SE", "S", "SW", "W", "NW"}

function CompassHUD:Enable()
    if Enabled then return end
    Enabled = true
    local label = build()
    Gui.Enabled = true
    Elapsed = 0
    Connection = RunService.Heartbeat:Connect(function(deltaTime)
        Elapsed = Elapsed + deltaTime
        if Elapsed < 0.12 then return end
        Elapsed = 0
        local camera = workspace.CurrentCamera
        if camera and label and label.Parent then
            local look = camera.CFrame.LookVector
            local heading = (math.deg(math.atan2(-look.X, -look.Z)) + 360) % 360
            local index = math.floor((heading + 22.5) / 45) % 8 + 1
            label.Text = string.format("%s  %03d°", directions[index], math.floor(heading + 0.5))
        end
    end)
end

function CompassHUD:Disable()
    Enabled = false
    if Connection then Connection:Disconnect() Connection = nil end
    if Gui then Gui.Enabled = false end
end

function CompassHUD:IsEnabled() return Enabled end
function CompassHUD:GetState() return Enabled and "on" or "off" end

return CompassHUD
