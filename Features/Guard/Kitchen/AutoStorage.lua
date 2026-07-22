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
    Id = "mapped.guards.kitchen_staff.autostorage",
    Name = "Auto Storage",
    Description = "Moves cooked food into detected storage or delivery stations.",
    Kind = "TaskChain",
    RequireToolTokens = {"cooked", "meal", "food", "tray"},
    SourceTokens = {"cooked", "meal", "tray", "collect meal", "pick up tray"},
    DestinationTokens = {"storage", "shelf", "delivery", "counter", "serve", "place food", "deliver meal", "submit tray"},
    SourceLabel = "cooked food",
    DestinationLabel = "storage or delivery station",
    InteractDistance = 11,
    ActionCooldown = 0.8,
    MovementPriority = 85,
    ActionPriority = 80,
})
