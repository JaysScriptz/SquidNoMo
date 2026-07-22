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
    ExpectedGame = "Fight Nights",
    Id = "mapped.games.fight_nights.combataura",
    Name = "Combat Aura",
    Description = "Automatically uses the equipped combat tool on nearby valid targets.",
    Kind = "ToolAura",
    ToolTokens = {"bat", "bottle", "knife", "weapon", "fist"},
    Range = 10,
    FaceTarget = true,
    Interval = 0.22,
    ActionPriority = 65,
})
