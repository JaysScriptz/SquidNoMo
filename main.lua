--[[
    🦑 SquidNoMo 🎯
    Version: 1.0.0 Beta
    Main Bootstrap
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Destroy previous instance
pcall(function()
    PlayerGui:WaitForChild("SquidNoMo"):Destroy()
end)

----------------------------------------------------
-- ScreenGui
----------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SquidNoMo"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

----------------------------------------------------
-- Main Window
----------------------------------------------------

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.fromOffset(1050,650)
Window.Position = UDim2.new(.5,-525,.5,-325)
Window.BackgroundColor3 = Color3.fromRGB(17,17,17)
Window.BorderSizePixel = 0
Window.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,16)
Corner.Parent = Window

----------------------------------------------------
-- Header
----------------------------------------------------

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,60)
Header.BackgroundColor3 = Color3.fromRGB(27,27,27)
Header.BorderSizePixel = 0
Header.Parent = Window

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0,16)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(20,0)
Title.Size = UDim2.new(0,350,1,0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextColor3 = Color3.fromRGB(91,255,98)
Title.Text = "🦑 SquidNoMo 🎯"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

----------------------------------------------------
-- Experience
----------------------------------------------------

local Experience = Instance.new("TextLabel")
Experience.BackgroundTransparency = 1
Experience.Position = UDim2.new(1,-350,0,6)
Experience.Size = UDim2.fromOffset(330,18)
Experience.Font = Enum.Font.Gotham
Experience.Text = "Experience : Squid Game X"
Experience.TextSize = 14
Experience.TextColor3 = Color3.fromRGB(255,255,255)
Experience.TextXAlignment = Enum.TextXAlignment.Right
Experience.Parent = Header

----------------------------------------------------
-- Status
----------------------------------------------------

local Status = Instance.new("TextLabel")
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(1,-350,0,24)
Status.Size = UDim2.fromOffset(330,18)
Status.Font = Enum.Font.Gotham
Status.Text = "Status : Detecting..."
Status.TextSize = 14
Status.TextColor3 = Color3.fromRGB(91,255,98)
Status.TextXAlignment =
