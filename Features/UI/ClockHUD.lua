local ClockHUD = {}
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Enabled = false
local Gui = nil
local Thread = nil
local Generation = 0

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
    Gui.Name = "SquidNoMo_ClockHUD"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 999974
    Gui.Parent = getParent()

    local panel = Instance.new("Frame")
    panel.AnchorPoint = Vector2.new(1, 0)
    panel.Position = UDim2.new(1, -12, 0, 12)
    panel.Size = UDim2.fromOffset(150, 34)
    panel.BackgroundColor3 = Color3.fromRGB(12, 9, 18)
    panel.BackgroundTransparency = 0.12
    panel.BorderSizePixel = 0
    panel.Parent = Gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = panel
    local outline = Instance.new("UIStroke")
    outline.Color = Color3.fromRGB(255, 58, 145)
    outline.Transparency = 0.18
    outline.Parent = panel

    local label = Instance.new("TextLabel")
    label.Name = "Value"
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.fromOffset(8, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = "--:--:--"
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(240, 245, 255)
    label.Parent = panel
    return label
end

function ClockHUD:Enable()
    if Enabled then return end
    Enabled = true
    Generation = Generation + 1
    local generation = Generation
    local label = build()
    Gui.Enabled = true
    Thread = task.spawn(function()
        while Enabled and generation == Generation and Gui and Gui.Parent do
            if label and label.Parent then
                label.Text = os.date("%I:%M:%S %p")
            end
            task.wait(1)
        end
    end)
end

function ClockHUD:Disable()
    Enabled = false
    Generation = Generation + 1
    Thread = nil
    if Gui then Gui.Enabled = false end
end

function ClockHUD:IsEnabled() return Enabled end
function ClockHUD:GetState() return Enabled and "on" or "off" end

return ClockHUD
