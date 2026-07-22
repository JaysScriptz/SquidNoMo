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
    Id = "mapped.guards.kitchen_staff.autocooker",
    Name = "Auto Cooker",
    Description = "Finds raw supplies, equips them, and assists with nearby cooking stations.",
    Kind = "TaskChain",
    RequireToolTokens = {"raw", "ingredient", "food", "meat"},
    SourceTokens = {"raw", "ingredient", "supply", "food", "collect", "pick up"},
    DestinationTokens = {"cook", "stove", "oven", "grill", "pan", "place ingredient", "start cooking"},
    SourceLabel = "raw kitchen supply",
    DestinationLabel = "cooking station",
    InteractDistance = 11,
    ActionCooldown = 0.8,
    MovementPriority = 75,
    ActionPriority = 70,
})
