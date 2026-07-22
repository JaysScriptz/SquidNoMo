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
    Game = "Escape",
    Id = "mapped.games.escape.islandnav",
    Name = "Island Extraction Route",
    Description = "Uses pathfinding to walk toward a confirmed extraction boat, dock, or escape finish and interacts when close.",
    Handler = "PathTo",
    TargetTokens = {"extraction", "escape boat", "boat", "dock", "finish", "exit"},
    ExcludeTokens = {"start boat", "decorative"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    StopDistance = 8,
    Interact = true,
    InteractDistance = 12,
    MovementPriority = 70,
    Interval = 0.42,
    IdleInterval = 1.0,
    WaitingMessage = "Waiting for an extraction boat or finish point",
})
