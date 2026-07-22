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
    ExpectedGame = "Rebellion",
    Id = "mapped.games.rebellion.guardcombat",
    Name = "Guard Combat",
    Description = "Automatically engages nearby guard targets with the equipped tool.",
    Kind = "ToolAura",
    PlayerTokens = {"guard", "staff", "soldier"},
    TargetTokens = {"guard", "staff", "soldier"},
    IncludeNPCs = true,
    ToolTokens = {"gun", "rifle", "pistol", "bat", "weapon"},
    Range = 16,
    FaceTarget = true,
    Interval = 0.22,
    ActionPriority = 70,
})
