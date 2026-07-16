repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

pcall(function()
    PlayerGui:WaitForChild("SquidNoMo"):Destroy()
end)

local App = {}

App.Version = "0.0.1"
App.Name = "🦑 SquidNoMo 🎯"
App.Game = "Squid Game X"

App.Theme = {

    Background = Color3.fromRGB(17,17,17),
    Surface = Color3.fromRGB(27,27,27),
    Card = Color3.fromRGB(34,34,34),

    Border = Color3.fromRGB(48,48,48),

    Primary = Color3.fromRGB(91,255,98),

    Warning = Color3.fromRGB(255,184,0),

    Danger = Color3.fromRGB(255,77,77),

    Text = Color3.new(1,1,1),

    Secondary = Color3.fromRGB(180,180,180)

}

App.Device = "Desktop"

do

    local Size = workspace.CurrentCamera.ViewportSize

    if UserInputService.TouchEnabled then

        if math.min(Size.X,Size.Y) < 700 then

            App.Device = "Phone"

        else

            App.Device = "Tablet"

        end

    else

        App.Device = "Desktop"

    end

end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SquidNoMo"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = PlayerGui

App.Gui = ScreenGui

------------------------------------------------------------
-- UI Library
------------------------------------------------------------

local UI = {}

function UI:Corner(Object,Radius)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,Radius or 12)
    Corner.Parent = Object

    return Corner

end

function UI:Stroke(Object,Color,Thickness)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color or App.Theme.Border
    Stroke.Thickness = Thickness or 1
    Stroke.Parent = Object

    return Stroke

end

function UI:Padding(Object,P)

    local Padding = Instance.new("UIPadding")

    Padding.PaddingTop = UDim.new(0,P)
    Padding.PaddingBottom = UDim.new(0,P)
    Padding.PaddingLeft = UDim.new(0,P)
    Padding.PaddingRight = UDim.new(0,P)

    Padding.Parent = Object

end

function UI:Label(Parent,Text,Size,Bold)

    local Label = Instance.new("TextLabel")

    Label.BackgroundTransparency = 1
    Label.Size = Size or UDim2.new(1,0,0,30)

    Label.Font = Bold and Enum.Font.GothamBold or Enum.Font.Gotham

    Label.Text = Text or ""

    Label.TextColor3 = App.Theme.Text

    Label.TextSize = 16

    Label.TextXAlignment = Enum.TextXAlignment.Left

    Label.Parent = Parent

    return Label

end

function UI:Button(Parent,Text)

    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(1,0,0,42)

    Button.BackgroundColor3 = App.Theme.Card

    Button.TextColor3 = App.Theme.Text

    Button.Font = Enum.Font.GothamBold

    Button.TextSize = 15

    Button.AutoButtonColor = false

    Button.Text = Text

    Button.Parent = Parent

    UI:Corner(Button,10)
    UI:Stroke(Button)

    return Button

end

_G.SquidNoMo = App

print("[SquidNoMo] Loaded Bootstrap")
print("[SquidNoMo] Device:",App.Device)
print("[SquidNoMo] Version:",App.Version)
