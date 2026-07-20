local SpeedHUD = {}
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
    Gui.Name = "SquidNoMo_SpeedHUD"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 999977
    Gui.Parent = getParent()

    local panel = Instance.new("Frame")
    panel.AnchorPoint = Vector2.new(0.5, 1)
    panel.Position = UDim2.new(0.5, 0, 1, -12)
    panel.Size = UDim2.fromOffset(150, 34)
    panel.BackgroundColor3 = Color3.fromRGB(12, 9, 18)
    panel.BackgroundTransparency = 0.12
    panel.BorderSizePixel = 0
    panel.Parent = Gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = panel
    local outline = Instance.new("UIStroke")
    outline.Color = Color3.fromRGB(255, 196, 64)
    outline.Transparency = 0.18
    outline.Parent = panel

    local label = Instance.new("TextLabel")
    label.Name = "Value"
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.fromOffset(8, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = "SPEED --"
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(240, 245, 255)
    label.Parent = panel
    return label
end

function SpeedHUD:Enable()
    if Enabled then return end
    Enabled = true
    local label = build()
    Gui.Enabled = true
    Elapsed = 0
    Connection = RunService.Heartbeat:Connect(function(deltaTime)
        Elapsed = Elapsed + deltaTime
        if Elapsed < 0.12 then return end
        Elapsed = 0
        local character = LocalPlayer and LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local speed = root and Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z).Magnitude or 0
        if label and label.Parent then
            label.Text = string.format("SPEED %.0f", speed)
        end
    end)
end

function SpeedHUD:Disable()
    Enabled = false
    if Connection then Connection:Disconnect() Connection = nil end
    if Gui then Gui.Enabled = false end
end

function SpeedHUD:IsEnabled() return Enabled end
function SpeedHUD:GetState() return Enabled and "on" or "off" end

return SpeedHUD
