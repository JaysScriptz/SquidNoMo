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
    Game = "Hide & Seek",
    Id = "mapped.games.hide_seek.enemyesp",
    Name = "Enemy ESP",
    Description = "Highlights living opposing players using the confirmed local Hide & Seek role.",
    Handler = "Highlight",
    PlayerMode = true,
    Color = Color3.fromRGB(255, 82, 100),
    Interval = 0.55,
    IdleInterval = 0.9,
    WaitingMessage = "Waiting for opposing players",
})
