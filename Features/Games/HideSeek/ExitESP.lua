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
    Game = "Hide & Seek",
    Id = "mapped.games.hide_seek.exitesp",
    Name = "Exit ESP",
    Description = "Highlights detected exits, gates, and escape doors in the active maze.",
    Handler = "Highlight",
    TargetTokens = {"exit", "escape", "gate", "finish door", "unlock"},
    ExcludeTokens = {"emergency light", "sign"},
    TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
    Color = Color3.fromRGB(60, 255, 126),
    Label = "EXIT",
    Interval = 0.65,
    IdleInterval = 1.0,
    WaitingMessage = "Waiting for detected exits",
})
