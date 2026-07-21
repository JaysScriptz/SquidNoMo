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
    Id = "mapped.games.jump_rope.autojump",
    Name = "Auto Jump",
    Description = "Triggers jumps automatically as the rope approaches.",
    Kind = "AutoJump",
    TargetTokens = {"rope", "swing", "bar"},
    TriggerDistance = 17,
    Interval = 0.06,
})
