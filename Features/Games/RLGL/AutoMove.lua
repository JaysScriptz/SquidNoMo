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
    Game = "Red Light, Green Light",
    Id = "mapped.games.red_light_green_light.automove",
    Name = "Auto Move",
    Description = "Moves toward the finish during green using live HUD values, doll orientation, doll audio, and crowd movement; stops immediately on red or uncertainty.",
    Handler = "RLGLMove",
    TargetTokens = {"finish", "safe zone", "end zone", "goal", "finish line"},
    ExcludeTokens = {"start", "spawn"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    StopDistance = 8,
    MovementPriority = 96,
    Interval = 0.08,
    IdleInterval = 0.55,
})
