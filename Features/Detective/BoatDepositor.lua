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
    Id = "mapped.detective.boat_operations.boatdepositor",
    Name = "Boat Depositor",
    Description = "Walks evidence back to the boat and deposits supported evidence tools.",
    Kind = "TaskChain",
    RequireToolTokens = {"evidence", "clue", "file", "document", "keycard"},
    SourceTokens = {"evidence", "clue", "file", "document", "keycard"},
    DestinationTokens = {"boat", "deposit", "submit", "evidence box", "dock", "return evidence", "hand in evidence"},
    SourceLabel = "evidence",
    DestinationLabel = "boat evidence deposit",
    InteractDistance = 12,
    ActionCooldown = 0.9,
    MovementPriority = 90,
    ActionPriority = 85,
})
