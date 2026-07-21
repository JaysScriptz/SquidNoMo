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
    Id = "mapped.games.hide_seek.exitesp",
    Name = "Exit ESP",
    Description = "Marks detected exits and escape points in the map.",
    Kind = "Highlight",
    TargetTokens = {"exit", "escape", "gate", "finish door"},
    TargetClasses = {"Model", "BasePart"},
    Color = Color3.fromRGB(60, 255, 126),
    WaitingMessage = "Waiting for detected exits",
})
