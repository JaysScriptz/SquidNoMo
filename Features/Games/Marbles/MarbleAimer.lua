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
    Id = "mapped.games.marbles.marbleaimer",
    Name = "Marble Aimer",
    Description = "Adds aiming assistance for more consistent marble throws.",
    Kind = "AimActivate",
    TargetTokens = {"ring", "target", "hole", "goal"},
    ToolTokens = {"marble", "ball"},
    Range = 140,
    Interval = 0.20,
    ActionPriority = 60,
    WaitingMessage = "Waiting for a marble and a target",
})
