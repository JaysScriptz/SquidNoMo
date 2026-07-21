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
    Id = "mapped.games.hide_seek.huntertracker",
    Name = "Hunter Tracker",
    Description = "Tracks hunters and keeps their location visible during the round.",
    Kind = "Highlight",
    PlayerMode = true,
    PlayerTokens = {"hunter", "seeker", "killer"},
    Color = Color3.fromRGB(255, 70, 70),
    WaitingMessage = "Waiting for a hunter or seeker role",
})
