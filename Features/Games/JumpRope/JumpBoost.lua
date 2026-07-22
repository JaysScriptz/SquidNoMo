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
    Id = "mapped.games.jump_rope.jumpboost",
    Name = "Jump Boost",
    Description = "Temporarily raises jump strength during the confirmed Jump Rope round and restores the original value when disabled.",
    Handler = "JumpBoost",
    JumpPower = 72,
    JumpHeight = 12,
    Interval = 0.4,
    IdleInterval = 0.8,
})
