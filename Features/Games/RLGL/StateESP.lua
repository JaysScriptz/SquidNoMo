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
    Id = "mapped.games.red_light_green_light.stateesp",
    Name = "State ESP",
    Description = "Shows the adaptive RLGL state and whether it came from chant audio, crowd consensus, a learned rotating sentinel, or a safe stop fallback.",
    Handler = "StateHUD",
    Interval = 0.1,
    IdleInterval = 0.55,
})
