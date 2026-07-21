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
    Id = "mapped.games.dalgona.highlightesp",
    Name = "Shape Highlight",
    Description = "Outlines the cookie shape so the tracing boundary is easier to see.",
    Kind = "GuiHighlight",
    TargetTokens = {"cookie", "shape", "outline", "cut area", "dalgona"},
    Color = Color3.fromRGB(255, 210, 70),
    Thickness = 3,
    WaitingMessage = "Waiting for the Dalgona shape interface",
})
