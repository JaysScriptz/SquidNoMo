local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table" or Runtime.Revision ~= "1.1b1-ultralight-r4" then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(repository .. "Features/Shared/Runtime.lua?squidnomo_revision=1_1b1_ultralight_r4")
    Runtime = loadstring(source)()
end
if type(Runtime) ~= "table" or Runtime.Revision ~= "1.1b1-ultralight-r4" then
    error("SquidNoMo feature runtime revision mismatch; deploy the complete build")
end

return Runtime:CreateFeature({
    Id = "mapped.detective.evidence.evidenceesp",
    Name = "Evidence ESP",
    Description = "Highlights evidence, clues, files, and keycards in the world.",
    Kind = "Highlight",
    TargetTokens = {"evidence", "clue", "file", "document", "keycard", "fingerprint"},
    ExcludeTokens = {"submitted", "deposit"},
    TargetClasses = {"Tool", "Model", "BasePart"},
    Color = Color3.fromRGB(60, 220, 255),
    WaitingMessage = "Waiting for evidence objects",
})
