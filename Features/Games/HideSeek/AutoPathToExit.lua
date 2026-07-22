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
    Id = "mapped.games.hide_seek.autopathtoexit",
    Name = "Auto Path to Exit",
    Description = "Uses pathfinding to walk toward the nearest detected exit.",
    Kind = "WalkTo",
    TargetTokens = {"exit", "escape", "gate", "finish door"},
    ExcludeTokens = {"emergency light"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    StopDistance = 7,
    Interact = true,
    InteractDistance = 12,
    RequireToolTokens = {"key", "keycard"},
    ExcludeLocalRoleTokens = {"hunter", "seeker", "killer"},
    MovementPriority = 85,
    WaitingMessage = "Waiting for a detected exit",
})
