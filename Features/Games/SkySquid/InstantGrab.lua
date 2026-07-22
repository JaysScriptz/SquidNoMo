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
    ExpectedGame = "Sky Squid",
    Id = "mapped.games.sky_squid.instantgrab",
    Name = "Instant Grab",
    Description = "Quickly collects nearby weapons, poles, and usable tools.",
    Kind = "Interact",
    TargetTokens = {"weapon", "pole", "knife", "tool", "bat"},
    ExcludeTokens = {"owned", "inventory"},
    TargetClasses = {"Tool", "Model", "BasePart", "ProximityPrompt"},
    MaxDistance = 45,
    Walk = true,
    InteractDistance = 11,
    ActionCooldown = 0.45,
    WaitingMessage = "Waiting for a nearby usable item",
})
