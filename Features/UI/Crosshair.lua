local Crosshair = {}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Enabled = false
local Gui = nil
local Color = Color3.fromRGB(255, 58, 145)

local function getParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    local player = Players.LocalPlayer
    return (player and player:FindFirstChildOfClass("PlayerGui")) or CoreGui
end

local function createLine(parent, size, position)
    local line = Instance.new("Frame")
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Position = position
    line.Size = size
    line.BackgroundColor3 = Color
    line.BorderSizePixel = 0
    line.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = line
    return line
end

local function build()
    if Gui and Gui.Parent then return end
    Gui = Instance.new("ScreenGui")
    Gui.Name = "SquidNoMo_Crosshair"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 999990
    Gui.Parent = getParent()

    local center = Instance.new("Frame")
    center.Name = "Center"
    center.AnchorPoint = Vector2.new(0.5, 0.5)
    center.Position = UDim2.fromScale(0.5, 0.5)
    center.Size = UDim2.fromOffset(42, 42)
    center.BackgroundTransparency = 1
    center.Parent = Gui

    createLine(center, UDim2.fromOffset(14, 3), UDim2.new(0.5, -13, 0.5, 0))
    createLine(center, UDim2.fromOffset(14, 3), UDim2.new(0.5, 13, 0.5, 0))
    createLine(center, UDim2.fromOffset(3, 14), UDim2.new(0.5, 0, 0.5, -13))
    createLine(center, UDim2.fromOffset(3, 14), UDim2.new(0.5, 0, 0.5, 13))
    createLine(center, UDim2.fromOffset(4, 4), UDim2.fromScale(0.5, 0.5))
end

local function recolor()
    if not Gui then return end
    for _, child in ipairs(Gui:GetDescendants()) do
        if child:IsA("Frame") and child.Name ~= "Center" then
            child.BackgroundColor3 = Color
        end
    end
end

function Crosshair:Enable()
    Enabled = true
    build()
    recolor()
    if Gui then Gui.Enabled = true end
end

function Crosshair:Disable()
    Enabled = false
    if Gui then Gui.Enabled = false end
end

function Crosshair:IsEnabled() return Enabled end
function Crosshair:GetState() return Enabled and "on" or "off" end
function Crosshair:SetColor(color)
    if typeof(color) == "Color3" then Color = color recolor() end
end
function Crosshair:GetColor() return Color end

return Crosshair
