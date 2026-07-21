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
    Id = "mapped.games.marbles.marblesesp",
    Name = "Marbles ESP",
    Description = "Highlights marbles, targets, and useful round objects.",
    Kind = "Highlight",
    TargetTokens = {"marble", "ring", "target", "hole"},
    TargetClasses = {"Tool", "Model", "BasePart"},
    Color = Color3.fromRGB(60, 220, 255),
    WaitingMessage = "Waiting for marble targets",
})
