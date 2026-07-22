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
    Game = "Dalgona",
    Id = "mapped.games.dalgona.autocut",
    Name = "Auto Cut",
    Description = "Uses only client-visible trace nodes or exposed cut controls; it pauses instead of guessing when the interface hides the path.",
    Handler = "DalgonaCut",
    ActionTokens = {"cut", "carve", "trace", "complete", "finish"},
    Interval = 0.14,
    IdleInterval = 0.75,
})
