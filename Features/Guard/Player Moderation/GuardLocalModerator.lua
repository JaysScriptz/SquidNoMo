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
    Id = "mapped.guards.game_moderation.guardlocalmoderator",
    Name = "Guard Local Moderator",
    Description = "Assists with nearby guard moderation targets while avoiding unsupported rounds.",
    Kind = "ToolAura",
    PlayerTokens = {},
    ExcludePlayerTokens = {"guard", "staff", "detective", "frontman"},
    ToolTokens = {"taser", "stun", "baton", "guard", "weapon"},
    Range = 12,
    FaceTarget = true,
    Interval = 0.22,
})
