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
    Game = "Glass Bridge",
    Id = "mapped.games.glass_bridge.autocomplete",
    Name = "Auto Complete",
    Description = "Walks only to glass panels verified safe by exposed state or by another living player standing on them; it never guesses.",
    Handler = "GlassWalk",
    MinimumDistance = 2,
    MaximumDistance = 55,
    MovementPriority = 76,
    Interval = 0.34,
    IdleInterval = 0.75,
})
