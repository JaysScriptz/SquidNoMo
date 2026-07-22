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
    Id = "mapped.detective.evidence.evidencecollector",
    Name = "Evidence Collector",
    Description = "Walks to nearby evidence and activates supported collection prompts.",
    Kind = "Interact",
    TargetTokens = {"evidence", "clue", "file", "document", "keycard", "fingerprint", "collect evidence", "inspect clue", "investigate"},
    ExcludeTokens = {"submitted", "deposit"},
    TargetClasses = {"Tool", "Model", "BasePart", "ProximityPrompt", "ClickDetector"},
    MaxDistance = 80,
    Walk = true,
    InteractDistance = 12,
    ActionCooldown = 0.65,
    MovementPriority = 70,
    ActionPriority = 70,
    WaitingMessage = "Waiting for collectible evidence",
})
