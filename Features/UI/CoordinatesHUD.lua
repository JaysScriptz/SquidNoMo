local CoordinatesHUD = {}
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Enabled = false
local Gui = nil
local Connection = nil
local Elapsed = 0

local function getParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    return (LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")) or CoreGui
end

local function build()
    if Gui and Gui.Parent then return Gui:FindFirstChild("Value", true) end
    Gui = Instance.new("ScreenGui")
    Gui.Name = "SquidNoMo_CoordinatesHUD"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 999978
    Gui.Parent = getParent()

    local panel = Instance.new("Frame")
    panel.AnchorPoint = Vector2.new(0, 1)
    panel.Position = UDim2.new(0, 12, 1, -12)
    panel.Size = UDim2.fromOffset(230, 34)
    panel.BackgroundColor3 = Color3.fromRGB(12, 9, 18)
    panel.BackgroundTransparency = 0.12
    panel.BorderSizePixel = 0
    panel.Parent = Gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = panel
    local outline = Instance.new("UIStroke")
    outline.Color = Color3.fromRGB(45, 232, 98)
    outline.Transparency = 0.18
    outline.Parent = panel

    local label = Instance.new("TextLabel")
    label.Name = "Value"
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.fromOffset(8, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = "X --  Y --  Z --"
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(240, 245, 255)
    label.Parent = panel
    return label
end

function CoordinatesHUD:Enable()
    if Enabled then return end
    Enabled = true
    local label = build()
    Gui.Enabled = true
    Elapsed = 0
    Connection = RunService.Heartbeat:Connect(function(deltaTime)
        Elapsed = Elapsed + deltaTime
        if Elapsed < 0.15 then return end
        Elapsed = 0
        local character = LocalPlayer and LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if label and label.Parent then
            if root then
                local p = root.Position
                label.Text = string.format("X %.0f  Y %.0f  Z %.0f", p.X, p.Y, p.Z)
            else
                label.Text = "X --  Y --  Z --"
            end
        end
    end)
end

function CoordinatesHUD:Disable()
    Enabled = false
    if Connection then Connection:Disconnect() Connection = nil end
    if Gui then Gui.Enabled = false end
end

function CoordinatesHUD:IsEnabled() return Enabled end
function CoordinatesHUD:GetState() return Enabled and "on" or "off" end

return CoordinatesHUD
