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
    Id = "mapped.games.jump_rope.autoposition",
    Name = "Auto Position",
    Description = "Keeps the character near the lane established when the feature is enabled while allowing forward progress.",
    Handler = "LaneKeeper",
    TargetTokens = {"finish", "end", "goal", "exit", "other side"},
    ExcludeTokens = {"start", "spawn"},
    TargetClasses = {"Model", "BasePart"},
    MaxDistance = 7,
    MovementPriority = 28,
    Interval = 0.24,
    IdleInterval = 0.75,
})
