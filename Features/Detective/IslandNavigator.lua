local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then Environment = result end
end

local Manifest = type(Environment.__SquidNoMoBuildManifest) == "table"
    and Environment.__SquidNoMoBuildManifest
    or {}
local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table"
    or Runtime.Revision ~= tostring(Manifest.FeatureRuntimeRevision or "")
    or tonumber(Runtime.BuildNumber) ~= tonumber(Manifest.BuildNumber)
then
    error("SquidNoMo verified feature runtime is unavailable; execute the complete current build")
end

return Runtime:CreateFeature({
    Id = "mapped.detective.island_navigation.islandnavigator",
    Name = "Island Navigator",
    Description = "Auto-walks from the boat or starting area to the nearest evidence using pathfinding; it does not teleport.",
    Kind = "WalkTo",
    TargetTokens = {"evidence", "clue", "file", "document", "keycard", "fingerprint", "objective", "waypoint", "hint marker"},
    ExcludeTokens = {"boat deposit", "submitted"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    StopDistance = 8,
    MaxWaypoints = 5,
    MovementPriority = 55,
    WaypointTimeout = 1.2,
    WaitingMessage = "Waiting for evidence on the island",
})
