local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table" or Runtime.Revision ~= "1.1b1-ultralight-r4" then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(repository .. "Features/Shared/Runtime.lua?squidnomo_revision=1_1b1_ultralight_r4")
    Runtime = loadstring(source)()
end
if type(Runtime) ~= "table" or Runtime.Revision ~= "1.1b1-ultralight-r4" then
    error("SquidNoMo feature runtime revision mismatch; deploy the complete build")
end

return Runtime:CreateFeature({
    Id = "mapped.games.pentathlon.paengi",
    Name = "Paengi Assist",
    Description = "Automates the spin interaction for the Paengi event.",
    Kind = "Timing",
    IndicatorTokens = {"indicator", "power", "cursor", "spin"},
    ZoneTokens = {"target", "sweet spot", "green", "spin zone"},
    ActionTokens = {"spin", "pull", "paengi", "play"},
    ClickActionWhenVisible = true,
    ActionCooldown = 0.22,
    ActionPriority = 85,
    WaitingMessage = "Waiting for the Paengi timing interface",
})
