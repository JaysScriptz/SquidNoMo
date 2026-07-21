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
    Id = "mapped.games.hide_seek.mapradar",
    Name = "Map Radar",
    Description = "Shows nearby players and important map objects in a compact radar view.",
    Kind = "Radar",
    PlayerColor = Color3.fromRGB(255, 82, 100),
    TargetColor = Color3.fromRGB(60, 255, 126),
    TargetTokens = {"exit", "key", "knife", "door"},
    Range = 180,
    Title = "HIDE & SEEK RADAR",
})
