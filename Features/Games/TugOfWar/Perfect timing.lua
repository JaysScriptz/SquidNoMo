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
    Id = "mapped.games.tug_of_war.perfect_timing",
    Name = "Perfect Timing",
    Description = "Times pull inputs around the strongest part of the tug sequence.",
    Kind = "Timing",
    IndicatorTokens = {"indicator", "cursor", "needle", "power"},
    ZoneTokens = {"sweet spot", "green", "target", "perfect"},
    ActionTokens = {"pull", "tug", "tap"},
    ActionCooldown = 0.14,
    WaitingMessage = "Waiting for the Tug of War timing meter",
})
