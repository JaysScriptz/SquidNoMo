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
    Id = "mapped.guards.kitchen_staff.autocooker",
    Name = "Auto Cooker",
    Description = "Finds raw supplies, equips them, and assists with nearby cooking stations.",
    Kind = "TaskChain",
    RequireToolTokens = {"raw", "ingredient", "food", "meat"},
    SourceTokens = {"raw", "ingredient", "supply", "food"},
    DestinationTokens = {"cook", "stove", "oven", "grill", "pan"},
    SourceLabel = "raw kitchen supply",
    DestinationLabel = "cooking station",
    InteractDistance = 11,
    ActionCooldown = 0.8,
})
