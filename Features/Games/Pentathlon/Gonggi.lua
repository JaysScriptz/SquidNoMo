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
    Game = "Pentathlon",
    Stage = "Gonggi",
    Id = "mapped.games.pentathlon.gonggi",
    Name = "Gonggi Assist",
    Description = "Presses only visible Gonggi catch, throw, or next controls and ignores unrelated interface buttons.",
    Handler = "GuiPulse",
    ActionTokens = {"catch", "throw", "gonggi", "tap", "next"},
    ExcludeTokens = {"shop", "buy", "reward", "close"},
    ActionCooldown = 0.13,
    ActionPriority = 68,
    Interval = 0.1,
    IdleInterval = 0.65,
})
