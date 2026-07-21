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
    Id = "mapped.games.dalgona.autocut",
    Name = "Auto Cut",
    Description = "Automates the cookie carving interaction to help complete the selected shape.",
    Kind = "GuiAction",
    ActionTokens = {"cut", "carve", "trace", "complete", "finish", "tap"},
    ActionCooldown = 0.12,
    Interval = 0.08,
    WaitingMessage = "Waiting for the Dalgona cutting controls",
})
