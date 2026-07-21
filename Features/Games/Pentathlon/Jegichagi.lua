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
    Id = "mapped.games.pentathlon.jegichagi",
    Name = "Jegichagi Assist",
    Description = "Keeps the Jegichagi sequence going with automatic timed inputs.",
    Kind = "Timing",
    IndicatorTokens = {"indicator", "timing", "cursor", "ball"},
    ZoneTokens = {"target", "sweet spot", "green", "kick zone"},
    ActionTokens = {"kick", "jegi", "tap"},
    ClickActionWhenVisible = true,
    ActionCooldown = 0.18,
    WaitingMessage = "Waiting for the Jegichagi timing interface",
})
