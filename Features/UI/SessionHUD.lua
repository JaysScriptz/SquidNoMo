local SessionHUD = {}
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Enabled = false
local Gui = nil
local Thread = nil
local StartedAt = 0

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
    Gui.Name = "SquidNoMo_SessionHUD"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 999979
    Gui.Parent = getParent()

    local panel = Instance.new("Frame")
    panel.Position = UDim2.fromOffset(12, 54)
    panel.Size = UDim2.fromOffset(180, 34)
    panel.BackgroundColor3 = Color3.fromRGB(12, 9, 18)
    panel.BackgroundTransparency = 0.12
    panel.BorderSizePixel = 0
    panel.Parent = Gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = panel
    local outline = Instance.new("UIStroke")
    outline.Color = Color3.fromRGB(172, 76, 255)
    outline.Transparency = 0.18
    outline.Parent = panel

    local label = Instance.new("TextLabel")
    label.Name = "Value"
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.fromOffset(8, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = "SESSION 00:00:00"
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(240, 245, 255)
    label.Parent = panel
    return label
end

local function formatTime(seconds)
    seconds = math.max(0, math.floor(seconds))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function SessionHUD:Enable()
    if Enabled then return end
    Enabled = true
    StartedAt = os.clock()
    local label = build()
    Gui.Enabled = true
    Thread = task.spawn(function()
        while Enabled and Gui and Gui.Parent do
            if label and label.Parent then
                label.Text = "SESSION " .. formatTime(os.clock() - StartedAt)
            end
            task.wait(1)
        end
    end)
end

function SessionHUD:Disable()
    Enabled = false
    Thread = nil
    if Gui then Gui.Enabled = false end
end

function SessionHUD:IsEnabled() return Enabled end
function SessionHUD:GetState() return Enabled and "on" or "off" end

return SessionHUD
