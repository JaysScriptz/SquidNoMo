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
    Id = "mapped.games.mingle.autoroom",
    Name = "Auto Room",
    Description = "Reads the visible required count, chooses a nearby room with available capacity, and enters it during the room phase.",
    Handler = "RoomAssist",
    RoomRadius = 12,
    StopDistance = 5,
    InteractDistance = 10,
    MovementPriority = 62,
    Interval = 0.32,
    IdleInterval = 0.75,
})
