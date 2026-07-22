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
    Game = "Glass Bridge",
    Id = "mapped.games.glass_bridge.glassesp",
    Name = "Glass ESP",
    Description = "Labels known safe, known unsafe, and unknown bridge panels; unknown panels remain clearly marked instead of being guessed.",
    Handler = "GlassESP",
    SafeColor = Color3.fromRGB(60, 255, 126),
    UnsafeColor = Color3.fromRGB(255, 80, 90),
    UnknownColor = Color3.fromRGB(255, 210, 70),
    Interval = 0.65,
    IdleInterval = 1.0,
})
