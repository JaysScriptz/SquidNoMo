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
    Id = "mapped.games.red_light_green_light.stateesp",
    Name = "State ESP",
    Description = "Shows the current red-light or green-light state directly on screen.",
    Kind = "StateHUD",
    TargetTokens = {"status", "light", "red", "green", "stop", "go"},
    Interval = 0.15,
})
