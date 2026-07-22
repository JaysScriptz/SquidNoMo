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
    Id = "mapped.guards.morgue_staff.coffindisposal",
    Name = "Coffin Disposal",
    Description = "Carries detected coffin or body tools toward the disposal area.",
    Kind = "TaskChain",
    RequireToolTokens = {"coffin", "body", "corpse"},
    SourceTokens = {"coffin", "body", "corpse"},
    DestinationTokens = {"dispose", "disposal", "incinerator", "furnace", "burn", "drop", "cremate", "place coffin"},
    SourceLabel = "coffin or body",
    DestinationLabel = "disposal area",
    InteractDistance = 12,
    ActionCooldown = 0.9,
    MovementPriority = 80,
    ActionPriority = 75,
})
