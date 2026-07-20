local RoleLegend = {}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Enabled = false
local Gui = nil

local function getParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    local player = Players.LocalPlayer
    return (player and player:FindFirstChildOfClass("PlayerGui")) or CoreGui
end

local function build()
    if Gui and Gui.Parent then return end
    Gui = Instance.new("ScreenGui")
    Gui.Name = "SquidNoMo_RoleLegend"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 999970
    Gui.Parent = getParent()

    local panel = Instance.new("Frame")
    panel.AnchorPoint = Vector2.new(1, 0)
    panel.Position = UDim2.new(1, -12, 0, 12)
    panel.Size = UDim2.fromOffset(160, 124)
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

    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(10, 5)
    title.Size = UDim2.new(1, -20, 0, 22)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.Text = "ROLE COLORS"
    title.TextSize = 11
    title.TextColor3 = Color3.fromRGB(255, 196, 64)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = panel

    local roles = {
        {"Player", Color3.fromRGB(0, 170, 255)},
        {"Guard", Color3.fromRGB(235, 55, 70)},
        {"Detective", Color3.fromRGB(0, 230, 150)},
        {"Frontman", Color3.fromRGB(172, 76, 255)},
    }
    for index, entry in ipairs(roles) do
        local dot = Instance.new("Frame")
        dot.Position = UDim2.fromOffset(12, 29 + ((index - 1) * 22))
        dot.Size = UDim2.fromOffset(12, 12)
        dot.BackgroundColor3 = entry[2]
        dot.BorderSizePixel = 0
        dot.Parent = panel
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot

        local label = Instance.new("TextLabel")
        label.Position = UDim2.fromOffset(32, 25 + ((index - 1) * 22))
        label.Size = UDim2.new(1, -42, 0, 20)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamMedium
        label.Text = entry[1]
        label.TextSize = 10
        label.TextColor3 = Color3.fromRGB(240, 236, 244)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = panel
    end
end

function RoleLegend:Enable()
    Enabled = true
    build()
    if Gui then Gui.Enabled = true end
end
function RoleLegend:Disable()
    Enabled = false
    if Gui then Gui.Enabled = false end
end
function RoleLegend:IsEnabled() return Enabled end
function RoleLegend:GetState() return Enabled and "on" or "off" end

return RoleLegend
