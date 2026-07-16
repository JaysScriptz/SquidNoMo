--[[
    🦑 SquidNoMo 🎯
    Version: v0.0.1
    Main Bootstrap

    This file is the application's entry point.
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------
-- Destroy previous UI
--------------------------------------------------

local Existing = PlayerGui:FindFirstChild("SquidNoMo")

if Existing then
    Existing:Destroy()
end

--------------------------------------------------
-- Application
--------------------------------------------------

local App = {}

App.Name = "SquidNoMo"
App.Version = "0.0.1"
App.Game = "Squid Game X"

App.Theme = {
    Background = Color3.fromRGB(17,17,17),
    Surface = Color3.fromRGB(27,27,27),
    Card = Color3.fromRGB(35,35,35),

    Border = Color3.fromRGB(55,55,55),

    Primary = Color3.fromRGB(91,255,98),

    Warning = Color3.fromRGB(255,184,0),

    Danger = Color3.fromRGB(255,77,77),

    Text = Color3.new(1,1,1),

    Secondary = Color3.fromRGB(180,180,180)
}

App.Device = "Desktop"

--------------------------------------------------
-- Device Detection
--------------------------------------------------

do

    local Viewport = workspace.CurrentCamera.ViewportSize

    local Smallest = math.min(Viewport.X,Viewport.Y)

    if UserInputService.TouchEnabled then

        if Smallest < 700 then
            App.Device = "Phone"
        else
            App.Device = "Tablet"
        end

    else

        App.Device = "Desktop"

    end

end

--------------------------------------------------
-- ScreenGui
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SquidNoMo"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

App.Gui = ScreenGui

--------------------------------------------------
-- Global Functions
--------------------------------------------------

function App:Log(...)

    print("[SquidNoMo]",...)

end

function App:Warn(...)

    warn("[SquidNoMo]",...)

end

--------------------------------------------------
-- Startup
--------------------------------------------------

App:Log("Starting "..App.Name)

App:Log("Version:",App.Version)

App:Log("Device:",App.Device)

App:Log("Game:",App.Game)

_G.SquidNoMo = App

return App
