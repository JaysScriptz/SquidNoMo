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
    ExpectedGame = "Sky Squid",
    Id = "mapped.games.sky_squid.autofight",
    Name = "Auto Fight",
    Description = "Automatically attacks nearby valid opponents with the equipped tool.",
    Kind = "ToolAura",
    ToolTokens = {"knife", "pole", "bat", "weapon", "push"},
    Range = 11,
    FaceTarget = true,
    Interval = 0.22,
    ActionPriority = 60,
})
