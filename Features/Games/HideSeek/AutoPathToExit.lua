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
    Id = "mapped.games.hide_seek.autopathtoexit",
    Name = "Auto Path to Exit",
    Description = "For Hiders carrying a key, pathfinds to a detected exit and uses its visible interaction.",
    Handler = "PathTo",
    Role = "Hider",
    TargetTokens = {"exit", "escape", "gate", "finish door", "unlock"},
    ExcludeTokens = {"emergency light", "sign"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    Interact = true,
    StopDistance = 6,
    InteractDistance = 12,
    RequireToolTokens = {"key", "keycard"},
    MovementPriority = 86,
    Interval = 0.36,
    IdleInterval = 0.9,
    WaitingMessage = "Waiting for a detected exit",
})
