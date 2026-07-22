local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then Environment = result end
end

local Manifest = type(Environment.__SquidNoMoBuildManifest) == "table"
    and Environment.__SquidNoMoBuildManifest
    or {}
local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table"
    or Runtime.Revision ~= tostring(Manifest.FeatureRuntimeRevision or "")
    or tonumber(Runtime.BuildNumber) ~= tonumber(Manifest.BuildNumber)
then
    error("SquidNoMo verified feature runtime is unavailable; execute the complete current build")
end

return Runtime:CreateFeature({
    ExpectedGame = "Pentathlon",
    Id = "mapped.games.pentathlon.jegichagi",
    Name = "Jegichagi Assist",
    Description = "Keeps the Jegichagi sequence going with automatic timed inputs.",
    Kind = "Timing",
    IndicatorTokens = {"indicator", "timing", "cursor", "ball"},
    ZoneTokens = {"target", "sweet spot", "green", "kick zone"},
    ActionTokens = {"kick", "jegi", "tap"},
    ClickActionWhenVisible = true,
    ActionCooldown = 0.18,
    ActionPriority = 85,
    WaitingMessage = "Waiting for the Jegichagi timing interface",
})
