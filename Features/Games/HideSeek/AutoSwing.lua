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
    ExpectedGame = "Hide & Seek",
    Id = "mapped.games.hide_seek.autoswing",
    Name = "Auto Swing",
    Description = "Automatically activates the equipped melee tool while enabled.",
    Kind = "ToolAura",
    ToolTokens = {"knife", "bat", "sword", "weapon", "blade"},
    Range = 10,
    FaceTarget = true,
    Interval = 0.24,
    LocalRoleTokens = {"hunter", "seeker", "killer"},
    ActionPriority = 70,
    WaitingMessage = "Waiting for a melee tool and a nearby opponent",
})
