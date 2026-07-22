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
    Game = "Pentathlon",
    Stage = "Paengi",
    Id = "mapped.games.pentathlon.paengi",
    Name = "Paengi Assist",
    Description = "Triggers the visible spin or pull control only during the ready timing zone.",
    Handler = "TimingPulse",
    IndicatorTokens = {"indicator", "power", "cursor", "spin"},
    ZoneTokens = {"target", "sweet spot", "green", "spin zone", "perfect"},
    ActionTokens = {"spin", "pull", "paengi", "play"},
    ActionCooldown = 0.21,
    ActionPriority = 86,
    RequireReady = true,
    Interval = 0.1,
    IdleInterval = 0.65,
})
