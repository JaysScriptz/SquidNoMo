local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then Environment = result end
end
local Manifest = type(Environment.__SquidNoMoBuildManifest) == "table" and Environment.__SquidNoMoBuildManifest or {}
local Runtime = Environment.__SquidNoMoGameRuntime
if type(Runtime) ~= "table"
    or tostring(Runtime.Revision) ~= tostring(Manifest.GameRuntimeRevision or "")
    or tonumber(Runtime.BuildNumber) ~= tonumber(Manifest.BuildNumber)
then
    error("SquidNoMo game runtime is unavailable; deploy and execute the complete current build")
end


return Runtime:CreateFeature({
    Game = "Mingle",
    Id = "mapped.games.mingle.smartroom",
    Name = "Smart Room",
    Description = "Scores nearby rooms by distance and occupancy, rejects full rooms, and moves toward the best verified option.",
    Handler = "RoomAssist",
    RoomRadius = 12,
    StopDistance = 5,
    InteractDistance = 10,
    MovementPriority = 78,
    Interval = 0.28,
    IdleInterval = 0.7,
})
