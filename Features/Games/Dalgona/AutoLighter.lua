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
    ExpectedGame = "Dalgona",
    Id = "mapped.games.dalgona.autolighter",
    Name = "Auto Lighter",
    Description = "Finds, equips, and repeatedly activates the lighter while enabled.",
    Kind = "ToolActivate",
    ToolTokens = {"lighter", "torch", "flame", "fire"},
    Interval = 0.3,
    ActionPriority = 45,
    WaitingMessage = "Waiting for a lighter tool",
})
