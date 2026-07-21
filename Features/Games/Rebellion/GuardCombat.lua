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
    Id = "mapped.games.rebellion.guardcombat",
    Name = "Guard Combat",
    Description = "Automatically engages nearby guard targets with the equipped tool.",
    Kind = "ToolAura",
    PlayerTokens = {"guard", "staff", "soldier"},
    TargetTokens = {"guard", "staff", "soldier"},
    IncludeNPCs = true,
    ToolTokens = {"gun", "rifle", "pistol", "bat", "weapon"},
    Range = 16,
    FaceTarget = true,
    Interval = 0.16,
})
