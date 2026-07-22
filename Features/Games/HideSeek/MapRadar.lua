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
    Game = "Hide & Seek",
    Id = "mapped.games.hide_seek.mapradar",
    Name = "Map Radar",
    Description = "Shows nearby players, exits, keys, knives, and doors in a lightweight local radar.",
    Handler = "Radar",
    TargetTokens = {"exit", "key", "knife", "door"},
    Range = 180,
    PlayerColor = Color3.fromRGB(255, 82, 100),
    TargetColor = Color3.fromRGB(60, 255, 126),
    Interval = 0.3,
    IdleInterval = 0.8,
})
