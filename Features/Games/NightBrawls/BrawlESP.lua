local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then Environment = result end
end
local Manifest = type(Environment.__SquidNoMoBuildManifest) == "table" and Environment.__SquidNoMoBuildManifest or {}
local Runtime = Environment.__SquidNoMoGameRuntime
if type(Runtime) ~= "table"
    or tostring(Runtime.Revision) ~= tostring(Manifest.GameRuntimeRevision or "")
    or tonumber(Runtime.BuildNumber) ~= tonumber(Manifest.BuildNumber)
then
    error("SquidNoMo game runtime is unavailable; deploy and execute the complete current build")
end


return Runtime:CreateFeature({
    Game = "Fight Nights",
    Id = "mapped.games.fight_nights.brawlesp",
    Name = "Brawl ESP",
    Description = "Highlights living nearby opponents during confirmed Fight Nights or Lights Out rounds.",
    Handler = "Highlight",
    PlayerMode = true,
    Color = Color3.fromRGB(255, 70, 92),
    Interval = 0.5,
    IdleInterval = 0.9,
    WaitingMessage = "Waiting for night-brawl opponents",
})
