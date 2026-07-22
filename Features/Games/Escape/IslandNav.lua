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
    ExpectedGame = "Escape",
    Id = "mapped.games.escape.islandnav",
    Name = "Island Extraction Route",
    Description = "Walks toward the detected extraction boat or finish point.",
    Kind = "WalkTo",
    TargetTokens = {"extraction", "escape boat", "boat", "dock", "finish", "exit"},
    ExcludeTokens = {"start boat"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    StopDistance = 9,
    MovementPriority = 70,
    Interact = true,
    InteractDistance = 12,
    WaitingMessage = "Waiting for an extraction boat or finish point",
})
