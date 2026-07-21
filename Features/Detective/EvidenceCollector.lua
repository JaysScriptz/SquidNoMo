local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table" then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(repository .. "Features/Shared/Runtime.lua?squidnomo_revision=1_1b1_feature_recode_r2")
    Runtime = loadstring(source)()
end

return Runtime:CreateFeature({
    Id = "mapped.detective.evidence.evidencecollector",
    Name = "Evidence Collector",
    Description = "Walks to nearby evidence and activates supported collection prompts.",
    Kind = "Interact",
    TargetTokens = {"evidence", "clue", "file", "document", "keycard", "fingerprint"},
    ExcludeTokens = {"submitted", "deposit"},
    TargetClasses = {"Tool", "Model", "BasePart", "ProximityPrompt", "ClickDetector"},
    MaxDistance = 80,
    Walk = true,
    InteractDistance = 12,
    ActionCooldown = 0.65,
    WaitingMessage = "Waiting for collectible evidence",
})
