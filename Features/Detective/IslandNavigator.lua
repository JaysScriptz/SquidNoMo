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
    Id = "mapped.detective.island_navigation.islandnavigator",
    Name = "Island Navigator",
    Description = "Auto-walks from the boat or starting area to the nearest evidence using pathfinding; it does not teleport.",
    Kind = "WalkTo",
    TargetTokens = {"evidence", "clue", "file", "document", "keycard", "fingerprint"},
    ExcludeTokens = {"boat deposit", "submitted"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    StopDistance = 8,
    MaxWaypoints = 5,
    WaypointTimeout = 1.2,
    WaitingMessage = "Waiting for evidence on the island",
})
