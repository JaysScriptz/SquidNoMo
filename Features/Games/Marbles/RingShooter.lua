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
    ExpectedGame = "Marbles",
    Id = "mapped.games.marbles.ringshooter",
    Name = "Ring Shooter",
    Description = "Assists with lining up and firing marbles toward ring targets.",
    Kind = "AimActivate",
    TargetTokens = {"ring", "hoop", "hole", "target"},
    ToolTokens = {"marble", "ball"},
    Range = 160,
    Interval = 0.20,
    ActionPriority = 75,
    WaitingMessage = "Waiting for a ring target and marble tool",
})
