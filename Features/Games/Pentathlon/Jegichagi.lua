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
    Stage = "Jegichagi",
    Id = "mapped.games.pentathlon.jegichagi",
    Name = "Jegichagi Assist",
    Description = "Triggers the visible kick control only during the ready timing zone.",
    Handler = "TimingPulse",
    IndicatorTokens = {"indicator", "timing", "cursor", "ball"},
    ZoneTokens = {"target", "sweet spot", "green", "kick zone", "perfect"},
    ActionTokens = {"kick", "jegi", "tap"},
    ActionCooldown = 0.17,
    ActionPriority = 86,
    RequireReady = true,
    Interval = 0.09,
    IdleInterval = 0.65,
})
