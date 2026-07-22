local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then Environment = result end
end

local Manifest = type(Environment.__SquidNoMoBuildManifest) == "table"
    and Environment.__SquidNoMoBuildManifest
    or {}
local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table"
    or Runtime.Revision ~= tostring(Manifest.FeatureRuntimeRevision or "")
    or tonumber(Runtime.BuildNumber) ~= tonumber(Manifest.BuildNumber)
then
    error("SquidNoMo verified feature runtime is unavailable; execute the complete current build")
end

return Runtime:CreateFeature({
    ExpectedGame = "Glass Bridge",
    Id = "mapped.games.glass_bridge.glassesp",
    Name = "Glass ESP",
    Description = "Highlights detected safe and unsafe glass panels.",
    Kind = "GlassESP",
    SafeColor = Color3.fromRGB(60, 255, 126),
    UnsafeColor = Color3.fromRGB(255, 80, 90),
    UnknownColor = Color3.fromRGB(255, 210, 70),
    Interval = 0.75,
})
