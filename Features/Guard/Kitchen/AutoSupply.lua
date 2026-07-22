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
    Id = "mapped.guards.kitchen_staff.autosupply",
    Name = "Auto Supply",
    Description = "Collects nearby kitchen supplies when inventory space is available.",
    Kind = "Interact",
    TargetTokens = {"supply", "ingredient", "raw", "food", "crate", "collect", "pick up", "take supply", "grab", "take", "pickup", "pick up ingredient"},
    ExcludeTokens = {"cooked", "empty"},
    TargetClasses = {"Tool", "Model", "BasePart", "ProximityPrompt"},
    MaxDistance = 50,
    Walk = true,
    InteractDistance = 11,
    ActionCooldown = 0.6,
    MovementPriority = 50,
    ActionPriority = 50,
    WaitingMessage = "Waiting for kitchen supplies",
})
