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
    Id = "mapped.games.fight_nights.brawlesp",
    Name = "Brawl ESP",
    Description = "Highlights nearby opponents during night-fight rounds.",
    Kind = "Highlight",
    PlayerMode = true,
    Color = Color3.fromRGB(255, 70, 92),
    WaitingMessage = "Waiting for night-brawl opponents",
})
