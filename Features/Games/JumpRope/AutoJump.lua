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
    Id = "mapped.games.jump_rope.autojump",
    Name = "Auto Jump",
    Description = "Tracks the moving rope and jumps only when it is approaching within the verified trigger window.",
    Handler = "RopeJump",
    TargetTokens = {"rope", "swing", "bar", "spinner", "sweep"},
    TriggerDistance = 17,
    Cooldown = 0.62,
    Interval = 0.08,
    IdleInterval = 0.55,
})
