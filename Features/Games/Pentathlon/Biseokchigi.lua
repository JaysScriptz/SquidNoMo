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
    Stage = "Biseokchigi",
    Id = "mapped.games.pentathlon.biseokchigi",
    Name = "Biseokchigi Assist",
    Description = "Acts only on the visible Biseokchigi timing control when its target zone is ready.",
    Handler = "TimingPulse",
    IndicatorTokens = {"indicator", "power", "cursor", "needle"},
    ZoneTokens = {"target", "sweet spot", "green", "hit zone", "perfect"},
    ActionTokens = {"throw", "hit", "biseok", "play"},
    ActionCooldown = 0.24,
    ActionPriority = 86,
    RequireReady = true,
    Interval = 0.1,
    IdleInterval = 0.65,
})
