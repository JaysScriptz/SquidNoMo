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
    Id = "mapped.games.pentathlon.paengi",
    Name = "Paengi Assist",
    Description = "Automates the spin interaction for the Paengi event.",
    Kind = "Timing",
    IndicatorTokens = {"indicator", "power", "cursor", "spin"},
    ZoneTokens = {"target", "sweet spot", "green", "spin zone"},
    ActionTokens = {"spin", "pull", "paengi", "play"},
    ClickActionWhenVisible = true,
    ActionCooldown = 0.22,
    ActionPriority = 85,
    WaitingMessage = "Waiting for the Paengi timing interface",
})
