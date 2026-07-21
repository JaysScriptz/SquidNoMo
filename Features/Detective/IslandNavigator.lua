local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Manifest = type(Environment.__SquidNoMoBuildManifest) == "table"
    and Environment.__SquidNoMoBuildManifest
    or {}
local BUILD_NUMBER = tonumber(Manifest.BuildNumber) or 0
local BUILD_TOKEN = tostring(Manifest.BuildToken or BUILD_NUMBER)
local expectedRevision = tostring(Manifest.FeatureRuntimeRevision or "visual-gameplay-runtime-r2")

local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table"
    or Runtime.Revision ~= expectedRevision
    or tonumber(Runtime.BuildNumber) ~= BUILD_NUMBER
then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(
        repository .. "Features/Shared/Runtime.lua?squidnomo_build=" .. BUILD_TOKEN
    )
    Runtime = loadstring(source)()
end
if type(Runtime) ~= "table"
    or Runtime.Revision ~= expectedRevision
    or tonumber(Runtime.BuildNumber) ~= BUILD_NUMBER
then
    error("SquidNoMo feature runtime build mismatch; deploy the complete build")
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
