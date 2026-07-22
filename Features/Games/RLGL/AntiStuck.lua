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
    Id = "mapped.games.red_light_green_light.antistuck",
    Name = "Anti Stuck",
    Description = "Checks real movement progress and applies one jump recovery only during confirmed green light.",
    Handler = "AntiStuck",
    StuckSeconds = 2.1,
    MinimumMovement = 0.4,
    Interval = 0.3,
    IdleInterval = 0.75,
})
