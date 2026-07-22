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
    ExpectedGame = "Red Light, Green Light",
    Id = "mapped.games.red_light_green_light.antistuck",
    Name = "Anti Stuck",
    Description = "Detects stalled movement and helps the character recover during the round.",
    Kind = "AntiStuck",
    Interval = 0.35,
    StuckSeconds = 2.2,
    MinimumMovement = 0.3,
    RecoveryDistance = 5,
    IdleInterval = 0.8,
})
