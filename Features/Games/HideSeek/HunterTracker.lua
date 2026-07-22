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
    Id = "mapped.games.hide_seek.huntertracker",
    Name = "Hunter Tracker",
    Description = "Highlights living players whose team, role, or character cues identify them as a Hunter or Seeker.",
    Handler = "Highlight",
    PlayerMode = true,
    PlayerTokens = {"hunter", "seeker", "killer"},
    Color = Color3.fromRGB(255, 70, 70),
    Label = "HUNTER",
    Interval = 0.5,
    IdleInterval = 0.9,
    WaitingMessage = "Waiting for a hunter or seeker role",
})
