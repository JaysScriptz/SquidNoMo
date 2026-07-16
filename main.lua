-- main.lua
local GITHUB_BASE = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
local cacheBuster = "?v=" .. tick()

-- 1. Setup UI
local Lib = loadstring(game:HttpGet(GITHUB_BASE .. "library.lua" .. cacheBuster))()
local UI = Lib:New("SquidNoMo")

-- 2. Init Modules
local Sidebar = loadstring(game:HttpGet(GITHUB_BASE .. "modules/sidebar.lua" .. cacheBuster))()
Sidebar:Init(UI)

print("SquidNoMo Initialized Successfully")
