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
    Id = "mapped.games.red_light_green_light.dollesp",
    Name = "Doll ESP",
    Description = "Highlights the doll so its position stays visible from anywhere on the field.",
    Kind = "Highlight",
    TargetTokens = {"doll", "younghee", "young hee", "mugunghwa", "robot"},
    TargetClasses = {"Model", "BasePart"},
    Color = Color3.fromRGB(255, 80, 110),
    WaitingMessage = "Waiting for the RLGL doll",
})
