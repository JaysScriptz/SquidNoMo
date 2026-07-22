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
    Id = "mapped.games.pentathlon.ddakji",
    Name = "Ddakji Assist",
    Description = "Helps perform the Ddakji action with consistent timing.",
    Kind = "Timing",
    IndicatorTokens = {"indicator", "power", "cursor", "needle"},
    ZoneTokens = {"target", "sweet spot", "green", "flip zone"},
    ActionTokens = {"throw", "flip", "ddakji", "play"},
    ClickActionWhenVisible = true,
    ActionCooldown = 0.25,
    ActionPriority = 85,
    WaitingMessage = "Waiting for the Ddakji timing interface",
})
