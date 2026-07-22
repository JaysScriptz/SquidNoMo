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
    Game = "Dalgona",
    Id = "mapped.games.dalgona.autolighter",
    Name = "Auto Lighter",
    Description = "Equips and activates a visible lighter or flame tool while the Dalgona round is confirmed.",
    Handler = "ToolPulse",
    ToolTokens = {"lighter", "torch", "flame", "fire"},
    ActionCooldown = 0.35,
    Interval = 0.28,
    IdleInterval = 0.8,
    WaitingMessage = "Waiting for a lighter tool",
})
