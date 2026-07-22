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
    Game = "Sky Squid",
    Id = "mapped.games.sky_squid.instantgrab",
    Name = "Instant Grab",
    Description = "Finds the best nearby interactive weapon or pole and uses a supported prompt, click, or touch interaction.",
    Handler = "Interact",
    TargetTokens = {"weapon", "pole", "knife", "tool", "bat"},
    ExcludeTokens = {"owned", "inventory", "shop", "icon"},
    TargetClasses = {"Tool", "Model", "BasePart", "ProximityPrompt"},
    MaxDistance = 45,
    Walk = true,
    InteractDistance = 11,
    MovementPriority = 58,
    ActionCooldown = 0.45,
    Interval = 0.3,
    IdleInterval = 0.8,
    WaitingMessage = "Waiting for a nearby usable item",
})
