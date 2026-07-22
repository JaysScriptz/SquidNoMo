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
    ExpectedGame = "Tug of War",
    Id = "mapped.games.tug_of_war.perfect_timing",
    Name = "Perfect Timing",
    Description = "Times pull inputs around the strongest part of the tug sequence.",
    Kind = "Timing",
    IndicatorTokens = {"indicator", "cursor", "needle", "power"},
    ZoneTokens = {"sweet spot", "green", "target", "perfect"},
    ActionTokens = {"pull", "tug", "tap"},
    ActionCooldown = 0.14,
    ActionPriority = 90,
    WaitingMessage = "Waiting for the Tug of War timing meter",
})
