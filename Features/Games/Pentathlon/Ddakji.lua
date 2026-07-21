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
    Id = "mapped.games.pentathlon.ddakji",
    Name = "Ddakji Assist",
    Description = "Helps perform the Ddakji action with consistent timing.",
    Kind = "Timing",
    IndicatorTokens = {"indicator", "power", "cursor", "needle"},
    ZoneTokens = {"target", "sweet spot", "green", "flip zone"},
    ActionTokens = {"throw", "flip", "ddakji", "play"},
    ClickActionWhenVisible = true,
    ActionCooldown = 0.25,
    WaitingMessage = "Waiting for the Ddakji timing interface",
})
