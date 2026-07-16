-- main.lua
local GITHUB_BASE = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
local cacheBuster = "?v=" .. tick()

local function debugLog(text)
    local sg = game.Players.LocalPlayer.PlayerGui:FindFirstChild("DebugGui")
    if sg and sg:FindFirstChild("TextLabel") then
        sg.TextLabel.Text = text
    end
end

debugLog("Loading Library...")
local success, Lib = pcall(function() return loadstring(game:HttpGet(GITHUB_BASE .. "library.lua" .. cacheBuster))() end)
if not success then debugLog("Error Loading Library: " .. Lib) return end

debugLog("Loading Sidebar...")
local success2, Sidebar = pcall(function() return loadstring(game:HttpGet(GITHUB_BASE .. "modules/Sidebar.lua" .. cacheBuster))() end)
if not success2 then debugLog("Error Loading Sidebar: " .. Sidebar) return end

debugLog("Initializing UI...")
local UI = Lib:New("SquidNoMo")
Sidebar:Init(UI)

debugLog("Success! UI should be visible.")
wait(2)
game.Players.LocalPlayer.PlayerGui.DebugGui:Destroy()
