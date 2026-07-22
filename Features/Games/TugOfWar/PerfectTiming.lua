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
    Game = "Tug of War",
    Id = "mapped.games.tug_of_war.perfect_timing",
    Name = "Perfect Timing",
    Description = "Presses the visible pull control only when the timing meter exposes a ready or green zone.",
    Handler = "TimingPulse",
    IndicatorTokens = {"indicator", "cursor", "needle", "power", "marker"},
    ZoneTokens = {"sweet spot", "green", "target", "perfect", "now"},
    ActionTokens = {"pull", "tug", "tap"},
    ActionCooldown = 0.14,
    ActionPriority = 92,
    RequireReady = true,
    Interval = 0.08,
    IdleInterval = 0.55,
    WaitingMessage = "Waiting for the Tug of War timing meter",
})
