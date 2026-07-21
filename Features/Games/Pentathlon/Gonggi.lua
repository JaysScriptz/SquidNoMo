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
    Id = "mapped.games.pentathlon.gonggi",
    Name = "Gonggi Assist",
    Description = "Automates the repeated inputs needed for the Gonggi event.",
    Kind = "GuiAction",
    ActionTokens = {"catch", "throw", "gonggi", "tap", "next"},
    ActionCooldown = 0.12,
    Interval = 0.08,
    WaitingMessage = "Waiting for the Gonggi action controls",
})
