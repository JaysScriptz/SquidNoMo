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
    Id = "mapped.games.hide_seek.autograbknife",
    Name = "Auto Grab Knife",
    Description = "For Seekers, finds the best interactive knife target, walks to it, and collects it through the supported interaction.",
    Handler = "PathTo",
    Role = "Seeker",
    TargetTokens = {"knife", "blade", "weapon"},
    ExcludeTokens = {"shop", "cosmetic"},
    TargetClasses = {"Tool", "Model", "BasePart", "ProximityPrompt"},
    Interact = true,
    StopDistance = 6,
    InteractDistance = 12,
    SkipIfToolTokens = {"knife", "blade"},
    MovementPriority = 70,
    Interval = 0.38,
    IdleInterval = 0.85,
    WaitingMessage = "Waiting for an available knife",
})
