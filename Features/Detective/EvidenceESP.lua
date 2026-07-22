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
    Id = "mapped.detective.evidence.evidenceesp",
    Name = "Evidence ESP",
    Description = "Highlights evidence, clues, files, and keycards in the world.",
    Kind = "Highlight",
    TargetTokens = {"evidence", "clue", "file", "document", "keycard", "fingerprint", "collect evidence", "inspect clue"},
    ExcludeTokens = {"submitted", "deposit"},
    TargetClasses = {"Tool", "Model", "BasePart"},
    Color = Color3.fromRGB(60, 220, 255),
    WaitingMessage = "Waiting for evidence objects",
})
