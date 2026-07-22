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
    Id = "mapped.guards.morgue_staff.coffingrabber",
    Name = "Coffin Grabber",
    Description = "Finds and collects the nearest available coffin or body target.",
    Kind = "Interact",
    TargetTokens = {"coffin", "body", "corpse", "grab coffin", "pick up body", "collect body", "grab", "take", "carry", "pickup"},
    ExcludeTokens = {"disposal", "incinerator"},
    TargetClasses = {"Tool", "Model", "BasePart", "ProximityPrompt"},
    MaxDistance = 55,
    Walk = true,
    InteractDistance = 12,
    ActionCooldown = 0.7,
    MovementPriority = 55,
    ActionPriority = 55,
    WaitingMessage = "Waiting for an available coffin or body",
})
