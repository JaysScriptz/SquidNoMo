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
    Id = "mapped.games.hide_seek.autograbkey",
    Name = "Auto Grab Key",
    Description = "For Hiders, finds the best interactive key target, walks to it, and uses the available prompt, click, or touch interaction.",
    Handler = "PathTo",
    Role = "Hider",
    TargetTokens = {"key", "keycard", "door key", "exit key"},
    ExcludeTokens = {"keyboard", "monkey", "shop"},
    TargetClasses = {"Tool", "Model", "BasePart", "ProximityPrompt"},
    Interact = true,
    StopDistance = 6,
    InteractDistance = 12,
    SkipIfToolTokens = {"key", "keycard"},
    MovementPriority = 72,
    Interval = 0.38,
    IdleInterval = 0.85,
    WaitingMessage = "Waiting for an available Hide & Seek key",
})
