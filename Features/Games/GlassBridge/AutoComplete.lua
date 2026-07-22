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
    ExpectedGame = "Glass Bridge",
    Id = "mapped.games.glass_bridge.autocomplete",
    Name = "Auto Complete",
    Description = "Moves toward detected safe glass tiles in sequence.",
    Kind = "SafeTileWalk",
    MinimumDistance = 2,
    MaximumDistance = 55,
    Interval = 0.32,
    MovementPriority = 75,
    WaitingMessage = "Waiting for Glass Bridge panels",
})
