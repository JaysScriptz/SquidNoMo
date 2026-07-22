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
    Game = "Jump Rope",
    Id = "mapped.games.jump_rope.autocomplete",
    Name = "Auto Complete",
    Description = "Advances toward the finish only when the moving rope is outside the danger window and jumps detected gaps.",
    Handler = "RopeCourse",
    TargetTokens = {"finish", "end", "goal", "exit", "other side", "checkpoint"},
    ExcludeTokens = {"start", "spawn"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    ObstacleTokens = {"rope", "swing", "bar", "spinner", "sweep"},
    JumpDistance = 17,
    StopDistance = 7,
    MovementPriority = 72,
    Interval = 0.1,
    IdleInterval = 0.65,
})
