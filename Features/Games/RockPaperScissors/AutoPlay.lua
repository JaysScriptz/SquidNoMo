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
    Game = "Rock, Paper, Scissors Minus One",
    Id = "mapped.games.rock_paper_scissors_minus_one.autoplay",
    Name = "Auto Play",
    Description = "Reads visible opponent choice text when available, chooses a counter, and submits through the visible RPS controls.",
    Handler = "RPS",
    Interval = 0.32,
    IdleInterval = 0.75,
})
