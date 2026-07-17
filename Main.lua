print("MAIN STARTED")

local URL = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Config.lua"

print(URL)

local Source = game:HttpGet(URL)

print("Downloaded:", #Source)

local Chunk = loadstring(Source)

print("Compiled:", Chunk ~= nil)

Chunk()

print("CONFIG FINISHED")
