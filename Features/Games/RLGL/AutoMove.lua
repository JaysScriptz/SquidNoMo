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
    ExpectedGame = "Red Light, Green Light",
    Id = "mapped.games.red_light_green_light.automove",
    Name = "Auto Move",
    Description = "Moves on green light and stops automatically when the doll changes to red.",
    Kind = "RLGLAutoMove",
    TargetTokens = {"finish", "safe zone", "end zone", "goal"},
    Interval = 0.10,
    MovementPriority = 95,
    IdleInterval = 0.65,
    WaitingMessage = "Waiting for the RLGL status and finish area",
})
