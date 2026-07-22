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
    Id = "mapped.games.mingle.roomesp",
    Name = "Room ESP",
    Description = "Highlights active room and door targets during the confirmed Mingle round.",
    Handler = "RoomESP",
    TargetTokens = {"room", "door", "mingle", "enter room", "join room"},
    Color = Color3.fromRGB(60, 220, 255),
    Interval = 0.55,
    IdleInterval = 0.9,
})
