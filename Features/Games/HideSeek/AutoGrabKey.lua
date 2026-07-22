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
    Id = "mapped.games.hide_seek.autograbkey",
    Name = "Auto Grab Key",
    Description = "Finds the nearest key and moves close enough to collect it.",
    Kind = "WalkTo",
    TargetTokens = {"key", "keycard"},
    ExcludeTokens = {"keyboard", "monkey"},
    TargetClasses = {"Tool", "Model", "BasePart", "ProximityPrompt"},
    Interact = true,
    StopDistance = 7,
    InteractDistance = 12,
    SkipIfToolTokens = {"key", "keycard"},
    ExcludeLocalRoleTokens = {"hunter", "seeker", "killer"},
    MovementPriority = 70,
    WaitingMessage = "Waiting for an available Hide & Seek key",
})
