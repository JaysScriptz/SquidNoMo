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
    Id = "mapped.games.red_light_green_light.stateesp",
    Name = "State ESP",
    Description = "Shows the current red-light or green-light state directly on screen.",
    Kind = "StateHUD",
    TargetTokens = {"status", "light", "red", "green", "stop", "go"},
    Interval = 0.12,
})
