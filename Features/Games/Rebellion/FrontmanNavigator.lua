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
    Id = "mapped.games.rebellion.frontmannavigator",
    Name = "Frontman Navigator",
    Description = "Guides the character toward the detected Frontman objective.",
    Kind = "WalkTo",
    TargetTokens = {"frontman", "front man", "command", "control room", "host"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    StopDistance = 10,
    MovementPriority = 60,
    WaitingMessage = "Waiting for the Frontman objective",
})
