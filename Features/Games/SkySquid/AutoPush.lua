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
    Id = "mapped.games.sky_squid.autopush",
    Name = "Auto Push",
    Description = "Uses the push action when an opponent enters range.",
    Kind = "ToolAura",
    ToolTokens = {"push", "shove"},
    Range = 12,
    FaceTarget = true,
    Interval = 0.18,
})
