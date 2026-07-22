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
    Game = "Rebellion",
    Id = "mapped.games.rebellion.frontmannavigator",
    Name = "Frontman Navigator",
    Description = "Pathfinds toward the confirmed Frontman, command room, control room, or final Rebellion objective.",
    Handler = "PathTo",
    TargetTokens = {"frontman", "front man", "command room", "control room", "host", "office"},
    ExcludeTokens = {"poster", "icon", "shop"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    StopDistance = 9,
    Interact = true,
    InteractDistance = 12,
    MovementPriority = 72,
    Interval = 0.4,
    IdleInterval = 0.9,
    WaitingMessage = "Waiting for the Frontman objective",
})
