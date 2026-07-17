--//========================================================
--// SquidNoMo Beta 5.0
--// Main.lua
--// Stage 2
--//========================================================

print("MAIN STARTED")

pcall(function()
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "SquidNoMo",
		Text = "Main Started",
		Duration = 5
	})
end)

local Config = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Config.lua"
))()

print("CONFIG LOADED")

pcall(function()
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "SquidNoMo",
		Text = "Config Loaded",
		Duration = 5
	})
end)

return true
