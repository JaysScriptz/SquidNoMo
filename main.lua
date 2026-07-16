-- main.lua
local BaseURL = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"

-- Load the Library (The Visual Engine)
local Library = loadstring(game:HttpGet(BaseURL .. "library.lua?v=" .. tick()))()

-- Load the UI Window
local UI = Library:New("SquidNoMo")

-- Load the Player Features
local Player = loadstring(game:HttpGet(BaseURL .. "modules/Sidebar.lua?v=" .. tick()))()
-- Add your tab logic here...
