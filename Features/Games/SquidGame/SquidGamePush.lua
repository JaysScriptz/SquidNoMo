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
    ExpectedGame = "Squid Game",
    Id = "mapped.games.squid_game.squidgamepush",
    Name = "Squid Game Push",
    Description = "Automatically uses the push tool against nearby opponents.",
    Kind = "ToolAura",
    ToolTokens = {"push", "shove"},
    Range = 12,
    FaceTarget = true,
    Interval = 0.24,
    ActionPriority = 70,
})
