-- main.lua
local GITHUB_URL = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Cleanup existing
if playerGui:FindFirstChild("SquidNoMoUI") then playerGui.SquidNoMoUI:Destroy() end

-- Load Library
local Lib = loadstring(game:HttpGet(GITHUB_URL .. "Library.lua?v=" .. tick()))()
local UI = Lib:New("SquidNoMo")

-- Load Modules
local PlayerMod = loadstring(game:HttpGet(GITHUB_URL .. "Modules/Player.lua?v=" .. tick()))()
PlayerMod:Init(UI)
