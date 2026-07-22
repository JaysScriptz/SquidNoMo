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
    Game = "Tug of War",
    Id = "mapped.games.tug_of_war.autopull",
    Name = "Auto Pull",
    Description = "Presses the visible Tug of War pull control at a throttled rate and ignores unrelated interface buttons.",
    Handler = "GuiPulse",
    ActionTokens = {"pull", "tug", "tap", "rope"},
    ExcludeTokens = {"shop", "buy", "reward", "close"},
    ActionCooldown = 0.09,
    ActionPriority = 55,
    Interval = 0.08,
    IdleInterval = 0.55,
    WaitingMessage = "Waiting for the Tug of War pull control",
})
