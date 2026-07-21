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
    Id = "mapped.games.dalgona.tacehelper",
    Name = "Trace Helper",
    Description = "Adds a visual tracing guide that follows the cursor over the cookie shape.",
    Kind = "GuiHighlight",
    TargetTokens = {"trace", "path", "line", "cursor", "needle", "shape"},
    Color = Color3.fromRGB(60, 220, 255),
    Thickness = 4,
    WaitingMessage = "Waiting for a trace path or cursor",
})
